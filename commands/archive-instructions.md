# Archive Instructions

Move completed or archived task instructions to the archive directory, keeping INSTRUCTIONS.md lean and focused on active/future work.

## Parameters
- `--dry-run` - Optional: show what would be archived without actually doing it
- `--force` - Optional: archive all COMPLETED/ARCHIVED tasks without confirmation

## Purpose

As tasks are completed, `control/INSTRUCTIONS.md` accumulates old sections. This command:
- Moves COMPLETED/ARCHIVED sections to dated archive files
- Keeps INSTRUCTIONS.md focused on ACTIVE and FUTURE tasks
- Preserves history without clutter
- Is called automatically by `/instruct` when starting new tasks

## Instructions

### 1. Read Current Instructions

1. Read `control/INSTRUCTIONS.md`
2. Parse sections (identified by `##` headers)
3. For each section, extract:
   - Section name (from `##` header)
   - STATUS field (look for `**STATUS:** [value]`)
   - Full section content (from `##` to next `##` or EOF)

### 2. Identify Sections to Archive

Look for sections with:
- `**STATUS:** COMPLETED`
- `**STATUS:** ARCHIVED`
- `**STATUS:** BLOCKED` (optionally include these - ask user if found)

**Do NOT archive:**
- `**STATUS:** ACTIVE`
- `**STATUS:** FUTURE`
- Sections without STATUS field (like intro/header)

### 3. Confirm Archival (Unless --force)

Present list to user:

```
Found sections to archive:

COMPLETED:
- Forensic Investigation (completed 2026-01-25)
- Cogwheel Test (completed 2026-01-27)
- Parameter Scan (completed 2026-01-29)

ARCHIVED:
- Forensic 2
- Cogwheel test 2

Total: 5 sections

Archive these sections? (y/n)
```

If `--force` flag: skip confirmation

If `--dry-run` flag: show list and exit without archiving

If BLOCKED sections found:
```
⚠️  Also found BLOCKED sections:
- Implementation Task (blocked 2026-02-01: Missing dependencies)

Include BLOCKED sections in archival? (y/n/ask-per-section)
```

### 4. Create Archive Directory

Ensure archive directory exists:

```bash
mkdir -p control/archive
```

### 5. Archive Each Section

For each section to archive:

#### 5.1. Generate Archive Filename

**Naming convention:** `YYYY-MM-DD_section-name.md`

1. Get current date: `date +%Y-%m-%d`
2. Extract section name from `##` header
3. Sanitize section name:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Remove special characters (keep alphanumeric and hyphens)
   - Truncate to 50 characters
4. Combine: `[date]_[sanitized-name].md`

Example:
- "Forensic Investigation" → `2026-02-03_forensic-investigation.md`
- "Cogwheel Test 2" → `2026-02-03_cogwheel-test-2.md`
- "TD→FD Conditioning Investigation" → `2026-02-03_td-fd-conditioning-investigation.md`

#### 5.2. Check for Existing Archive File

If archive file already exists with same name:
- Append counter: `2026-02-03_task-name-2.md`
- Increment until unique filename found

#### 5.3. Create Archive File

Create file: `control/archive/[filename].md`

**Archive file format:**

```markdown
# [Section Name]

**ARCHIVED:** YYYY-MM-DD
**ORIGINAL_STATUS:** [COMPLETED/ARCHIVED/BLOCKED]
**COMPLETED:** [completion date if available]
**CREATED:** [creation date if available]

---

[Full original section content, preserving all formatting]
```

Example archive file:

```markdown
# Forensic Investigation

**ARCHIVED:** 2026-02-03
**ORIGINAL_STATUS:** COMPLETED
**COMPLETED:** 2026-01-25
**CREATED:** 2026-01-25

---

## Forensic Investigation
**STATUS:** COMPLETED
**COMPLETED:** 2026-01-25
**CREATED:** 2026-01-25

**OBJECTIVE:** Understand how dot-PE computes waveforms...

[rest of section content]
```

#### 5.4. Write Archive File

Write the content to the archive file.

### 6. Update INSTRUCTIONS.md

**After all sections archived:**

1. Read current `control/INSTRUCTIONS.md`
2. Remove all archived sections
3. Keep:
   - Header/intro (any content before first `##` with STATUS)
   - ACTIVE sections
   - FUTURE sections
   - Any sections without STATUS (explanatory text)
4. Write updated content back to `control/INSTRUCTIONS.md`

**Preserve structure:**
- Keep the intro paragraph about updating PROJECT_SUMMARY.md
- Keep section ordering for remaining tasks
- Maintain proper markdown formatting

### 7. Report Results

Present summary to user:

```
✅ Archival complete

Archived 5 sections to control/archive/:
- control/archive/2026-02-03_forensic-investigation.md
- control/archive/2026-02-03_cogwheel-test.md
- control/archive/2026-02-03_parameter-scan.md
- control/archive/2026-02-03_forensic-2.md
- control/archive/2026-02-03_cogwheel-test-2.md

Remaining in INSTRUCTIONS.md:
- ACTIVE: 1 task
- FUTURE: 2 tasks

INSTRUCTIONS.md is now focused on current work.
```

### 8. Verify Operation

**Sanity checks after archival:**

1. Verify INSTRUCTIONS.md still exists and is valid
2. Verify all archive files were created successfully
3. Verify no ACTIVE or FUTURE tasks were accidentally archived
4. Count sections before/after to ensure correct number archived

If any issues detected:
```
⚠️  Warning: Sanity check failed
[describe issue]

Archive files created but INSTRUCTIONS.md not modified.
Please review and fix manually if needed.
```

### 9. Commit Changes (Optional)

Ask user:
```
Archive complete. Commit changes to git? (y/n)

Changes:
- Modified: control/INSTRUCTIONS.md
- Added: control/archive/[X files]
```

If yes:
```bash
git add control/INSTRUCTIONS.md control/archive/*.md
git commit -m "Archive completed instructions (X sections)

Archived:
- [section names]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Integration with Other Commands

This command is called automatically by `/instruct` when starting a new task, but can also be run standalone:

**Called by /instruct:**
- Automatic archival before creating new instruction
- No user confirmation needed (part of flow)

**Called standalone:**
- Manual cleanup operation
- User confirmation requested (unless --force)
- Useful for periodic maintenance

---

## Important

- **Preserve history**: Archive files contain complete original content
- **Never lose data**: Verify files written before removing from INSTRUCTIONS.md
- **Unique filenames**: Handle name collisions by appending counters
- **Keep context**: Archive files include metadata (dates, original status)
- **Idempotent**: Can be run multiple times safely
- **Focused INSTRUCTIONS.md**: Goal is to keep only ACTIVE and FUTURE tasks visible

---

## Example Usage

**Standard archival with confirmation:**
```
/archive-instructions
```

**Preview without archiving:**
```
/archive-instructions --dry-run
```

**Force archival without confirmation:**
```
/archive-instructions --force
```

**Called automatically:**
```
/instruct "New task"
→ Archives old tasks automatically before creating new instruction
```

---

## Error Cases

**No sections to archive:**
```
No completed or archived sections found in INSTRUCTIONS.md.

Current state:
- ACTIVE: 1 task
- FUTURE: 2 tasks
- COMPLETED/ARCHIVED: 0 tasks

Nothing to archive.
```

**Permission error:**
```
❌ Cannot create archive directory: Permission denied

Please check permissions for control/archive/
```

**Write error:**
```
❌ Failed to write archive file: control/archive/2026-02-03_task.md

[error details]

Archival aborted - INSTRUCTIONS.md not modified.
```

---

## Archive File Retrieval

**To find archived instructions:**

```bash
# List all archived instructions
ls -lt control/archive/

# Search for specific task
grep -r "task keyword" control/archive/

# View specific archive
cat control/archive/2026-01-25_forensic-investigation.md
```

**Archive files are:**
- Plain markdown (human-readable)
- Timestamped in filename (chronologically sortable)
- Complete (no information loss)
- Git-tracked (versioned and backed up)
