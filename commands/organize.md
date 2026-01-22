# Organize project structure

Analyze a project or repository's file structure, identify misplaced files, and propose organizational improvements. Do NOT execute changes without user approval.

## Parameters
- `{project_path}` - Optional: path to the project/repository to organize. If not specified, analyze the current working directory.

## Instructions

1. **Analyze current structure**:
   - Identify the project root (may be a project under `projects/` or any repository)
   - Map the current file structure
   - Identify the project type and expected structure (check for `docs/`, `src/`, `explorations/`, etc.)

2. **Identify misplaced files**:
   - Find floating `.md` files in the root or wrong directories
   - Find log files (`.log`, `.txt` logs) that should be in `runs/` or `explorations/`
   - Find temporary files that should be cleaned up
   - Find files in wrong locations according to the workspace structure (see `rules/NORMS.md`)

3. **Check against expected structure**:
   - Verify required directory exists: `docs/` (only required directory)
   - Check for optional directories: `explorations/`, `archaeology/`, `runs/`, `src/` (may not exist for Minimal or legacy projects)
   - Adapt expectations based on project type:
     - Science projects: May have all 5 directories
     - Minimal projects: Only `docs/` required
     - Legacy projects: May have different structure
   - Check if files are in appropriate locations:
     - Documentation → `docs/`
     - Active work → `explorations/` (if it exists)
     - Archived work → `archaeology/` (if it exists)
     - Executions/logs → `runs/` (if it exists)
     - Promoted code → `src/` (if it exists)

4. **Propose improvements**:
   - List all misplaced files and where they should go
   - If the structure can be significantly improved, propose a reorganization plan
   - Explain the rationale for each proposed change
   - Group related changes together

5. **Present proposal to user**:
   - Show a clear summary of:
     - Files to move (from → to)
     - Files to delete (if temporary/unnecessary)
     - New directories to create (if needed)
     - Structural improvements (if significant)
   - Ask for explicit approval before making any changes
   - Wait for user confirmation before executing

6. **After approval** (if given):
   - Create any missing directories as needed (only create workspace-specific directories like `explorations/`, `runs/`, `archaeology/` if files need to be moved there)
   - Move files to their proper locations
   - Update any references/links that break due to moves
   - Clean up temporary files (if approved)
   - Verify the final structure
   - Note: Only `docs/` is required; other directories are optional and should only be created if needed

## Important

- **DO NOT execute any file moves or deletions without explicit user approval**
- Always explain the rationale for proposed changes
- Preserve file history when possible (use `git mv` if in a git repository)
- Check for broken references after moves
- Respect the workspace structure defined in `rules/NORMS.md`
- If working in a project under `projects/`, respect that project's own structure rules

## Example Output Format

```
## Structure Analysis

Current issues found:
- 3 .md files in root that should be in docs/
- 2 log files that should be in runs/
- 1 exploration notebook in wrong location

## Proposed Changes

1. Move files:
   - README-notes.md → docs/notes.md
   - session.log → runs/logs/session.log
   - analysis.ipynb → explorations/2024-01-analysis/

2. Create missing directories:
   - runs/logs/

3. Delete temporary files:
   - temp_scratch.txt

Do you approve these changes? (yes/no)

```
