# Go to Next Phase

Continue work from a handoff document, following the original plan and incorporating lessons from all previous handoff documents. Designed for fresh agent instances.

## Parameters
- `{handoff_location}` - Directory path where handoff documents (`AGENT_REPORT_*.md`) are located, or path to a specific handoff document.

## Instructions

1. **Repo checkpointing (Option A)**:
   - If this continuation step is part of a larger iteration pipeline (e.g., invoked via `/iterate`), assume the iteration boundary checkpoint has already been done and **do not** re-run `/ensure-clean-repo` here.
   - If you are running this command standalone (fresh continuation outside `/iterate`), run `/ensure-clean-repo` once before proceeding.

2. **Locate handoff documents**:
   - If `{handoff_location}` is a file path ending in `AGENT_REPORT_*.md`, use that specific document and skip to step 3.
   - If `{handoff_location}` is a directory (or not provided), proceed with identification:
     - **MANDATORY STEP**: Execute `/identify-latest-handoff {handoff_location}` to find the latest handoff document.
     - **MANDATORY STEP**: Review the output to verify which file was identified as latest.
     - **MANDATORY STEP**: Note the modification time and all other handoff documents found.
     - The output will show all handoff documents sorted by modification time (newest first).
     - Use the file identified as "Latest handoff document" as your starting point.
   - Also note all other handoff documents found - you will read them for context in step 4.

3. **Identify the latest handoff document**:
   - The latest handoff document was identified in step 2:
     - If a direct file path was provided, that file is the latest handoff document.
     - If a directory was provided, the latest handoff document was identified via `/identify-latest-handoff`.
   - **VERIFICATION STEP**: Confirm you have the correct file by checking:
     - The file path matches the output from `/identify-latest-handoff` (if directory was provided)
     - The modification time shown is the most recent (if validation output was displayed)
     - You understand why this file is the latest (modification time, not filename date)
   - This is your starting point for continuation.
   - Read this document completely to understand:
     - Current state (Context Out)
     - Status (IN_PROGRESS, INTERRUPTED, BLOCKED, or COMPLETED) and reason for handoff
     - What was done (Actions)
     - What needs to be done next (Next section)
     - Evidence of what worked or didn't work
     - Any blockers or issues that need to be addressed

4. **Read all handoff documents for context**:
   - Read all handoff documents in chronological order to understand:
     - The progression of work across phases
     - Lessons learned (what worked, what didn't, what was changed)
     - Patterns of decisions made
     - Any recurring issues or adjustments
     - Evolution of understanding or approach
   - Extract key lessons and incorporate them into your approach.

5. **Locate and read the original plan**:
   - From the handoff documents, identify the original plan document path (usually in "Context In" section).
   - Read the complete plan document to understand:
     - Original objectives and success criteria
     - Requirements (functional and non-functional)
     - Implementation phases
     - Testing requirements
     - Frozen artifact constraints
   - Compare the plan with what has been done so far to understand progress.

6. **Understand current state**:
   - From the latest handoff document's "Context Out" section, identify:
     - All artifacts that were created or modified
     - Their current state (ACTIVE/FROZEN)
     - Their locations
   - Verify these artifacts exist and understand their current state.
   - Check the "Evidence" section to understand what was tested and validated.

7. **Determine next phase work**:
   - Read the "Next" section of the latest handoff document carefully.
   - This specifies what the next agent should do.
   - **Check the status and reason**:
     - If status is `INTERRUPTED` or `BLOCKED`, pay special attention to the reason and blockers section
     - If status is `IN_PROGRESS`, continue from where work left off
     - If status is `COMPLETED`, verify completion and proceed to next phase per plan
   - Cross-reference with the original plan to understand:
     - Which phase of the plan this corresponds to
     - What the overall goal is
     - What success looks like for this phase
   - Incorporate lessons from previous handoff documents:
     - If previous phases encountered issues, adjust approach accordingly
     - If certain patterns worked well, continue them
     - If constraints were discovered, respect them
   - **Address any blockers** mentioned in the handoff document before proceeding

8. **Execute the next phase**:
   - Follow the "Next" section instructions from the latest handoff.
   - Work systematically through the tasks.
   - **Respect frozen artifacts** - never modify anything marked FROZEN.
   - **Check for directory existence**: Before assuming directories exist (like `explorations/`), check if they exist. Create on-demand if needed for workspace-specific directories.
   - Create new artifacts as needed (don't modify existing ones unless they're ACTIVE and the plan/handoff explicitly allows it).
   - Document decisions and rationale as you work.
   - Run tests and capture evidence.

9. **Create new handoff document**:
   - **Get current timestamp**: Run `date +%Y-%m-%d_%H%M%S` to get current system time.
   - **DO NOT guess or assume the date** - always execute this command.
   - Use the command output as the timestamp in the filename.
   - Create a new `AGENT_REPORT_<timestamp>.md` file in the same location as previous handoff documents.
   - Example: `date +%Y-%m-%d_%H%M%S` outputs `2026-01-13_144221` → filename: `AGENT_REPORT_2026-01-13_144221.md`
   - Follow the structure from `rules/AI-AGENT-CONTRACT.md`:
     
     ### Context In
     - List the handoff document(s) you started from (with paths and state)
     - List the original plan document (with path and state)
     - List any other input artifacts you used (with paths and state ACTIVE/FROZEN)
     - Reference previous handoff documents and key lessons incorporated
     
     ### Actions
     - Exact commands run
     - Exact file operations performed
     - What phase/tasks were completed
     - Any deviations from the "Next" section and why
     - Decisions made and rationale
     
     ### Evidence
     - Verbatim test outputs
     - Diagnostic results
     - Pointers to plots, logs, artifacts
     - Validation results
     
     ### Context Out
     - Explicit list of all created/modified artifacts (with full paths)
     - Artifact state (ACTIVE/FROZEN) for each
     - Current status of work
     
     ### Next
     - What the next agent should do (single next task if possible, or clear list of next steps)
     - Reference to which phase of the plan this corresponds to
     - Any prerequisites or setup needed
     - Expected outcomes or success criteria for the next phase
   
   - Include a **Lessons Learned** section (optional but recommended):
     - What worked well in this phase
     - What didn't work or was challenging
     - Adjustments made to approach
     - Insights for future phases

10. **Verify against plan**:
    - Check progress against original plan objectives.
    - Verify which phases are complete and which remain.
    - Document any scope changes or plan adjustments needed.
    - Update status in the handoff document.

11. **Follow project rules**:
    - Adhere to `rules/NORMS.md`:
      - Work in appropriate directories (`explorations/` for active work)
      - Follow file structure conventions
      - Never modify frozen artifacts
    - Adhere to `rules/AI-AGENT-CONTRACT.md`:
      - Operate in Mode A (Working/execute) unless specified otherwise
      - Be explicit about assumptions
      - Provide evidence-based work
      - Mark artifact state clearly

## Important

- **The `/ensure-clean-repo` step is mandatory** - never skip this step
- **Read all handoff documents** - don't just read the latest one; understand the full progression
- **Incorporate lessons** - use insights from previous phases to improve your approach
- **Respect frozen artifacts** - this is critical and non-negotiable
- **Follow the "Next" section** - it's the bridge between phases, but also use judgment if the plan suggests different priorities
- **Create complete handoff documents** - the next agent should be able to continue seamlessly
- **Document lessons learned** - help future phases benefit from your experience
- **Be explicit about state** - clearly mark what is ACTIVE vs FROZEN
- **This command is designed for fresh agent instances** - assume no prior conversation context

## Example Workflow

1. `/ensure-clean-repo` → ensure clean state
2. Locate handoff directory → execute `/identify-latest-handoff explorations/ml-progressive-iob-v0/` to find most recent by modification time
3. Identify latest → use output from `/identify-latest-handoff` as the latest handoff document
4. Read all handoffs → understand progression: Phase 1 → Phase 2 → Phase 3
5. Read original plan → `docs/IMPLEMENTATION_PLAN.md`
6. Understand current state → Phase 2 complete, artifacts in `explorations/phase2/`
7. Determine next work → "Next" section says "Run integration tests and validate results"
8. Execute phase → run tests, validate, document results
9. Create new handoff → run `date +%Y-%m-%d_%H%M%S`, create `AGENT_REPORT_<output>.md` with complete context
10. Verify progress → Phase 3 complete, Phase 4 next per plan

--- End Command ---
