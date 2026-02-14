# Autonomous Optimization Loop Guide

**Purpose:** A systematic methodology for iterative performance optimization. Designed for AI agents working on computationally intensive code where bottleneck identification, correctness preservation, and rigorous measurement matter.

**Origin:** Developed and battle-tested in two projects — an N-body simulation (C/Python/Julia, achieving 10-35x speedups) and a gravitational wave PE pipeline (Python, achieving 8x speedup on the critical phase). The methodology transferred perfectly between domains.

**Audience:** AI agents. This document tells you exactly how to run an optimization campaign.

---

## 1. The Core Loop

```
REPEAT:
  1. PROFILE  — identify the actual bottleneck (don't guess)
  2. THINK    — write reasoning in thinking_log.md BEFORE implementing
  3. PLAN     — write what you'll try and why in the optimization log
  4. IMPLEMENT — make the change
  5. TEST     — run correctness test (MUST pass, or revert)
  6. BENCHMARK — measure performance, record numbers
  7. LOG      — record result in optimization_log.md (include Surprise field)
  8. COMMIT   — git commit the successful change
  9. DECIDE   — continue or stop based on criteria below
```

**Every step is mandatory.** Skipping steps (especially THINK and LOG) defeats the purpose. The value isn't just the speedup — it's the documented reasoning that prevents repeating mistakes.

---

## 2. Stopping Criteria

Stop when **ANY** of these is true:

- **Target speedup achieved** (define this before starting)
- **Last 3 consecutive iterations each gave < 5% improvement** (diminishing returns)
- **N iterations completed** (set a cap, typically 10-15 per optimization target)
- **All reasonable optimizations exhausted** for the current bottleneck

When the current bottleneck is optimized, re-profile. The new bottleneck may be in a completely different part of the code. Start a new optimization campaign targeting it.

---

## 3. Recovery Protocol

- **If correctness test fails:** Revert to last committed version, log the failure, try a different approach. Never commit broken code.
- **If build fails:** Fix the build error first, do not skip the test.
- **If benchmark shows regression:** Revert, log it, move on.
- **If stuck after 3 failed attempts on the same bottleneck:** Skip it. Move to the next optimization target. Document why you're stuck — a future agent may find a solution.

---

## 4. The Surprise Field (MANDATORY)

This is the single most important innovation in this methodology.

Every optimization log entry MUST include a **Surprise** field that captures the delta between your prediction and reality. Write "None" if nothing surprised you — but think hard first.

**What to capture:**
- Did the speedup match your prediction?
- Did something break that shouldn't have?
- Did an optimization help more or less than expected?
- Did you discover something about the code's behavior?

**Why it matters:**
- Forces honest prediction before implementation (combats confirmation bias)
- Creates a searchable record of unexpected behaviors
- Surfaces hidden assumptions about the code
- The surprises are often more valuable than the speedups — they reveal the real architecture

**Examples of good Surprise entries:**
- "Predicted ~8x from 64 threads, got 0.78x regression. Thread creation overhead dominates at this problem size."
- "Expected 2x from early-stopping. Got 7.95x because the batch was sorted — early elements were the expensive ones."
- "None — speedup matched prediction within 10%. The bottleneck was exactly where profiling said."

---

## 5. Documentation Format

### 5.1 Optimization Log Entry

```markdown
## Iteration N: [Brief title]
**Target:** [What bottleneck you're attacking]
**Optimization:** [What you changed and why]
**Bottleneck:** [What profiling revealed]
**Prediction:** [Expected speedup and reasoning]
**Result:** X.Xx speedup (cumulative: Y.Yx over baseline)
**Performance:** [Key metric, e.g., time in seconds, throughput]
**Correctness:** PASS / FAIL (if fail, note that you reverted)
**Commit:** [short hash]
**Surprise:** [What was unexpected — MANDATORY]
**Notes:** [Observations, what to try next]
```

### 5.2 Thinking Journal Entry

Write **before** each implementation attempt (step 2: THINK). This is your pre-registration.

```markdown
### Before Iteration N
- **Current bottleneck hypothesis:** What I think is limiting performance and why
- **Options considered:** List 2-3 approaches with pros/cons
- **Chosen approach:** Which one and why
- **Prediction:** Expected speedup and reasoning (e.g., "~2x because we eliminate half the evaluations")
- **Risk:** What could go wrong or invalidate this approach
```

After the attempt, add a brief **postmortem** if the result diverged from prediction:

```markdown
### Postmortem — Iteration N
- **Predicted:** 2x speedup
- **Actual:** 0.9x (regression)
- **Why:** [Explanation of the discrepancy]
- **Lesson:** [What this teaches about the code]
```

---

## 6. Infrastructure Setup

### 6.1 Directory Structure

```
optim/
├── optimization_log.md     # What happened (structured results)
├── thinking_log.md         # Why it happened (deliberation & reasoning)
├── baseline.json           # Baseline metrics (generated once)
└── baseline_results/       # Baseline output files for comparison
```

### 6.2 Required Scripts

You need three scripts. These are project-specific but follow a common pattern:

**1. Baseline generator** (`scripts/run_baseline.py` or similar)
- Runs the code with fixed parameters and a fixed seed
- Saves timing breakdown, output metrics, and git commit hash
- Produces `optim/baseline.json` and copies key outputs to `optim/baseline_results/`
- Run once, never modify the baseline

**2. Benchmark runner** (`scripts/optim_benchmark.py` or similar)
- Runs the same workload as baseline with the same parameters
- Compares timing against `optim/baseline.json`
- Prints formatted comparison table with per-phase speedup
- Optionally accepts `--validate-full` for larger test cases

**Output format:**
```
Phase           Baseline    Current     Speedup
preparation      11.5s       11.2s      1.03x
processing      259.0s      124.0s      2.09x
aggregation      26.1s       25.8s      1.01x
TOTAL           320.8s      184.0s      1.74x
Correctness: PASS
```

**3. Correctness checker** (`scripts/optim_correctness.py` or similar)
- Compares a run's output against baseline
- Uses tolerances appropriate for the domain (Monte Carlo methods need loose tolerances)
- Returns PASS/FAIL verdict

**Tolerance guidance:**
- Deterministic outputs (best-fit values): tight tolerance (< 1%)
- Stochastic outputs (evidence integrals): loose tolerance (may vary 5-50%)
- Sample counts: very loose (may change with early-stopping)
- The key check: does the optimization produce **statistically equivalent** results?

### 6.3 Version Control

```bash
# Before starting optimization
cd <package_directory>
git tag pre-optimization     # Bookmark the starting point
git checkout -b optimization # All changes on a branch

# After each successful iteration
git add -A && git commit -m "optim iter N: [brief description]"

# After campaign complete
git checkout main && git merge optimization
git tag post-optimization
```

---

## 7. Profiling Techniques

### 7.1 Phase Timing (Start Here)

The simplest and most useful profiling: wrap each logical phase of your code with timing decorators.

```python
import time

phase_timings = {}

def timed_phase(name):
    """Decorator that records phase execution time."""
    def decorator(func):
        def wrapper(*args, **kwargs):
            t0 = time.time()
            result = func(*args, **kwargs)
            phase_timings[name] = time.time() - t0
            return result
        return wrapper
    return decorator
```

This immediately tells you which phase to attack. Don't optimize a phase that's 2% of runtime.

### 7.2 cProfile (When Phase Timing Isn't Enough)

```python
import cProfile
import pstats

profiler = cProfile.Profile()
profiler.enable()
# ... code to profile ...
profiler.disable()

stats = pstats.Stats(profiler)
stats.sort_stats('cumulative')
stats.print_stats(20)  # Top 20 functions
```

### 7.3 Line Profiling (For Hot Functions)

```bash
pip install line_profiler
kernprof -l -v your_script.py
```

---

## 8. Common Optimization Patterns

### 8.1 Early Stopping / Short-Circuiting

If a loop evaluates N candidates but only needs K (where K << N):
- **Check:** Is the loop already shuffled/randomized? If yes, taking the first K is unbiased.
- **Implementation:** Convert list comprehension to loop with counter, break after K accepted.
- **Typical speedup:** N/K (can be 10-100x for large N, small K)
- **Risk:** Must verify the selection isn't biased by ordering.

### 8.2 Caching / Memoization

If the same expensive computation is repeated:
- **Check:** Are inputs identical across calls? Use `functools.lru_cache` or manual dict cache.
- **Typical speedup:** Proportional to cache hit rate.
- **Risk:** Memory growth. Set cache size limits.

### 8.3 Algorithm Change

Sometimes the right move is a different algorithm, not micro-optimization:
- **Check:** Is the current algorithm O(n²) when O(n log n) exists?
- **Typical speedup:** Asymptotic improvement (unbounded).
- **Risk:** Higher implementation complexity, correctness harder to verify.

### 8.4 Parallelism

- **Check:** Are loop iterations independent?
- **Implementation:** `multiprocessing.Pool`, `concurrent.futures`, or SLURM array jobs.
- **Typical speedup:** ~cores used (with overhead).
- **Risk:** Thread safety, memory duplication, diminishing returns from overhead.

### 8.5 I/O Optimization

- **Check:** Is disk I/O the bottleneck? (Look at `iowait` in `top`)
- **Implementation:** Batch reads, memory-mapping, compressed formats (Feather, Parquet).
- **Typical speedup:** 2-10x for I/O-bound workloads.

---

## 9. Validation at Scale

Optimizations tested on small inputs may behave differently at full scale.

**Protocol:**
- **Every iteration:** Test on a fast case (minutes, not hours). Use fixed seed for reproducibility.
- **Every 3 iterations:** Run on a larger case (`--validate-full`) to confirm the optimization generalizes.
- **Before merging:** Run the full production workload once and compare against the pre-optimization tag.

**Why:** Early-stopping optimizations, for example, may show 10x on small inputs but only 2x at scale (or vice versa — the batch composition changes with scale).

---

## 10. Example Campaign Summary

This is what a completed optimization campaign looks like in the log:

```markdown
# Optimization Campaign: Phase 4 Extrinsic Sampling

## Baseline
- Total: 320.8s | Phase 4: 259.0s (81%) | Phase 5: 30.5s (9%)
- Commit: abc1234 (pre-optimization tag)

## Iteration 1: lnlike filter early-stopping
- Prediction: ~3x on Phase 4 (eliminate 80% of waveform evaluations)
- Result: 2.36x total speedup, Phase 4: 109.5s → 2.36x
- Surprise: Bigger than expected — batch ordering put expensive cases first
- Commit: def5678

## Iteration 2: QMC loop early-exit
- Prediction: ~1.1x additional
- Result: 1.05x additional (cumulative 2.48x)
- Surprise: None — small win as predicted
- Commit: ghi9012

## Iteration 3: [Attempted] Vectorized likelihood
- Prediction: ~1.5x on remaining Phase 4
- Result: FAIL (correctness check failed, reverted)
- Surprise: Vectorization changed floating-point ordering, broke determinism
- Commit: (reverted)

## Full-scale validation
- 32k survivors: Phase 4 = 431s vs 3429s original = 7.95x
- At scale, early-stopping is even more effective (more candidates to skip)

## Campaign result: 7.95x on Phase 4 at production scale
## Phase 5 now dominates (86% of total). New campaign needed for further gains.
```

---

## 11. Anti-Patterns

- **Optimizing without profiling.** You will optimize the wrong thing. Always measure first.
- **Skipping the THINK step.** Without a prediction, you can't learn from the result.
- **Committing without correctness check.** One broken commit poisons the whole campaign.
- **Testing only at small scale.** Optimizations that work on 100 items may fail at 100,000.
- **No Surprise field.** Without it, you're just recording numbers, not learning.
- **Optimizing a phase that's 2% of runtime.** Even a 10x speedup on 2% gives 1.02x total.
- **Giving up after one failure.** The recovery protocol exists for a reason. Try a different approach.
