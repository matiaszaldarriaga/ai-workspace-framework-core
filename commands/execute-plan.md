# Execute Plan

Implement a plan document (produced by `/req-imp-test-plan` or similar) automatically, following project rules and creating audit trails.

## Parameters
- `{plan_path}` - Path to the plan document to execute. If not provided, search for recent planning documents.

## Instructions

1. **Repo checkpointing (Option A)**:
   - If this execution step is part of a larger iteration pipeline (e.g., invoked via `/iterate`), assume the iteration boundary checkpoint has already been done and **do not** re-run `/ensure-clean-repo` here.
   - If you are running this command standalone (not under `/iterate`), run `/ensure-clean-repo` once before proceeding.

2. **Locate and read the plan document**:
   - If `{plan_path}` is provided, use that document.
   - Otherwise, search for recent planning documents (e.g., `IMPLEMENTATION_PLAN.md`, `REQUIREMENTS.md`, or similar in `docs/` directories).
   - Read the entire plan document carefully to understand:
     - Objectives and success criteria
     - Requirements (functional and non-functional)
     - Implementation plan phases
     - Testing requirements
     - Frozen artifact constraints
     - File structure and organization requirements

  - If present, also read `docs/HUMAN_COMMENTS.md` to capture any durable human constraints/intent that may not be in chat.

3. **Verify frozen constraints**:
   - Check the plan for explicit frozen artifact constraints.
   - If not clear, run `/verify-frozen-constraint` on the plan.
   - Ensure you understand which artifacts are FROZEN and must not be modified.
   - Frozen code can be copied, used, or called, but original files must remain unchanged.

4. **Determine working location**:
   - Identify the target project (if working within a project).
   - Determine if an active exploration exists (check `docs/INDEX.md`).
   - If no active exploration exists, create one using `/create-exploration` or work in an appropriate location.
   - Follow `rules/NORMS.md`: work in `explorations/` for active work, `src/` only when explicitly promoting.

5. **Execute implementation phases automatically**:
   - Work through each phase of the implementation plan systematically.
   - For each phase:
     - **Create required files and directories** following the plan's file structure
     - **Implement code** according to specifications
     - **Respect frozen artifacts**: never modify frozen code, explorations, or runs
     - **Create new artifacts** for any modifications or extensions (new files, new explorations)
     - **Document decisions** as you go (in exploration `log.md` or similar)
   
   - **Automate as much as possible**:
     - Write code files directly
     - Create configuration files
     - Set up test files
     - Create documentation stubs
     - Install dependencies if specified
     - Run setup commands if documented
   - **Remote campaigns and bundles**:
     - If the plan involves building or updating a **remote execution bundle** (e.g., `bundle/` trees or tarballs for clusters like Typhon/Elara):
       - derive vendored code from the project’s canonical library locations (typically `src/` or documented library dirs), **not** from `explorations/` or frozen `runs/`,
       - prefer using the project’s canonical bundle builder (e.g., `scripts/build_bundle.sh` or a documented Python entrypoint) instead of ad-hoc file copying,
       - treat existing bundles and frozen runs as downstream snapshots for provenance only, not as upstream templates for new campaigns.

6. **Implement testing requirements**:
   - Create test files according to the plan's testing requirements
   - Write unit tests, integration tests, and end-to-end tests as specified
   - Create test data if required
   - Run tests and capture results
   - Document test outcomes

7. **Create audit artifacts**:
   - **Execution log**: Create or update a log file (e.g., `explorations/<id>/log.md` or `runs/<run-id>/execution.log`) documenting:
     - Each phase executed
     - Files created/modified
     - Commands run
     - Test results
     - Any deviations from the plan and why
     - Decisions made during implementation
   
   - **Evidence artifacts**: Save:
     - Test outputs (verbatim where possible)
     - Build/compilation results
     - Diagnostic outputs
     - Any plots, logs, or generated artifacts
   
   - **Handoff packet** (if work is complete or being handed off):
     - **Get current timestamp**: Run `date +%Y-%m-%d_%H%M%S` to get current system time.
     - **DO NOT guess or assume the date** - always execute this command.
     - Create `AGENT_REPORT_<timestamp>.md` using the command output, following the structure in `rules/AI-AGENT-CONTRACT.md`:
       1. **Context In**: Input artifacts (the plan document and any other inputs) and their state
       2. **Actions**: Exact commands run and file operations performed
       3. **Evidence**: Test outputs, diagnostic results, pointers to artifacts
       4. **Context Out**: Created/modified artifacts and their paths
       5. **Next**: What remains to be done (if anything) or completion status

8. **Verify completion against plan**:
   - Check each objective against success criteria
   - Verify all requirements are met (or document any that cannot be met and why)
   - Confirm all implementation phases are complete
   - Verify testing requirements are satisfied
   - Document any scope changes or deviations

9. **Update project documentation**:
   - Update `docs/INDEX.md` to reference new artifacts if applicable
   - Update exploration `README.md` with current status
   - If work is being promoted to `src/`, follow promotion rules from `rules/NORMS.md`
   - Document any decisions in `docs/QUESTIONS.md` or appropriate decision log

10. **Follow project rules strictly**:
    - **Never modify frozen artifacts** - this is non-negotiable
    - Work in appropriate directories (`explorations/` for active work)
    - Follow file structure conventions from `rules/NORMS.md`
    - Adhere to `rules/AI-AGENT-CONTRACT.md` operating modes (default to Mode A - Working/execute)
    - Mark artifact state (ACTIVE/FROZEN) in documentation
    - Be explicit about assumptions and decisions

## Important

- **Option A**: Prefer repo checkpointing at iteration boundaries (e.g., `/iterate`). If running standalone, checkpoint once at the start.
- **Respect frozen artifacts** - this is critical for reproducibility and auditability
- **Automate aggressively** - try to implement as much as possible without asking for permission
- **Document everything** - create audit trails that allow reconstruction of all actions
- **Stop and ask** only when:
  - The plan is ambiguous and choices impact correctness
  - Frozen artifacts need to be modified (this should not happen - propose alternatives)
  - Critical decisions require user input
  - The plan appears incomplete or contradictory
- **Create evidence** - prefer concrete artifacts (code, tests, logs) over explanations
- **Follow phases sequentially** - don't jump ahead unless the plan explicitly allows it

## Example Execution Flow

1. `/ensure-clean-repo` → ensure clean state
2. Read plan document → understand objectives, requirements, phases
3. Verify frozen constraints → identify what cannot be modified
4. Determine working location → find/create exploration
5. Phase 1: Create file structure → implement code → document
6. Phase 2: Implement components → integrate → test
7. Phase 3: Write tests → run tests → capture results
8. Create execution log → document all actions
9. Create handoff packet → summarize work done
10. Verify completion → check against plan objectives
11. Update documentation → index new artifacts

--- End Command ---
