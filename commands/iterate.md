# Iterate (hands-off pipeline)

Run an end-to-end iteration with minimal human involvement after a `/discuss`, producing the key artifacts (plan → implementation/testing → plot-first interpretation → handoff).

This command is designed to let the agent run for a long time with the human out of the loop, while still documenting all decisions and evidence in files (not just chat).

## Parameters
- `{project_path}` - Optional absolute path to the target project under `projects/`. If omitted, infer from context or ask.
- `{plan_path}` - Optional path to an existing plan document. If omitted, create a new plan via `/req-imp-test-plan`.
- `{artifact_path}` - Optional path to the primary artifact directory to interpret (e.g., a `runs/...` or `explorations/...` directory). If omitted, infer after execution.
- `{status_goal}` - Optional: `COMPLETED` (default) or `IN_PROGRESS`. Use `IN_PROGRESS` if the work is expected to span multiple iterations.

## Instructions

### Suggested subagent delegation (Cursor Nightly)

If subagents are available (Cursor Nightly), delegate phases explicitly to reduce context churn and help the agent run longer unattended:
- **Planning**: `/planner` (produce the plan artifact)
- **Execution**: `/implementer` (implement + run tests + capture evidence)
- **Interpretation**: `/interpreter` (plot-first interpretation doc)
- **Verification** (optional but recommended): `/verifier` (skeptical validation pass; readonly)
- **Handoff**: `/handoff-writer` (write pointer-heavy `AGENT_REPORT_*` without duplicating plan/conclusions)

### 0) Inputs: make “chat” non-authoritative

1. Identify the target project:
   - Prefer `{project_path}` if provided.
   - Otherwise infer from context (recent work, open files) or ask if ambiguous.

2. Ensure the project has `docs/HUMAN_COMMENTS.md`:
   - If missing, create it as an empty stub and continue.
   - Treat it as the primary human-owned input channel for this iteration.

3. Read `docs/HUMAN_COMMENTS.md` (if present) and the most relevant `docs/` entry points:
   - `docs/INDEX.md`, `docs/QUESTIONS.md`, `docs/RESULTS.md` (if they exist).
   - Use this to constrain scope and interpret results later.

### 1) Iteration boundary checkpoint (Option A)

4. **Run `/ensure-clean-repo` exactly once at the start of the iteration.**
   - This is the iteration-boundary safety checkpoint.
   - After this point, do NOT re-run `/ensure-clean-repo` as a “mandatory first step” of sub-steps.

### 2) Planning

5. Produce or locate the plan:
   - If `{plan_path}` is provided: read it and proceed.
   - Otherwise: run `/req-imp-test-plan` to produce a new plan document.
   - The plan must include:
     - objectives + success criteria
     - testing requirements
     - frozen artifact constraints
     - explicit “decision logging” expectation (see next section).

6. Decision logging policy (critical for hands-off work):
   - During execution, whenever you must choose among plausible options, take the best guess and **document it** in the execution log (or a dedicated decisions doc) with:
     - decision, alternatives, why chosen, expected impact, how to validate quickly.

### 3) Execution

7. Execute the plan via `/execute-plan {plan_path}`.
   - Automate aggressively.
   - Create audit trails (logs, test outputs, generated artifacts).
   - Prefer producing figures/plots when diagnosing scientific/technical behavior (see `rules/AI-AGENT-CONTRACT.md`).

### 4) Interpret results (plot-first)

8. Determine `{artifact_path}` if it was not provided:
   - Prefer the most recent `runs/...` directory created/updated by execution.
   - Otherwise use the active exploration directory referenced by `docs/INDEX.md`.

9. Run `/interpret-results {artifact_path}`.
   - The output must be a dedicated, human-facing doc that argues from figures (not just scalars).

### 5) Handoff / end-of-iteration reporting

10. Create a handoff packet via `/create-handoff`:
   - Use `{status_goal}` if provided; otherwise infer status from completion against the plan.
   - The handoff should **reference** (not duplicate) the plan + execution logs + interpretation doc.
   - If using subagents, prefer delegating handoff writing to `/handoff-writer`.

## Important

- This command is intended to be invoked **after** a `/discuss` + (optional) human edits to `docs/HUMAN_COMMENTS.md`.
- **Option A invariant**: repo checkpoint at iteration boundary only (start of `/iterate`, and then as needed for an explicit handoff).
- Keep decisions and evidence in artifacts, not only in chat.

