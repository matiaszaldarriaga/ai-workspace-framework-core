# Identify Latest Handoff

Returns the path to the most recent handoff document in a directory, sorted by file modification time. This command provides a reliable way to find the latest handoff document regardless of filename dates.

## Parameters
- `{handoff_location}` - Optional directory path where handoff documents (`AGENT_REPORT_*.md`) are located. If not provided, searches the current working directory.

## Instructions

1. **Determine search location**:
   - If `{handoff_location}` is provided, use that directory.
   - If not provided, use the current working directory.
   - Verify the directory exists. If it doesn't exist, report an error and stop.

2. **Find all handoff documents**:
   - Search for all files matching `AGENT_REPORT_*.md` in the specified directory.
   - Use `find` or `ls` to locate files:
     - `find {handoff_location} -maxdepth 1 -name "AGENT_REPORT_*.md"`
     - Or: `ls {handoff_location}/AGENT_REPORT_*.md` (if directory is provided)
   - Do not search subdirectories (only the specified directory).

3. **Handle edge case - no files found**:
   - If no handoff documents are found, report this clearly:
     ```
     No handoff documents (AGENT_REPORT_*.md) found in: {handoff_location}
     ```
   - Stop execution (there is no latest handoff to return).

4. **Handle edge case - single file found**:
   - If only one handoff document is found, it is by definition the latest.
   - Display the file and its modification time.
   - Return the file path.

5. **Get modification times for all files**:
   - For each file found, get its modification time using:
     - **macOS (Darwin)**: `stat -f %m <file>` (returns Unix timestamp)
     - **Linux**: `stat -c %Y <file>` (returns Unix timestamp)
   - Detect the operating system first:
     - Run `uname -s` to determine OS
     - Use appropriate `stat` command based on OS
   - Store the file path and modification time for each file.

6. **Sort by modification time**:
   - Sort all files by modification time (newest first).
   - The file with the most recent modification time is the latest handoff document.
   - Use `sort -rn` to sort numerically in reverse order (newest first).

7. **Display results with validation**:
   - Display all handoff documents found, sorted by modification time (newest first).
   - For each file, show:
     - Filename
     - Full path
     - Modification time in human-readable format:
       - **macOS**: `date -r <timestamp>`
       - **Linux**: `date -d @<timestamp>`
     - Relative time (e.g., "2 hours ago") if possible
   - Clearly indicate which file is the latest (mark as "LATEST" or similar).
   - Example output format:
     ```
     Found 4 handoff documents in: explorations/ml-progressive-iob-v0/
     
     Sorted by modification time (newest first):
     1. AGENT_REPORT_2026-01-13_local-testing.md
        Path: explorations/ml-progressive-iob-v0/AGENT_REPORT_2026-01-13_local-testing.md
        Modification time: 2026-01-13 14:42:00 (2 hours ago)
        [LATEST]
     
     2. AGENT_REPORT_2026-01-13.md
        Path: explorations/ml-progressive-iob-v0/AGENT_REPORT_2026-01-13.md
        Modification time: 2026-01-13 14:21:00 (2 hours 21 minutes ago)
     
     3. AGENT_REPORT_2026-01-17.md
        Path: explorations/ml-progressive-iob-v0/AGENT_REPORT_2026-01-17.md
        Modification time: 2026-01-13 14:04:00 (2 hours 38 minutes ago)
     
     4. AGENT_REPORT_2026-01-16.md
        Path: explorations/ml-progressive-iob-v0/AGENT_REPORT_2026-01-16.md
        Modification time: 2026-01-13 12:26:00 (4 hours 16 minutes ago)
     
     Latest handoff document: explorations/ml-progressive-iob-v0/AGENT_REPORT_2026-01-13_local-testing.md
     ```

8. **Return the latest handoff path**:
   - Output the full path to the most recent handoff document.
   - This path should be used by calling commands (like `/go-to-next-phase`).
   - Make the path explicit and absolute if possible, or relative to workspace root.

9. **Handle errors gracefully**:
   - If directory doesn't exist: Report error clearly
   - If permission denied: Report error clearly
   - If `stat` command fails: Report error clearly
   - Always provide informative error messages

## Important

- **Always use file modification time, NEVER filename date** - filename dates may be incorrect or misleading
- **Modification time is the source of truth** for chronological ordering
- **Platform detection is critical** - use correct `stat` command for macOS vs Linux
- **Validation output is essential** - always display all files with modification times so agents can verify the selection
- **Edge cases must be handled** - no files, single file, invalid directory, permission errors
- **Output must be clear** - the latest file should be clearly marked and the path should be unambiguous

## Example Usage

```bash
# Search in specific directory
/identify-latest-handoff explorations/ml-progressive-iob-v0/

# Search in current directory (if parameter not provided)
/identify-latest-handoff
```

## Notes

- This command is designed to be called by `/go-to-next-phase` but can also be used standalone
- The validation output helps agents understand why a particular file was selected
- Modification time sorting ensures correct identification even when filename dates are wrong
- The command is read-only - it does not modify any files

--- End Command ---
