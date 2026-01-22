# Review artifact data

Perform a data and input review of a specific artifact directory (exploration, run, archaeology, or any directory). Creates a comprehensive data review document that documents all data sources, input files, configurations, and data dependencies so future agents know exactly where all data and inputs reside.

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
   - Example: `runs/2024-01-15_experiment/` → identifier: `2024-01-15_experiment`, type: "run"

3. **Determine artifact state (ACTIVE/FROZEN)**:
   - Check if artifact is marked as FROZEN in any handoff packets or documentation
   - Check for explicit FROZEN markers in the artifact directory (e.g., `FROZEN` file, metadata)
   - If uncertain, default to ACTIVE
   - Document the state in the review

4. **Identify project root and docs directory**:
   - From artifact_path, find the project root (directory containing `docs/`, `src/`, etc.)
   - Verify `docs/` directory exists (create if needed, but this should be rare)
   - Create `docs/reviews/` subdirectory if it doesn't exist

5. **Inventory data files in artifact directory**:
   - Recursively scan the artifact directory for data files:
     - Common data formats: `.csv`, `.tsv`, `.json`, `.xml`, `.yaml`, `.yml`, `.parquet`, `.h5`, `.hdf5`, `.feather`, `.pkl`, `.pickle`, `.npy`, `.npz`, `.mat`, `.xlsx`, `.xls`, `.ods`, `.db`, `.sqlite`, `.sqlite3`
     - Text data: `.txt`, `.dat`, `.log`, `.out`
     - Binary data: `.bin`, `.raw`, `.dat` (if large)
     - Image data: `.png`, `.jpg`, `.jpeg`, `.tiff`, `.tif`, `.gif`, `.svg`, `.pdf`
     - Audio/video: `.wav`, `.mp3`, `.mp4`, `.avi`, `.mov`
   - For each data file found:
     - Record absolute path
     - Record relative path from artifact directory
     - Record file size
     - Record modification date
     - Identify file format/type
     - Note if file appears to be input, output, or intermediate

6. **Scan code files for data references**:
   - Scan all code files in the artifact directory for:
     - File paths (strings containing file paths, `open()`, `pd.read_csv()`, `np.load()`, etc.)
     - API endpoints and URLs
     - Database connection strings (without credentials)
     - Environment variable references
     - Configuration file references
   - Extract and catalog all data source references

7. **Identify external data sources**:
   - From code analysis, identify:
     - **External APIs**: HTTP endpoints, REST APIs, GraphQL endpoints
       - Document endpoint URLs (without authentication tokens)
       - Document authentication method (API key, OAuth, etc.) but NOT credentials
     - **Databases**: Database connections
       - Document database type, host (if not sensitive), database name
       - Document connection method but NOT credentials
     - **External files**: Files referenced but not in the artifact directory
       - Document absolute paths if accessible
       - Document relative paths from project root
       - Note if files are expected to exist elsewhere

8. **Inventory input parameters and configurations**:
   - Scan for configuration files:
     - `config.json`, `config.yaml`, `settings.ini`, `.env` files (document variable names, NOT values)
     - Command-line argument patterns
     - Configuration classes or dictionaries in code
   - Document environment variables used:
     - List variable names only (NOT values)
     - Document where they're used and for what purpose
   - Document command-line arguments:
     - Argument patterns and expected formats
     - Default values if apparent
     - Required vs optional arguments

9. **Trace data dependencies and provenance**:
   - For each data file, try to determine:
     - **Source**: Where did this data come from?
       - Generated within this artifact?
       - Copied from another location?
       - Downloaded from external source?
       - Output from previous step?
     - **Transformations**: What processing was applied?
       - Filtering, cleaning, aggregation
       - Format conversions
       - Data joins or merges
   - Document data flow: inputs → processing → outputs

10. **Identify output data locations**:
    - Scan for where data is written:
      - File write operations (`write()`, `to_csv()`, `save()`, etc.)
      - Database write operations
      - API POST/PUT operations
    - Document output locations:
      - Files written within artifact directory
      - Files written to external locations
      - Database tables or collections written to

11. **Document data structure notes**:
    - For key data files, document:
      - **Format**: CSV, JSON, Parquet, etc.
      - **Schema**: Column names, data types (if determinable from code or file inspection)
      - **Size/Volume**: File sizes, record counts (if available)
      - **Encoding**: Text encoding if relevant
    - Note any data structure documentation found in the artifact

12. **Create data review document**:
    - Save to: `docs/reviews/{artifact-identifier}-{type}-data-review.md`
    - Use the following structure:

    ```markdown
    # Data Review: {artifact-identifier}

    **Date**: {current date and time}
    **Artifact Type**: {exploration|run|archaeology|source|artifact}
    **Artifact Path**: {absolute path to artifact directory}
    **Artifact State**: ACTIVE / FROZEN
    **Review Type**: Data and Input Review

    ## Summary

    - **Total data sources**: {count}
    - **Data locations**: {within project} vs {external}
    - **Input files**: {count}
    - **Output files**: {count}
    - **External data sources**: {count}
    - **Configuration sources**: {count}

    ## Data Inventory

    ### Data Files in Artifact Directory

    {For each data file found:}
    - `{relative_path}` ({format})
      - **Full path**: `{absolute_path}`
      - **Size**: {size}
      - **Modified**: {date}
      - **Type**: {input|output|intermediate}
      - **Format**: {CSV, JSON, etc.}
      - **Schema/Structure**: {if determinable}

    ### External Data Sources

    #### External APIs
    {For each API endpoint:}
    - **Endpoint**: {URL without auth tokens}
    - **Method**: {GET, POST, etc.}
    - **Authentication**: {method, but NOT credentials}
    - **Purpose**: {what data is retrieved}
    - **Referenced in**: {file path and line number}

    #### Databases
    {For each database:}
    - **Type**: {PostgreSQL, MySQL, SQLite, etc.}
    - **Host**: {if not sensitive}
    - **Database name**: {name}
    - **Connection method**: {but NOT credentials}
    - **Purpose**: {what data is accessed}
    - **Referenced in**: {file path and line number}

    #### External Files
    {For each external file reference:}
    - **Path**: `{absolute or relative path}`
    - **Expected location**: {where file should exist}
    - **Purpose**: {what data is used for}
    - **Referenced in**: {file path and line number}

    ### Input Parameters

    #### Configuration Files
    {List all config files with paths and what they configure}

    #### Environment Variables
    {List variable names only (NOT values) and their purpose}

    #### Command-Line Arguments
    {Document argument patterns and expected formats}

    ### Data Dependencies and Provenance

    #### Data Flow
    {Document: inputs → processing → outputs}

    #### Data Sources
    {For each data file, document where it came from}

    #### Data Transformations
    {Document what processing was applied to data}

    ### Output Data Locations

    {List where data is written: files, databases, APIs}

    ### Data Structure Notes

    {Document formats, schemas, sizes for key data files}

    ## References

    - Related code files: {links to code that uses this data}
    - Related documentation: {links to relevant docs}
    - Handoff packets: {if any reference this artifact}
    - Related artifacts: {other explorations/runs that might share data}
    - Project documentation: {links to project docs/INDEX.md, etc.}
    ```

13. **Respect frozen artifacts**:
    - If artifact is FROZEN:
      - Document that the artifact is FROZEN and immutable
      - State that this review is a snapshot documentation
      - Do NOT modify any files in the artifact directory
      - The review document itself is new documentation in `docs/reviews/`, not a modification of the frozen artifact
    - If artifact is ACTIVE:
      - Still create review in `docs/reviews/` (not inside artifact) for consistency
      - Document that artifact is ACTIVE and may be modified

14. **Security considerations**:
    - **NEVER include**:
      - Passwords, API keys, tokens, or secrets
      - Database credentials
      - Personal or sensitive data values
    - **DO include**:
      - Variable names (without values)
      - Authentication methods (without credentials)
      - Data source locations (without sensitive paths)
      - Configuration structure (without secrets)

15. **Update project documentation index**:
    - Read `docs/INDEX.md` (create if it doesn't exist)
    - Add entry for the new review document in appropriate section
    - If `docs/INDEX.md` has a "Reviews" or "Documentation" section, add there
    - Otherwise, add a new "Reviews" section
    - Format: `- [Data Review: {artifact-identifier}](reviews/{filename}) - {artifact-type} data and input review`

16. **Ensure completeness**:
    - Include all data file paths (absolute and relative)
    - Document all external data sources
    - Reference code files that use each data source
    - Make the document self-contained for future agents
    - Write clearly so a future agent reading this knows exactly where all data resides

## Important

- **Location**: Review documents are ALWAYS saved in `docs/reviews/` regardless of artifact state (ACTIVE/FROZEN)
- **Frozen artifacts**: Never modify frozen artifacts. The review document is new documentation that references frozen artifacts without changing them.
- **Security**: Never document passwords, API keys, tokens, or sensitive data values. Document structure and locations only.
- **Completeness**: The review should be comprehensive enough that future agents know exactly where all data and inputs reside
- **Evidence-based**: Include specific file paths, data source locations, and code references
- **Self-contained**: Document should stand alone without requiring access to the review session
- **Update INDEX**: Always update `docs/INDEX.md` to make the review discoverable
- **Artifact type detection**: Automatically detects type from path, but works for any directory structure
- **Flexibility**: Works for explorations, runs, archaeology, src/, or any custom directory
- **Data provenance**: Document where data came from and how it was transformed

--- End Command ---
