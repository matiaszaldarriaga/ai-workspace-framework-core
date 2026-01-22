# Review artifact code

Perform a code review of all code files used in a specific artifact directory (exploration, run, archaeology, or any directory). Creates a comprehensive code review document that documents all code dependencies, files used, and key components so future agents don't need to re-investigate.

## Parameters
- `{artifact_path}` - Path to the directory to review (exploration, run, archaeology, or any directory)
  - Can be absolute path or relative to project root
  - Examples: `explorations/my-analysis/`, `runs/2024-01-15/`, `archaeology/salvaged/`, `custom-dir/`
- `{project_path}` - Optional. Base path if artifact_path is relative. If not provided, infers from artifact_path or uses current context.

## Instructions

1. **Resolve and validate artifact path**:
   - If `{artifact_path}` is absolute, use it directly
   - If `{artifact_path}` is relative and `{project_path}` is provided, resolve relative to project_path
   - If `{artifact_path}` is relative and no project_path, infer project root from artifact_path (look for parent directories containing `docs/`, `src/`, etc.)
   - Verify the path exists and is a directory
   - If path doesn't exist, stop and report error

2. **Detect artifact type and extract identifier**:
   - Parse artifact_path to detect type:
     - If path contains `/explorations/` → type: "exploration"
     - If path contains `/runs/` → type: "run"
     - If path contains `/archaeology/` → type: "archaeology"
     - If path contains `/src/` → type: "source"
     - Otherwise → type: "artifact" (generic)
   - Extract artifact identifier from directory name (last component of path)
   - Sanitize identifier for filename: convert to kebab-case, remove special characters
   - Example: `explorations/2026-01-13_analysis/` → identifier: `2026-01-13_analysis`, type: "exploration"

3. **Determine artifact state (ACTIVE/FROZEN)**:
   - Check if artifact is marked as FROZEN in any handoff packets or documentation
   - Check for explicit FROZEN markers in the artifact directory (e.g., `FROZEN` file, metadata)
   - If uncertain, default to ACTIVE
   - Document the state in the review

4. **Identify project root and docs directory**:
   - From artifact_path, find the project root (directory containing `docs/`, `src/`, etc.)
   - Verify `docs/` directory exists (create if needed, but this should be rare)
   - Create `docs/reviews/` subdirectory if it doesn't exist

5. **Inventory code files in artifact directory**:
   - Recursively scan the artifact directory for code files:
     - Common extensions: `.py`, `.js`, `.ts`, `.jsx`, `.tsx`, `.java`, `.cpp`, `.c`, `.go`, `.rs`, `.rb`, `.php`, `.r`, `.m`, `.sh`, `.bash`, `.zsh`, `.ipynb`, `.jl`, `.scala`, `.swift`, `.kt`
     - Include configuration files that contain code: `.json`, `.yaml`, `.yml`, `.toml`, `.ini`, `.conf`
     - Include build/script files: `Makefile`, `CMakeLists.txt`, `Dockerfile`, `docker-compose.yml`
   - For each code file found:
     - Record absolute path
     - Record relative path from artifact directory
     - Record file size and modification date
     - Identify file type/language

6. **Analyze code dependencies**:
   - For each code file, parse imports/includes/dependencies:
     - Python: `import`, `from ... import`
     - JavaScript/TypeScript: `import`, `require()`
     - Other languages: language-specific import/include patterns
   - Categorize dependencies:
     - **From `src/`**: Code imported from promoted/trusted source
     - **From other explorations/runs**: Code imported from other artifacts
     - **From same artifact**: Internal imports within the artifact
     - **External dependencies**: Third-party libraries/packages
   - List all unique dependencies with their locations

7. **Identify key components**:
   - Scan code files for:
     - Main entry points (files with `if __name__ == "__main__"`, `main()` functions, etc.)
     - Key functions/classes (exported, public APIs)
     - Configuration points (config files, environment variables used)
     - Data access points (file I/O, database connections, API calls)
   - Document each with file path and line numbers

8. **Perform code analysis**:
   - Review code structure and organization
   - Note any code quality observations (if applicable):
     - Code organization patterns
     - Potential issues or concerns
     - Notable design decisions
   - Identify patterns or conventions used
   - Note any dependencies on external resources

9. **Create code review document**:
   - Save to: `docs/reviews/{artifact-identifier}-{type}-code-review.md`
   - Use the following structure:

   ```markdown
   # Code Review: {artifact-identifier}

   **Date**: {current date and time}
   **Artifact Type**: {exploration|run|archaeology|source|artifact}
   **Artifact Path**: {absolute path to artifact directory}
   **Artifact State**: ACTIVE / FROZEN
   **Review Type**: Code Review

   ## Summary

   - **Total files reviewed**: {count}
   - **Code locations**: {breakdown of files in artifact vs imported from src/ vs external}
   - **Key dependencies identified**: {count}
   - **Artifact type**: {type}

   ## Code Inventory

   ### Files in Artifact Directory

   {For each code file found:}
   - `{relative_path}` ({file_type})
     - **Full path**: `{absolute_path}`
     - **Size**: {size}
     - **Modified**: {date}
     - **Purpose**: {brief description if apparent from filename/structure}

   ### Code Dependencies

   #### From `src/` (Promoted Code)
   {List all imports from src/ with paths}

   #### From Other Artifacts
   {List imports from other explorations/runs/archaeology with paths}

   #### Internal (Within Artifact)
   {List internal imports within the artifact}

   #### External Dependencies
   {List third-party libraries/packages used}

   ## Key Components

   ### Entry Points
   {List main entry points with file paths and line numbers}

   ### Key Functions/Classes
   {List important functions/classes with locations}

   ### Configuration Points
   {List config files, environment variables, command-line arguments}

   ### Data Access Points
   {List file I/O, database connections, API endpoints used}

   ## Code Analysis

   ### Structure and Organization
   {Observations about code organization, patterns, conventions}

   ### Quality Observations
   {Any code quality notes, potential issues, or concerns}

   ### Design Decisions
   {Notable architectural or design choices observed}

   ## References

   - Related documentation: {links to relevant docs}
   - Handoff packets: {if any reference this artifact}
   - Related artifacts: {other explorations/runs that might be related}
   - Project documentation: {links to project docs/INDEX.md, etc.}
   ```

10. **Respect frozen artifacts**:
    - If artifact is FROZEN:
      - Document that the artifact is FROZEN and immutable
      - State that this review is a snapshot documentation
      - Do NOT modify any files in the artifact directory
      - The review document itself is new documentation in `docs/reviews/`, not a modification of the frozen artifact
    - If artifact is ACTIVE:
      - Still create review in `docs/reviews/` (not inside artifact) for consistency
      - Document that artifact is ACTIVE and may be modified

11. **Update project documentation index**:
    - Read `docs/INDEX.md` (create if it doesn't exist)
    - Add entry for the new review document in appropriate section
    - If `docs/INDEX.md` has a "Reviews" or "Documentation" section, add there
    - Otherwise, add a new "Reviews" section
    - Format: `- [Code Review: {artifact-identifier}](reviews/{filename}) - {artifact-type} code review`

12. **Ensure completeness**:
    - Include all file paths (absolute and relative)
    - Include line numbers for key components
    - Reference specific code patterns with file locations
    - Make the document self-contained for future agents
    - Write clearly so a future agent reading this doesn't need to re-investigate

## Important

- **Location**: Review documents are ALWAYS saved in `docs/reviews/` regardless of artifact state (ACTIVE/FROZEN)
- **Frozen artifacts**: Never modify frozen artifacts. The review document is new documentation that references frozen artifacts without changing them.
- **Completeness**: The review should be comprehensive enough that future agents don't need to re-investigate code dependencies
- **Evidence-based**: Include specific file paths, line numbers, and code references
- **Self-contained**: Document should stand alone without requiring access to the review session
- **Update INDEX**: Always update `docs/INDEX.md` to make the review discoverable
- **Artifact type detection**: Automatically detects type from path, but works for any directory structure
- **Flexibility**: Works for explorations, runs, archaeology, src/, or any custom directory

--- End Command ---
