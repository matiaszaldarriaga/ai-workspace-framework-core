# Ensure clean repository

Check git status, track all important files, commit changes, and ensure the repository is in a clean (porcelain) state.

**Workflow note (Option A)**: Prefer using this as an **iteration-boundary checkpoint** (e.g., at the start of `/iterate`, and before an end-of-iteration handoff), rather than repeatedly before every sub-step.

## Parameters
None - this command operates on the entire repository.

## Instructions

1. **Check git status** to identify:
   - Untracked files
   - Modified files
   - Deleted files
   - Uncommitted changes

2. **Review untracked files** and determine which are important:
   - Important files: source code, documentation, configuration files, rules, commands
   - Ignore: build artifacts, temporary files, IDE-specific files (unless they're part of the framework like `.cursor/`, `.agent/`, `.claude/`)
   - Check `.gitignore` to ensure proper exclusions

3. **Add all important files** to git:
   - Add untracked important files: `git add <files>`
   - Add modified files: `git add <files>`
   - Handle deleted files: `git add <deleted-files>` or `git rm <files>` as appropriate

4. **Commit all changes** with a descriptive message:
   - Use `git commit -m "<descriptive message>"` or `git commit` for interactive message
   - Include context about what was changed and why

5. **Verify clean state**:
   - Run `git status` to confirm repository is clean (no uncommitted changes)
   - Ensure no important files remain untracked
   - Repository should be in "porcelain" state (clean working tree)

6. **Handle edge cases**:
   - If there are merge conflicts, stop and report them
   - If there are files that should be ignored, update `.gitignore` first
   - If there are large binary files or sensitive data, ask before adding

## Important

- Do not commit sensitive information (API keys, passwords, personal data)
- Do not commit files that should be ignored (check `.gitignore`)
- Ensure commit messages are descriptive and meaningful
- The goal is a clean, committed state with all important work tracked
