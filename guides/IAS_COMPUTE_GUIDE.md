# IAS Compute Infrastructure Guide

**Purpose:** Reference for AI agents running jobs on IAS infrastructure — shared compute servers and the Typhon SLURM cluster. Read this before launching any computational campaign.

**Audience:** AI agents (Claude, Cursor, etc.) operating in scientific projects at IAS. Written to prevent the mistakes we've already made.

---

## 1. Infrastructure Overview

### 1.1 Compute Servers (No Scheduler)

Six shared-CPU machines, interchangeable for most workloads:

| Host | SSH Alias |
|------|-----------|
| Carme | `Carme` |
| Elara | `Elara` |
| Neso | `Neso` |
| Nereid | `Nereid` |
| Thalassa | `Thalassa` |
| Proteus | `Proteus` |

**Key facts:**
- All share `/home` and `/data` filesystems.
- No job scheduler — you manage your own processes.
- These are **shared machines**; other users may be running jobs.
- You can SSH between them freely. Code on one is available on all.

### 1.2 Typhon Cluster (SLURM Scheduler)

A 64-node beowulf cluster for batch jobs.

- **Login nodes:** `typhon-login1`, `typhon-login2` (for submitting jobs only, not computation)
- **Compute nodes:** 64 nodes, each with quad 24-core Intel Cascade Lake (96 physical cores/node), 384 GB RAM
- **Total cores:** 6144
- **Interconnect:** HDR100 InfiniBand
- **OS:** Springdale Linux 8
- **Scheduler:** SLURM

**Shared filesystems (same as compute servers):**
- `/home` — home directories (quota-limited, for code)
- `/data` — data storage (large, for outputs and banks)

**Cluster-only filesystems:**
- `/scratch/lustre` — parallel filesystem (high-throughput I/O)
- `/scratch/local/` — 600 GB local scratch per node

**QOS and Time Limits:**

| QOS | Time Limit | Cores Available |
|-----|------------|-----------------|
| short | 24 hours | 4608 |
| medium | 72 hours | 3072 |
| long | 168 hours (7 days) | 1536 |

QOS is automatically assigned based on requested `--time`. Fair share scheduling determines priority based on past usage.

### 1.3 Shared Filesystem Implications

Since `/home` and `/data` are cross-mounted on all compute servers AND Typhon:
- Code and data prepared on your server are immediately available everywhere.
- **No need to copy files between machines.**
- Conda environments installed under `/home` work on all machines.
- **Use separate output directories** for runs on different machines to avoid collisions.
- **Data goes on `/data/${USER}/`**, not `/home/` (quota).

---

## 2. CPU Budget Gate (MANDATORY)

### 2.1 Compute Servers — Self-Policing

These are shared machines with no enforced core isolation. You must self-limit CPU usage.

**Definitions:**
- `NCORES_PHYS` = physical cores from `lscpu` (not hyperthreads)
- `TARGET_FRACTION = 0.70` (leave 30% for other users)
- `CORE_BUDGET = floor(NCORES_PHYS × 0.70)`

**Pre-launch requirement — this condition must hold:**

```
jobs × threads_per_job <= CORE_BUDGET
```

**Check before launching:**
```bash
# Physical cores on this machine
lscpu | grep "Core(s) per socket"
lscpu | grep "Socket(s)"
# NCORES_PHYS = cores_per_socket × sockets

# Current load
uptime
ps aux | grep python | grep -v grep | wc -l
```

If the budget would be violated, STOP and either: reduce jobs, cap threads, or move to a different machine.

### 2.2 Typhon — SLURM Handles Allocation

On Typhon, SLURM allocates CPUs per job. But **SLURM does NOT limit threads** — your process can still spawn threads for all 96 cores on the node even if SLURM only allocated 4 CPUs. You must enforce thread limits yourself (see Section 3).

---

## 3. Thread Limits (MANDATORY)

### 3.1 Standard Thread Isolation

Every launch script and SLURM job MUST explicitly set these environment variables. Default PyTorch/BLAS/FFTW behavior uses ALL physical cores, which will monopolize the machine or cause massive contention on the cluster.

```bash
export OMP_NUM_THREADS=${NCPUS}
export MKL_NUM_THREADS=${NCPUS}
export OPENBLAS_NUM_THREADS=${NCPUS}
export NUMEXPR_NUM_THREADS=${NCPUS}
export VECLIB_MAXIMUM_THREADS=${NCPUS}
# If using PyTorch: torch.set_num_threads(N) in your Python code
```

**Implicit defaults are never acceptable.**

### 3.2 CRITICAL: Some Libraries Spawn Internal Threads That Ignore Env Vars

This is the single most important lesson in this guide.

Some libraries (particularly LAL/FFTW-based waveform models, and some linear algebra backends) spawn threads internally through mechanisms that **bypass** `OMP_NUM_THREADS` and all the standard environment variables. The process will quietly use more threads than you allocated.

**Example:** NRSur7dq4 (a gravitational waveform model) spawns **5 threads per process** regardless of any environment variable settings. Setting `OMP_NUM_THREADS=1` has no effect — the process still uses 5 threads.

**How to detect this:**
```bash
# Launch ONE instance of your code
python your_script.py &
PID=$!
sleep 10  # Let it start

# Check actual thread count
cat /proc/$PID/status | grep Threads
# Expected (single-threaded): Threads: 1
# If higher: the library is spawning internal threads

# Also check env vars actually took effect
cat /proc/$PID/environ | tr "\0" "\n" | grep OMP_NUM_THREADS
```

**ALWAYS test thread count with a single process BEFORE scaling up to multiple parallel jobs.**

**Adjusted CPU budget when internal threads exist:**
```
max_parallel_jobs = floor(CORE_BUDGET / actual_threads_per_process)
```

**Example (Carme, 32 cores):**
- Standard single-threaded code: `floor(32 × 0.70 / 1)` = 22 parallel jobs
- Code with 5 internal threads: `floor(32 × 0.70 / 5)` = 4 parallel jobs

If you launch 22 jobs of a 5-thread process, you'll have 110 threads fighting over 32 cores. Everything will be 5-10x slower than expected.

### 3.3 Thread Isolation in SLURM Jobs

In SLURM scripts, derive thread count from the allocation:

```bash
NCPUS=${SLURM_CPUS_PER_TASK:-1}
export OMP_NUM_THREADS=$NCPUS
export MKL_NUM_THREADS=$NCPUS
export OPENBLAS_NUM_THREADS=$NCPUS
export NUMEXPR_NUM_THREADS=$NCPUS
export VECLIB_MAXIMUM_THREADS=$NCPUS
```

For libraries with internal threading, request enough CPUs:
```bash
#SBATCH --cpus-per-task=5   # Match actual thread count
```

And still set the env vars to 1 (to prevent additional BLAS threads on top of the internal ones):
```bash
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
```

---

## 4. Running on Compute Servers

### 4.1 Launch Script Pattern

All launches must use standalone scripts, not complex inline commands.

**Required:**
- Standalone `.sh` file
- Redirects all output to a `.log` file
- Sets CPU thread limits explicitly
- Uses `setsid` to detach processes (see Section 4.2)
- Logs start time, PID, and configuration

**Template:**

```bash
#!/bin/bash
# Launch script for <CAMPAIGN_NAME> on <HOST>
# Launches N jobs with CPU thread limits
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Environment
eval "$(conda shell.bash hook)" && conda activate <ENV_NAME>

# Thread limits
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1

LOG_FILE="$SCRIPT_DIR/launch.log"
echo "$(date -Iseconds): Starting launch on $(hostname)" > "$LOG_FILE"
echo "CPU budget: <N> jobs × <T> threads = <TOTAL> (budget: <BUDGET>)" >> "$LOG_FILE"

for i in $(seq 1 $N_JOBS); do
    nohup python -u "$SCRIPT_DIR/<YOUR_SCRIPT>.py" --arg "$i" \
        >> "$SCRIPT_DIR/job_${i}.log" 2>&1 &
    echo "Job $i PID: $!" >> "$LOG_FILE"
done

echo "$(date -Iseconds): Launched $N_JOBS jobs" >> "$LOG_FILE"
```

### 4.2 Long-Running Jobs and Agent Sessions

**Problem:** If you are an AI agent launching jobs via a tool like Bash, the tool's shell session has a timeout. When the shell dies, child processes may be killed.

**Solution:** Use `setsid` to create a new session, fully detaching the process:

```bash
setsid bash launch.sh > launch_outer.log 2>&1 &
```

This creates a new process group that survives the parent shell being killed. The process will continue running even if the agent's session times out.

**For jobs expected to run > 10 minutes, always use `setsid`.** Then monitor via log files:

```bash
tail -f launch.log        # Watch progress
ps aux | grep your_script  # Verify still running
```

### 4.3 Running on a Different Compute Server

Since all servers share the same filesystems:

```bash
# Check load on other machines
ssh Carme 'nproc && uptime'
ssh Neso 'nproc && uptime'

# Launch on another server (no file copying needed)
ssh Carme 'cd /path/to/campaign && setsid bash launch.sh > launch.log 2>&1 &'
```

### 4.4 Verification After Launch

1. Check log file exists and has content
2. Verify processes are running: `ps aux | grep <YOUR_SCRIPT> | grep -v grep`
3. Check CPU usage is within budget: `top -b -n 1 | head -20`
4. **Check actual thread count:** `cat /proc/<PID>/status | grep Threads`
5. Check env vars: `cat /proc/<PID>/environ | tr "\0" "\n" | grep OMP_NUM_THREADS`

---

## 5. Running on Typhon (SLURM)

### 5.1 Workflow

1. Prepare code and data (already on shared filesystem)
2. Write a SLURM job script (absolute paths, thread isolation)
3. Write a launcher script that submits via `sbatch`
4. Submit from a Typhon login node
5. Monitor with `squeue`

```bash
ssh typhon-login1 'cd /path/to/campaign && bash launch_slurm.sh'
```

### 5.2 SLURM Job Script Template

```bash
#!/bin/bash
#SBATCH --job-name=<NAME>
#SBATCH --output=<LOG_DIR>/<NAME>_%j.out
#SBATCH --error=<LOG_DIR>/<NAME>_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=<NCPUS>
#SBATCH --mem=<MEM>G
#SBATCH --time=<HH:MM:SS>

set -e

echo "=== SLURM Job ==="
echo "Job ID:    $SLURM_JOB_ID"
echo "Node:      $SLURMD_NODENAME"
echo "Date:      $(date -Iseconds)"
echo "Run dir:   <RUN_DIR>"

# ── CRITICAL: Absolute paths (SLURM copies scripts to /var/spool/slurmd/) ──
PROJECT_DIR="<ABSOLUTE_PATH_TO_PROJECT>"

# ── CRITICAL: Thread isolation ──
NCPUS=${SLURM_CPUS_PER_TASK:-1}
export OMP_NUM_THREADS=1       # Set to 1 if library has internal threading
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1

# ── Environment ──
source ${HOME}/anaconda3/etc/profile.d/conda.sh
conda activate <ENV_NAME>

echo "Python: $(which python)"

# ── Execute ──
python -u "$PROJECT_DIR/scripts/<YOUR_SCRIPT>.py" "$@"

EXIT_CODE=$?
echo "=== Done (exit code: $EXIT_CODE) ==="
exit $EXIT_CODE
```

### 5.3 CRITICAL PITFALL: Absolute Paths

**SLURM copies job scripts to `/var/spool/slurmd/` before execution.** Any path derived from `BASH_SOURCE[0]` or `dirname` will point to the wrong location.

```bash
# BAD — will resolve to /var/spool/slurmd/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# GOOD — hardcode the absolute path
PROJECT_DIR="${HOME}/claude-projects/<PROJECT_NAME>"
```

### 5.4 CRITICAL PITFALL: Thread Contention

**SLURM allocates CPUs but does NOT limit threads.** Your process will spawn threads for ALL 96 cores on the node, even if SLURM only allocated 4 CPUs. This causes massive contention.

**Symptom:** Job runs but produces no output for 10+ minutes. `sacct` shows high CPU time but no progress.

**Fix:** Always set `OMP_NUM_THREADS` etc. in the job script (see template above).

### 5.5 Launcher Script Pattern (Real-World)

This pattern handles multiple runs, skips already-completed ones, and supports dry-run:

```bash
#!/bin/bash
# Launch SLURM jobs for all runs
# Usage: bash launch_slurm.sh [--dry-run] [--only RUN_NAME] [--time HH:MM:SS]
set -e

PROJECT_DIR="<ABSOLUTE_PATH_TO_PROJECT>"
SLURM_SCRIPT="$PROJECT_DIR/scripts/slurm_job.sh"
DATA_DIR="<ABSOLUTE_PATH_TO_DATA>"
TIME_LIMIT="${DEFAULT_TIME:-03:00:00}"

# Parse arguments
DRY_RUN=false
ONLY=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true; shift ;;
        --only) ONLY="$2"; shift 2 ;;
        --time) TIME_LIMIT="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

# Define runs
RUNS=(
    "run_name_1"
    "run_name_2"
    # ...
)

SUBMITTED=0
SKIPPED=0

for RUN in "${RUNS[@]}"; do
    # Filter if --only specified
    [[ -n "$ONLY" && "$RUN" != "$ONLY" ]] && continue

    RUN_DIR="$DATA_DIR/$RUN"

    # Skip if already completed (check for output marker)
    if [[ -f "$RUN_DIR/output/results.json" ]]; then
        echo "SKIP  $RUN (already complete)"
        ((SKIPPED++))
        continue
    fi

    # Ensure log directory exists
    mkdir -p "$RUN_DIR/slurm_logs"

    CMD="sbatch --job-name=${RUN} \
         --output=$RUN_DIR/slurm_logs/${RUN}_%j.out \
         --time=${TIME_LIMIT} \
         --export=ALL,RUN_DIR=$RUN_DIR \
         $SLURM_SCRIPT"

    if $DRY_RUN; then
        echo "[DRY] $CMD"
    else
        echo "SUBMIT $RUN"
        eval $CMD
        ((SUBMITTED++))
    fi
done

echo ""
echo "Submitted: $SUBMITTED, Skipped: $SKIPPED"
```

### 5.6 Array Jobs for Block-Parallel Work

When a campaign has many independent blocks (e.g., bank generation, scoring), use SLURM array jobs:

```bash
#SBATCH --array=0-99        # 100 blocks
#SBATCH --cpus-per-task=5
#SBATCH --mem=8G

BLOCK_ID=$SLURM_ARRAY_TASK_ID
```

**Smart relaunching — only submit missing blocks:**

```bash
# Find which blocks still need processing
MISSING=()
for i in $(seq 0 99); do
    [[ -f "$OUTPUT_DIR/block_${i}/done.marker" ]] || MISSING+=($i)
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All blocks complete"
    exit 0
fi

# Submit only missing blocks as comma-separated list
ARRAY_SPEC=$(IFS=,; echo "${MISSING[*]}")
sbatch --array=$ARRAY_SPEC slurm_block.sh
```

### 5.7 Monitoring Commands

```bash
# Your jobs
squeue -u $USER

# Job details
scontrol show job <JOB_ID>

# Job history (after completion)
sacct -j <JOB_ID> --format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS

# Cancel a job
scancel <JOB_ID>

# Cancel all your jobs
scancel -u $USER

# Cluster utilization
sinfo
```

### 5.8 Time Limit Selection

| Expected Runtime | Recommended `--time` | QOS (auto) |
|-----------------|---------------------|------------|
| Minutes | 01:00:00 | short |
| A few hours | 06:00:00 | short |
| Half day | 24:00:00 | short |
| 1-2 days | 72:00:00 | medium |
| Multiple days | 168:00:00 | long |

**Tip:** Shorter time limits = higher scheduling priority. Don't request 7 days for a 2-hour job.

---

## 6. Performance Expectations

These are approximate per-job timings from real campaigns. Use them for planning and sanity-checking.

### 6.1 Gravitational Wave PE (dot-PE)

| Operation | Scale | XPHM Time | NRSur Time | Notes |
|-----------|-------|-----------|------------|-------|
| Bank block (4096 samples) | per block | ~7 sec | ~18-30 min | NRSur spawns 5 threads |
| Full bank (1M samples) | 244 blocks | ~30 min (parallel) | ~10 hrs (parallel) | SLURM array jobs |
| Incoherent scoring block | per block | ~5 min | ~45 min | Same thread behavior |
| Full inference | 32-44k survivors | ~30 min | ~60 min | Phase 5 dominates |

### 6.2 General ML/Scientific Computing

| Operation | Typhon Node (96 cores) | Compute Server (~32 cores) |
|-----------|----------------------|---------------------------|
| NumPy/SciPy batch | ~3x faster (more cores) | Baseline |
| Single-threaded Python | ~Same | ~Same (clock speed similar) |
| I/O-heavy (NFS) | Slower (network FS) | Faster (closer to storage) |

**Key insight:** Typhon nodes are great for embarrassingly parallel work via SLURM arrays. For I/O-heavy single jobs, compute servers may be faster.

---

## 7. Conda Environment on Shared Filesystems

Conda environments installed under `${HOME}` work on all machines. But shells on remote machines and SLURM jobs don't source `.bashrc`, so you must activate explicitly:

```bash
# In any script or SLURM job
source ${HOME}/anaconda3/etc/profile.d/conda.sh
conda activate <ENV_NAME>
```

Or equivalently:
```bash
eval "$(conda shell.bash hook)" && conda activate <ENV_NAME>
```

**Gotcha:** After `pip install -e <package>`, a stale copy of the package in site-packages can shadow the editable install. If imports seem wrong after switching branches:
```bash
rm -rf $CONDA_PREFIX/lib/python*/site-packages/<PACKAGE_NAME>/
pip install -e <package_dir>
```

---

## 8. Data Organization

```
${HOME}/claude-projects/<PROJECT>/     # Code, scripts, notebooks (small)
/data/${USER}/<project>/               # Banks, run outputs, large data (large)
```

**Never put large data in `/home/`** — it has quota limits. Code stays in `/home/`, data goes on `/data/`.

Within `/data/`, organize by campaign:
```
/data/${USER}/<project>/
├── bank_<description>/          # Template banks
├── <campaign_name>/             # Campaign results
│   ├── <run_name>/             # Per-run output
│   │   ├── slurm_logs/         # SLURM stdout/stderr
│   │   ├── inference/          # Inference results
│   │   └── ...
│   └── ...
└── ...
```

---

## 9. Safety Rules

- **Running jobs must not be altered or killed** without explicit user instruction.
- **Configs are read-only after launch.**
- While jobs are running, **inspection only** (read logs, check status).
- Always **verify thread count** with a single test process before scaling up.
- Always **check machine load** before launching on a compute server.
- On SLURM, always use **`--dry-run`** first to verify job parameters.

---

## 10. Smoke Testing (Before Any Campaign)

Before launching a large campaign on any machine:

1. **On your current machine:** Run your script with minimal settings. Record output and timing.
2. **On the target machine:** Run the identical test. Compare results.
3. **If targeting Typhon:** Test via `sbatch` (not just login node). This catches SLURM-specific path and environment issues.
4. **Check thread count** on a single running process before launching parallel jobs.

Only proceed to full launch after all smoke tests pass with consistent results.

---

## 11. Common Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Job fails immediately, "file not found" | SLURM copied script to /var/spool/slurmd/ | Use absolute paths |
| Job runs but no output for 10+ min | Thread contention (96 threads, 4 CPUs) | Set OMP_NUM_THREADS etc. |
| Process uses 5x more threads than expected | Library with internal threading | Test thread count, adjust CPU budget |
| ImportError on SLURM but works locally | PYTHONPATH incomplete | Check all import roots |
| Results differ between machines | Environment mismatch | Run smoke test on both |
| Job stuck in PD (pending) | Low fair-share or full cluster | Check squeue, use shorter time |
| Log file empty but process runs | Buffered stdout | Use `python -u` (unbuffered) |
| Job killed with no error | Hit memory limit | Increase `--mem` or reduce batch size |
| `conda: command not found` in SLURM | Shell doesn't source .bashrc | Use explicit `source .../conda.sh` |

---

## 12. Checkpoint Policy for AI Agents

### STOP_AFTER_LAUNCH (Default)

After launching jobs, verify they are running correctly, then **STOP** and report back. Do not wait for completion.

Report:
- Campaign directory path
- Process IDs or SLURM job IDs
- Status confirmation (processes running / jobs in queue)
- Log file locations
- Monitoring commands the user can run

### AUTO_TO_COMPLETION

Proceed through completion, verification, and reporting. Must be explicitly requested by the user. Never default to this.
