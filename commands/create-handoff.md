# Create Handoff

Create a handoff document to preserve current work state, even if incomplete. Use when context window is full, agent is stuck, or work needs to be paused for continuation.

## Parameters
- `{handoff_location}` - Optional directory path where the handoff document should be created. If not provided, use the current working directory or exploration directory.
- `{status}` - Optional status indicator: `IN_PROGRESS`, `INTERRUPTED`, `BLOCKED`, or `COMPLETED`. Defaults to `IN_PROGRESS` if not specified.
- `{reason}` - Optional reason for creating the handoff (e.g., "Context window full", "Agent stuck on X", "User requested pause"). If not provided, infer from context.

## Instructions

1. **Always start with `/ensure-clean-repo`**:
   - Execute the `/ensure-clean-repo` command first to ensure all work is committed and nothing is lost if catastrophic mistakes occur.
   - This is a mandatory first step before creating the handoff document.

2. **Determine handoff location**:
   - If `{handoff_location}` is provided, use that directory.
   - Otherwise, determine the appropriate location:
     - If working in a project exploration, use the exploration directory
     - If working in a project, use the project root or `docs/` directory
     - If workspace-level, use an appropriate workspace location
   - Ensure the directory exists or create it if needed.

3. **Identify current work context**:
   - **Locate the original plan** (if working from a plan):
     - Check for plan documents (e.g., `IMPLEMENTATION_PLAN.md`, `REQUIREMENTS.md`) in `docs/` or current directory
     - Note the plan path and its state (ACTIVE/FROZEN)
   
   - **Identify input artifacts**:
     - List all artifacts that were used as inputs (code files, data, configurations)
     - Note their paths and state (ACTIVE/FROZEN)
     - Include any previous handoff documents if continuing from one
   
   - **Identify current working location**:
     - Note the exploration, project, or workspace path
     - Document the current phase or task being worked on

4. **Document what has been done (Actions)**:
   - **List all files created or modified**:
     - Exact file paths
     - Brief description of what was done to each
     - Whether files are complete or in-progress
   
   - **List all commands run**:
     - Exact commands executed
     - Their purpose and outcomes
     - Any errors encountered (even if partial)
   
   - **Document current phase/task**:
     - What phase of the plan is being worked on (if applicable)
     - What specific task was in progress
     - How far along the task is (complete, partial, just started)

5. **Gather evidence**:
   - **Test outputs** (if any tests were run):
     - Verbatim test results
     - Pass/fail status
     - Any error messages or warnings
   
   - **Diagnostic information**:
     - Error messages encountered
     - Warnings or issues discovered
     - Partial results or outputs
   
   - **Artifact pointers**:
     - Paths to logs, plots, or other generated artifacts
     - Any intermediate files created
     - Configuration files or state files

6. **Document current state (Context Out)**:
   - **List all created/modified artifacts**:
     - Full paths to all files created or modified
     - Current state of each (ACTIVE/FROZEN)
     - Whether each is complete or in-progress
   
   - **Note any partial work**:
     - Files that are partially written
     - Tests that are partially implemented
     - Documentation that is incomplete
     - Clearly mark what is done vs. what is incomplete

7. **Determine status and reason**:
   - **Set status**:
     - Use `{status}` parameter if provided
     - Otherwise, determine from context:
       - `IN_PROGRESS`: Work ongoing, handoff for continuation
       - `INTERRUPTED`: Work stopped due to context window, technical issues, or user request
       - `BLOCKED`: Work stopped due to missing information, dependencies, or blockers
       - `COMPLETED`: Phase/work is complete (use this if work is actually done)
   
   - **Document reason**:
     - Use `{reason}` parameter if provided
     - Otherwise, infer from context:
       - "Context window approaching limit"
       - "Agent stuck on [specific issue]"
       - "User requested pause"
       - "Blocked on [dependency/information]"
       - "Phase complete, ready for next phase"

8. **Define next steps**:
   - **What needs to be done next**:
     - Specific next task or phase
     - What should be continued or retried
     - Any prerequisites or setup needed
   
   - **Address blockers** (if status is BLOCKED or INTERRUPTED):
     - What was blocking progress
     - What information is needed
     - Suggested approach for the next agent
   
   - **Reference plan** (if applicable):
     - Which phase of the plan this corresponds to
     - What the plan says should happen next
     - Any deviations from the plan and why

9. **Create the handoff document**:
   - **Get current timestamp**: Run `date +%Y-%m-%d_%H%M%S` to get current system time.
   - **DO NOT guess or assume the date** - always execute this command.
   - Use the command output as the timestamp in the filename.
   - Create `AGENT_REPORT_<timestamp>.md` in the determined location using the command output.
   - Format: `AGENT_REPORT_YYYY-MM-DD_HHMMSS.md` (preferred) or `AGENT_REPORT_YYYY-MM-DD.md` if date-only needed.
   - Example: `date +%Y-%m-%d_%H%M%S` outputs `2026-01-13_144221` → filename: `AGENT_REPORT_2026-01-13_144221.md`
   - Note: The timestamp in the filename is for human readability only - chronological sorting must always use file modification time.
   - Follow the structure from `rules/AI-AGENT-CONTRACT.md`:
     
     ```markdown
     # Agent Report: [Brief Description]
     
     **Date**: YYYY-MM-DD
     **Agent**: [Agent name/type]
     **Status**: IN_PROGRESS | INTERRUPTED | BLOCKED | COMPLETED
     **Reason**: [Why this handoff is being created]
     **Mode**: [Operating mode: Mode A/B/C]
     
     ## Context In
     
     ### Input Artifacts
     - [List with paths and state ACTIVE/FROZEN]
     
     ### Plan Document (if applicable)
     - [Path to plan and state]
     
     ## Actions
     
     ### Files Created/Modified
     - [List with descriptions]
     
     ### Commands Run
     - [List exact commands]
     
     ### Current Phase/Task
     - [What was being worked on]
     
     ## Evidence
     
     ### Test Results (if any)
     - [Verbatim outputs]
     
     ### Diagnostics
     - [Error messages, warnings, issues]
     
     ### Artifacts
     - [Pointers to logs, plots, etc.]
     
     ## Context Out
     
     ### Created/Modified Artifacts
     - [List with full paths and state]
     
     ### Partial Work
     - [What is incomplete and needs continuation]
     
     ### Artifact State
     - **Status**: ACTIVE
     - **Location**: [Working directory]
     - **Frozen Artifacts**: [List any that are FROZEN]
     
     ## Next
     
     ### Immediate Next Steps
     - [What the next agent should do]
     
     ### Blockers/Issues (if applicable)
     - [What needs to be resolved]
     
     ### Prerequisites
     - [What setup or information is needed]
     ```
   
   - **Include lessons learned** (if applicable):
     - What worked well
     - What didn't work or was challenging
     - Insights for continuation
     - Patterns or approaches to continue or avoid

10. **Create ready task file** (if working in a project):
   - **Determine if in a project**:
     - If handoff location is within `projects/{project_name}/`, extract project name
     - If not in a project directory (workspace-level), skip this step
   
   - **Determine task status**:
     - If status is `IN_PROGRESS` or `COMPLETED`: Task is ready for agent (STATUS: READY)
     - If status is `BLOCKED` or `INTERRUPTED`: Task requires human intervention (STATUS: HUMAN_INTERVENTION)
   
   - **Create `.ready/READY/` directory** (if needed):
     - Create `projects/{project_name}/.ready/` if it doesn't exist
     - Create `projects/{project_name}/.ready/READY/` if it doesn't exist
   
   - **Generate task filename**:
     - Use same timestamp as handoff document
     - Extract source path from handoff location (relative to project root)
     - Format: `TASK_YYYYMMDD_HHMMSS_{source_path_sanitized}.md`
     - Sanitize source path: replace `/` with `_`, remove leading/trailing underscores
     - Example: handoff in `explorations/ml-progressive-iob-v0/` → `TASK_20260114_121402_explorations_ml-progressive-iob-v0.md`
   
   - **Create task file**:
     - Create file: `projects/{project_name}/.ready/READY/{task_filename}`
     - Format:
       ```markdown
       STATUS: READY|HUMAN_INTERVENTION
       SOURCE: {relative_path_from_project_root}
       HANDOFF: {handoff_filename}
       CREATED: {ISO8601_timestamp}
       
       PROMPT:
       /go-to-next-phase {handoff_location}
       
       OR if HUMAN_INTERVENTION:
       
       HUMAN_INTERVENTION:
       {Reason for handoff from step 7}
       ```
     - If STATUS is READY: Include PROMPT section with `/go-to-next-phase {handoff_location}` command
     - If STATUS is HUMAN_INTERVENTION: Include HUMAN_INTERVENTION section with reason for handoff
   
   - **Get current timestamp**:
     - Run `date -u +%Y-%m-%dT%H:%M:%SZ` to get ISO8601 timestamp
     - Use for CREATED field
   
   - **Determine source path**:
     - Calculate relative path from project root to handoff location
     - Example: If project is `gw231123-spin` and handoff is in `explorations/ml-progressive-iob-v0/`, source is `explorations/ml-progressive-iob-v0/`
     - If handoff is at project root, source is `.` or empty
   
   - **Note**: Task files are created in project-level `.ready/READY/` directory, allowing any agent in the project to discover and claim them

11. **Update project documentation** (if applicable):
    - Update `docs/INDEX.md` to reference the new handoff document
    - Update exploration `README.md` or `log.md` with current status
    - Note the handoff in any relevant documentation

12. **Follow project rules**:
    - Adhere to `rules/NORMS.md`:
      - Place handoff in appropriate location
      - Follow file structure conventions
      - Never modify frozen artifacts
    - Adhere to `rules/AI-AGENT-CONTRACT.md`:
      - Use the required handoff packet structure
      - Be explicit about artifact state (ACTIVE/FROZEN)
      - Provide sufficient context for continuation
      - Mark packets as immutable once written

## Important

- **The `/ensure-clean-repo` step is mandatory** - never skip this step
- **Document everything** - even partial work and failed attempts are valuable context
- **Be explicit about status** - clearly indicate if work is incomplete and why
- **Preserve state accurately** - the next agent must be able to continue seamlessly
- **Include blockers** - if stuck, document what was blocking and suggested approaches
- **Reference the plan** - if working from a plan, clearly indicate progress against it
- **Mark artifact state** - always indicate ACTIVE/FROZEN for all artifacts
- **Handoff documents are immutable** - once created, they should not be modified

## Example Usage

**Context window full:**
```
/create-handoff status=INTERRUPTED reason="Context window approaching limit"
```

**Agent stuck:**
```
/create-handoff status=BLOCKED reason="Unable to resolve dependency conflict in package X"
```

**Phase complete:**
```
/create-handoff status=COMPLETED reason="Phase 2 implementation complete, ready for testing phase"
```

**User requested pause:**
```
/create-handoff status=IN_PROGRESS reason="User requested pause for review"
```

--- End Command ---
