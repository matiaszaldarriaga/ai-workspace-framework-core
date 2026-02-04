# Complete Task

Verify that the active task meets all requirements, mark it as COMPLETED, and prepare for archival. This command enforces quality gates and ensures all deliverables are present before completion.

## Parameters
- `{task_name}` - Optional: specific task name to complete (if multiple ACTIVE tasks exist)
- `--skip-verification` - Optional: skip requirement verification (use with caution)
- `--mark-blocked` - Optional: mark task as BLOCKED instead of COMPLETED

## Workflow

This command is called after you've finished work and are ready to verify completion.

## Instructions

### 1. Identify Active Task

1. Read `control/INSTRUCTIONS.md`
2. Find section(s) with `**STATUS:** ACTIVE`
3. If multiple ACTIVE tasks exist:
   - If `{task_name}` parameter provided, use that task
   - Otherwise, ask user which task to complete
4. If no ACTIVE tasks exist:
   - Report: "No active tasks found in INSTRUCTIONS.md"
   - Exit

### 2. Verify Requirements (Unless --skip-verification)

Read the REQUIREMENTS section from the active task and `control/INSTRUCTION_REQUIREMENTS.md`.

For each requirement, verify and report status:

#### 2.1. Tests Written and Passing

**If tests are specified in DELIVERABLES:**

1. Identify test file path from deliverables
2. Check if test file exists:
   ```bash
   test -f path/to/test_file.py && echo "EXISTS" || echo "MISSING"
   ```
3. If exists, run the test suite:
   ```bash
   pytest path/to/test_file.py -v
   ```
4. Capture output and check for failures
5. Report:
   ```
   ✅ Tests: path/to/test_file.py
      - 22 tests passed
      - 0 tests failed
      [Show key test output]
   ```
   OR
   ```
   ❌ Tests: path/to/test_file.py
      - 18 tests passed
      - 4 tests failed
      [Show failure details]

   Cannot complete task - tests must pass.
   Fix failures and run /complete-task again.
   ```

**If test path not found in deliverables:**
- Check if tests were required for this task type
- If required but missing: ❌ Report missing tests
- If not required: ✅ Skip with note "Tests not applicable for this task"

#### 2.2. Notebook Updated and Runs

**If notebook is specified in DELIVERABLES:**

1. Identify notebook path from deliverables
2. Check if notebook exists:
   ```bash
   test -f path/to/notebook.ipynb && echo "EXISTS" || echo "MISSING"
   ```
3. If exists, attempt to run it end-to-end:
   ```bash
   jupyter nbconvert --to notebook --execute path/to/notebook.ipynb --output /tmp/test_notebook.ipynb 2>&1
   ```
4. Check for execution errors
5. Report:
   ```
   ✅ Notebook: path/to/notebook.ipynb
      - Executed successfully
      - All cells ran without errors
      - Outputs and figures generated
   ```
   OR
   ```
   ❌ Notebook: path/to/notebook.ipynb
      - Execution failed at cell X
      [Show error details]

   Cannot complete task - notebook must run end-to-end.
   Fix errors and run /complete-task again.
   ```

**If notebook path not found in deliverables:**
- Check `control/INSTRUCTION_REQUIREMENTS.md` to see if notebook is always required
- If required but missing: ❌ Report missing notebook
- If not required: ✅ Skip with note "Notebook not applicable for this task"

**Note:** For long-running notebooks, you may ask user:
```
The notebook may take several minutes to run. Should I:
A) Run it now and wait (verify end-to-end execution)
B) Skip notebook verification (trust that it works)
C) Run just the first N cells (quick sanity check)
```

#### 2.3. PROJECT_SUMMARY.md Updated

1. Check if `output/PROJECT_SUMMARY.md` is in deliverables
2. Read the file and check for recent updates:
   ```bash
   git log -1 --format="%ai" -- output/PROJECT_SUMMARY.md
   ```
3. Compare with task CREATED timestamp
4. Report:
   ```
   ✅ PROJECT_SUMMARY.md updated
      - Last modified: [timestamp]
      - After task creation
   ```
   OR
   ```
   ❌ PROJECT_SUMMARY.md not updated
      - Last modified: [timestamp]
      - Before task creation

   Please update PROJECT_SUMMARY.md with results.
   ```

#### 2.4. All Deliverables Present

Check each deliverable listed in the DELIVERABLES section:

1. Parse deliverable paths from instruction
2. For each deliverable:
   ```bash
   test -f path/to/deliverable && echo "EXISTS" || echo "MISSING"
   ```
3. Report:
   ```
   ✅ All deliverables present:
      - path/to/file1.py ✅
      - path/to/file2.py ✅
      - path/to/notebook.ipynb ✅
      - output/PROJECT_SUMMARY.md ✅
   ```
   OR
   ```
   ❌ Missing deliverables:
      - path/to/file2.py ❌

   Please create missing deliverables.
   ```

#### 2.5. Clean Git State

Check repository status:

```bash
git status --porcelain
```

Report:
```
✅ Git status: Clean
   - All changes committed
   - No untracked files (or only .gitignored files)
```
OR
```
⚠️  Git status: Uncommitted changes
   - X files modified
   - Y files untracked

Should I:
A) Commit changes with auto-generated message
B) Stop and let you commit manually
C) Complete anyway (skip clean state requirement)
```

#### 2.6. Check All Requirements Checklist

For each checkbox in the REQUIREMENTS section, verify and update:

- Replace `- [ ]` with `- [x]` for satisfied requirements
- Leave `- [ ]` for unsatisfied requirements

### 3. Verification Summary

Present a summary of all verification checks:

```
=== Task Completion Verification ===

Task: [Task Name]
Created: [timestamp]

Requirements:
✅ Tests passing (22/22 passed)
✅ Notebook runs end-to-end
✅ PROJECT_SUMMARY.md updated
✅ All deliverables present
✅ Git state clean

All requirements satisfied. Ready to complete.
```

OR if any requirements failed:

```
=== Task Completion Verification ===

Task: [Task Name]
Created: [timestamp]

Requirements:
✅ Tests passing (22/22 passed)
❌ Notebook has execution errors
✅ PROJECT_SUMMARY.md updated
⚠️  Git has uncommitted changes

Cannot complete task - 2 requirements unsatisfied.

Please:
1. Fix notebook execution errors
2. Commit changes or run with /complete-task and choose option

Run /complete-task again when ready.
```

### 4. Handle Verification Failures

**If any requirements are not satisfied:**

1. List what needs to be fixed
2. Provide specific guidance for each failure
3. Do NOT mark task as COMPLETED
4. Exit with instructions to fix and retry

**If user wants to override:**
- User can use `--skip-verification` flag
- Warn user: "⚠️  Skipping verification - task may be incomplete"
- Proceed to Step 5

### 5. Mark Task as COMPLETED

**If all requirements satisfied (or --skip-verification used):**

1. Get current timestamp: `date +"%Y-%m-%d %H:%M"`
2. Update the task in `control/INSTRUCTIONS.md`:
   - Change `**STATUS:** ACTIVE` to `**STATUS:** COMPLETED`
   - Add `**COMPLETED:** YYYY-MM-DD HH:MM` after the STATUS line
   - Update REQUIREMENTS checkboxes to all `[x]`

Example:
```markdown
## Implement NRSur7dq4 Support
**STATUS:** COMPLETED
**COMPLETED:** 2026-02-03 14:30
**CREATED:** 2026-02-03 10:00
```

3. Confirm to user:
   ```
   ✅ Task marked as COMPLETED: [Task Name]
   ```

### 6. Mark Task as BLOCKED (if --mark-blocked)

**If user wants to mark as BLOCKED instead:**

1. Ask for reason:
   ```
   Why is this task blocked? (Provide reason for next session)
   ```
2. Get current timestamp
3. Update task in `control/INSTRUCTIONS.md`:
   - Change `**STATUS:** ACTIVE` to `**STATUS:** BLOCKED`
   - Add `**BLOCKED:** YYYY-MM-DD HH:MM` after STATUS
   - Add `**BLOCKED_REASON:** [User's reason]`

Example:
```markdown
## Implement NRSur7dq4 Support
**STATUS:** BLOCKED
**BLOCKED:** 2026-02-03 14:30
**BLOCKED_REASON:** LAL function not available in current environment, need updated pycbc
**CREATED:** 2026-02-03 10:00
```

### 7. Create Handoff

**After marking as COMPLETED or BLOCKED:**

1. Use existing `/create-handoff` command:
   ```
   /create-handoff status=COMPLETED reason="Task completed: [Task Name]"
   ```
   OR
   ```
   /create-handoff status=BLOCKED reason="[Blocked reason]"
   ```

2. This will:
   - Ensure clean repo state
   - Create handoff document in `handoffs/`
   - Preserve all context for next session

### 8. Automatic Archival Note

**Do NOT archive immediately** - archival happens on next `/instruct` call.

Inform user:
```
✅ Task completed and handoff created.

The completed instruction will be automatically archived
when you start a new task with /instruct.

Current state:
- ACTIVE tasks: 0
- COMPLETED tasks: 1 (will be archived on next /instruct)
- FUTURE tasks: [count]

What would you like to do next?
```

### 9. Next Steps Suggestions

Suggest next actions to user:

```
Suggested next steps:
- Review handoff: handoffs/AGENT_REPORT_[timestamp].md
- Start new task: /instruct "Next task description"
- Review results in notebook: [path/to/notebook.ipynb]
- Check PROJECT_SUMMARY.md for updated status
```

---

## Important

- **Enforce quality gates**: Do not mark COMPLETED unless requirements satisfied
- **Run tests**: Actually execute tests, don't just check if files exist
- **Run notebook**: Verify end-to-end execution (with user permission for long notebooks)
- **Preserve evidence**: Show test outputs, error messages in verification report
- **Create handoff**: Always create handoff after completion
- **Don't archive immediately**: Archival happens on next `/instruct` call
- **Allow override**: `--skip-verification` available but warn user

## Example Usage

**Standard completion:**
```
/complete-task
```

**Skip verification (use with caution):**
```
/complete-task --skip-verification
```

**Mark as blocked:**
```
/complete-task --mark-blocked
```

**Complete specific task (if multiple active):**
```
/complete-task "Implement NRSur7dq4 Support"
```

---

## Error Cases

**No active tasks:**
```
❌ No active tasks found in control/INSTRUCTIONS.md

Nothing to complete. Use /instruct to start a new task.
```

**Requirements not satisfied:**
```
❌ Cannot complete task - 3 requirements unsatisfied:
   - Tests failing (4/22 failed)
   - Notebook execution error at cell 5
   - Git has uncommitted changes

Fix these issues and run /complete-task again.
```

**File not found:**
```
❌ Deliverable not found: path/to/expected/file.py

Please create this file or update DELIVERABLES section if path changed.
```
