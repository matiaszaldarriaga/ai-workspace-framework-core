# Instruct

Manage task instructions with automatic archival, collaborative refinement, and smart amendment detection. This is the primary command for initiating new work or providing feedback on active tasks.

## Parameters
- `{instruction}` - The task description (for new tasks) or feedback/correction (for active tasks)
- `--plan` - Optional flag to enter plan mode after instruction creation
- `--force-new` - Optional flag to force creation of new instruction even if active task exists

## Workflow Overview

```
First use (no ACTIVE task):
  User: /instruct "Implement NRSur7dq4 support"
  → Full workflow: archive → discuss → refine → save → [optional: plan]

During execution (ACTIVE task exists):
  User: /instruct "Use q_range 1-8 instead of 1-4"
  → Smart detection: amendment (quick) or major change (clarify)
  → Update instruction, continue working

After completion:
  User: /complete-task
  → Verify requirements, mark COMPLETED, create handoff
```

## Instructions

### 1. Check for Active Task

Read `control/INSTRUCTIONS.md` and check for any section with `**STATUS:** ACTIVE`.

**If NO active task exists:**
- Proceed to Step 2 (Full Workflow - New Task)

**If ACTIVE task exists:**
- Proceed to Step 7 (Smart Detection - Amendment or Change)

---

### 2. Full Workflow - New Task (No Active Task Exists)

This workflow is for initiating a new task from scratch.

#### 2.1. Auto-Archive Completed Instructions

**Before creating new instruction:**

1. Read `control/INSTRUCTIONS.md`
2. Identify all sections with `**STATUS:** COMPLETED` or `**STATUS:** ARCHIVED`
3. If any exist, run `/archive-instructions` to move them to `control/archive/`
4. This keeps INSTRUCTIONS.md lean (only ACTIVE + FUTURE tasks)

#### 2.2. Enter Discussion Mode

**Gather context from the repository:**

1. Read relevant code files and documentation
2. Check `control/VISION.md` for project objectives
3. Check `control/CHANGELOG.md` for recent work
4. Check latest handoff in `handoffs/` for current state
5. Check `output/PROJECT_SUMMARY.md` for project status
6. Search codebase if needed to understand current state

**Collaborative refinement with user:**

1. **Understand the request:**
   - Parse the instruction carefully
   - Identify what needs to be achieved
   - Note any ambiguities

2. **Propose refined instruction:**
   - **OBJECTIVE**: Clear, specific goal
   - **SUCCESS CRITERIA**: Measurable outcomes (2-4 specific criteria)
   - **DELIVERABLES**: Specific artifacts with paths (code files, tests, notebooks, reports)
   - **ESTIMATED SCOPE**: Complexity level (Simple/Medium/Complex) and rough time estimate
   - **NOTES**: Context, constraints, preferences, dependencies

3. **Present to user:**
   ```
   Based on [context from repo], I propose:

   OBJECTIVE: [Clear goal]

   SUCCESS CRITERIA:
   - [Specific, measurable outcome 1]
   - [Specific, measurable outcome 2]
   - [etc.]

   DELIVERABLES:
   - [path/to/file.py] - Description
   - [path/to/test.py] - Description
   - [path/to/notebook.ipynb] - Description
   - [path/to/report.md] - Description

   ESTIMATED SCOPE: [Simple/Medium/Complex], [time estimate]

   NOTES:
   - [Important context]
   - [Constraints]
   - [Dependencies]

   Should I proceed with this instruction? Any changes?
   ```

4. **Iterate with user** until instruction is clear and agreed upon

#### 2.3. Create Instruction in INSTRUCTIONS.md

1. Read `control/INSTRUCTION_REQUIREMENTS.md` for default requirements
2. Get current timestamp: `date +"%Y-%m-%d %H:%M"`
3. Generate section name from objective (kebab-case, max 50 chars)
4. Append new section to `control/INSTRUCTIONS.md`:

```markdown
## [Task Name]
**STATUS:** ACTIVE
**CREATED:** YYYY-MM-DD HH:MM

**OBJECTIVE:**
[Clear, specific goal statement]

**SUCCESS CRITERIA:**
- [Specific, measurable outcome 1]
- [Specific, measurable outcome 2]
- [etc.]

**DELIVERABLES:**
- `path/to/file.py` - Description
- `path/to/test.py` - Test suite description
- `path/to/notebook.ipynb` - Validation notebook description
- `output/PROJECT_SUMMARY.md` - Updated project summary

**ESTIMATED SCOPE:** [Simple/Medium/Complex]

**NOTES:**
- [Context, constraints, preferences]
- [Dependencies or prerequisites]

**AMENDMENTS:**
*Quick corrections and refinements during execution*
(empty initially)

**REQUIREMENTS:**
*From INSTRUCTION_REQUIREMENTS.md - must be satisfied before /complete-task*
- [ ] All tests written and passing
- [ ] Notebook updated and runs end-to-end without errors
- [ ] PROJECT_SUMMARY.md updated with results
- [ ] Code committed with descriptive message
- [ ] Clean git state (no uncommitted changes)
```

5. Save the file
6. Confirm to user: "Instruction created: [Task Name] (STATUS: ACTIVE)"

#### 2.4. Optional: Enter Plan Mode

If `--plan` flag provided or task complexity is Medium/Complex:

1. Ask user: "This task is [complexity level]. Should I enter plan mode to design the implementation approach?"
2. If user agrees:
   - Use `/enter-plan-mode` command
   - Create detailed implementation plan
   - Get user approval
   - Exit plan mode
3. If user declines, proceed directly to execution

#### 2.5. Begin Execution

State: "Starting work on: [Task Name]"

Proceed to execute the instruction following the OBJECTIVE, SUCCESS CRITERIA, and DELIVERABLES.

---

### 3. Smart Detection - Amendment or Change (Active Task Exists)

This workflow is for providing feedback or corrections during task execution.

#### 3.1. Read User Input and Analyze

**Analyze the user's instruction `{instruction}`:**

1. Read the current ACTIVE task from `control/INSTRUCTIONS.md`
2. Determine the nature of the feedback:

**QUICK AMENDMENT indicators:**
- Short input (< 30 words)
- Specific/tactical language: "use X", "change Y", "fix Z", "add ...", "update ..."
- Single specific point
- Doesn't change core objective
- Examples:
  - "Use q_range 1-8 instead of 1-4"
  - "Test should verify early-time behavior too"
  - "Add mismatch heatmap to notebook"
  - "Skip tests for q>6, that's expected"

**MAJOR CHANGE indicators:**
- Longer input (> 50 words) or fundamental change
- Scope/approach change: "actually...", "instead", "different approach"
- Changes core objective or deliverables
- Multiple significant changes
- Examples:
  - "Actually this approach won't work, use LAL direct interface instead"
  - "Let's focus on aligned systems only, skip precessing"
  - "We need to restructure this to use a different architecture"

**AMBIGUOUS** (when unclear):
- Medium length (30-50 words)
- Could be interpreted either way
- Need to ask user for clarification

#### 3.2. Quick Amendment (Tactical Correction)

If input indicates **QUICK AMENDMENT**:

1. Get current timestamp: `date +"%Y-%m-%d %H:%M"`
2. Add amendment to the ACTIVE task's AMENDMENTS section in `control/INSTRUCTIONS.md`:

```markdown
**AMENDMENTS:**
*Quick corrections and refinements during execution*
- YYYY-MM-DD HH:MM - [User's feedback/correction]
```

3. Brief confirmation to user:
   ```
   Amendment added to active task: "[Task Name]"

   → [User's feedback]

   Continuing work with updated guidance...
   ```

4. **Immediately incorporate the amendment** into your ongoing work
5. Continue execution with the updated direction

#### 3.3. Major Change (Significant Scope/Approach Change)

If input indicates **MAJOR CHANGE**:

1. Present options to user:
   ```
   This looks like a significant change to the active task: "[Task Name]"

   Your feedback: "{instruction}"

   This could mean:

   A) Update current instruction (same task, pivot approach)
      → Modify OBJECTIVE/SUCCESS CRITERIA/DELIVERABLES
      → Continue with updated direction
      → Best if: Core goal is same, just different approach

   B) Complete current and start new instruction
      → Mark current as COMPLETED or BLOCKED
      → Create fresh instruction with new direction
      → Best if: This is fundamentally a different task

   C) Add as amendment and adapt
      → Add to AMENDMENTS, try to incorporate
      → Continue with original structure
      → Best if: Change is smaller than it seems

   Which option do you prefer? (A/B/C)
   ```

2. **Wait for user response**

3. Based on user's choice:

   **Option A - Update Current Instruction:**
   - Enter discussion mode (similar to Step 2.2)
   - Propose updated OBJECTIVE/SUCCESS CRITERIA/DELIVERABLES
   - Get user confirmation
   - Update the ACTIVE task in `control/INSTRUCTIONS.md`
   - Add note to AMENDMENTS: "YYYY-MM-DD HH:MM - Major update: [brief description]"
   - Continue execution with new direction

   **Option B - Complete and Start New:**
   - Mark current task STATUS as `COMPLETED` or `BLOCKED` with reason
   - Add note: "Superseded by new approach: [brief description]"
   - Start fresh instruction flow (go to Step 2)

   **Option C - Add as Amendment:**
   - Follow Quick Amendment flow (Step 3.2)
   - Add user's feedback to AMENDMENTS
   - Attempt to incorporate into current work

#### 3.4. Ambiguous Case (Ask for Clarification)

If input is **AMBIGUOUS**:

1. Present interpretation to user:
   ```
   I see you've provided feedback on the active task: "[Task Name]"

   Your feedback: "{instruction}"

   I'm not sure if this is:
   - A quick tactical correction (add to AMENDMENTS, continue)
   - A significant scope/approach change (update instruction structure)

   How would you like me to handle this?
   ```

2. Wait for user guidance, then follow appropriate flow

---

### 4. Force New Task (Override Active Task)

If `--force-new` flag is provided:

1. Check for ACTIVE task
2. If exists, ask user:
   ```
   There is currently an ACTIVE task: "[Task Name]"

   You've used --force-new. Should I:
   A) Mark current as COMPLETED and start new
   B) Mark current as BLOCKED/INTERRUPTED and start new
   C) Cancel and continue with current task
   ```

3. Based on user response:
   - A or B: Update current task STATUS, then proceed to Step 2 (Full Workflow)
   - C: Cancel operation

---

### 5. Integration with Other Commands

**After /instruct completes:**
- User continues to review/test
- User may call `/instruct` again for amendments (returns to Step 3)
- When satisfied, user calls `/complete-task` (separate command)

**Plan mode integration:**
- If `--plan` flag used or high complexity, offer to enter plan mode
- Use existing `/enter-plan-mode` command
- After plan approval, return to execution

---

## Important

- **Context-aware**: Behavior changes based on whether ACTIVE task exists
- **Smart detection**: Automatically categorizes feedback as amendment or major change
- **Collaborative**: Discussion mode ensures clear, well-defined instructions
- **Quality gates**: Built-in requirements ensure consistent deliverables
- **History preserved**: AMENDMENTS section shows evolution of task
- **One command**: Handles both new tasks and iterative refinement

## Example Usage

**Starting new task:**
```
/instruct "Implement NRSur7dq4 support in cogwheel"
```

**Quick correction during execution:**
```
/instruct "Use q_range 1-8 instead of 1-4"
```

**Significant change during execution:**
```
/instruct "Actually, let's use LAL direct interface instead of going through cogwheel"
```

**Force new task:**
```
/instruct --force-new "Different task entirely"
```

**With plan mode:**
```
/instruct --plan "Complex multi-file refactoring task"
```

---

## Notes

- Always read `control/INSTRUCTION_REQUIREMENTS.md` for default requirements
- AMENDMENTS section preserves iteration history
- Smart detection reduces user overhead (no need to specify amendment vs new)
- Integrates with `/complete-task` for quality verification
- Integrates with `/archive-instructions` for automatic cleanup
