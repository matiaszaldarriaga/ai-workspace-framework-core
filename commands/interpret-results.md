# Interpret Results (plot-first)

Create a human-facing interpretation document (markdown) that prioritizes evidence from plots/figures, ties findings back to the iteration goals, and flags surprises/anomalies.

## Parameters
- `{artifact_path}` - Path to the primary artifact directory to interpret (e.g., `runs/<run-id>/` or `explorations/<exploration-id>/`).
- `{project_path}` - Optional. Base path if `{artifact_path}` is relative.

## Instructions

1. **Resolve and validate artifact path**:
   - Resolve `{artifact_path}` to an absolute directory path (use `{project_path}` if provided).
   - If the directory does not exist, stop and report the error.

2. **Identify project root**:
   - From `{artifact_path}`, identify the project root (directory containing `docs/`).
   - Ensure `docs/` exists.

3. **Gather goals + human intent**:
   - Read `docs/HUMAN_COMMENTS.md` if it exists (treat as primary human input).
   - Read the most relevant goal-setting docs if they exist:
     - `docs/INDEX.md`, `docs/QUESTIONS.md`, `docs/RESULTS.md`
   - If a plan document is clearly associated with this artifact (referenced in logs/handoffs), read it.

4. **Inventory figures and evidence artifacts** (plot-first):
   - Recursively scan `{artifact_path}` for figures:
     - Prefer: `.png`, `.jpg`, `.jpeg`, `.svg`, `.pdf`
   - Also collect key scalar evidence:
     - test outputs, logs (`.log`, `.out`, `.txt`)
     - metrics tables (`.csv`, `.json`)
   - Prioritize the most "semantic" figures:
     - learning curves, residuals, calibration curves, confusion matrices
     - before/after comparisons
     - error distributions, outlier diagnostics

5. **Read and interpret the key plots**:
   - Open representative plots directly using the Read tool (do not rely only on filenames).
   - For each plot, write a short "claim → evidence → implication" interpretation:
     - **Claim**: what the plot demonstrates
     - **Evidence**: what visual features support the claim (e.g., slope change, separation, saturation, hysteresis)
     - **Implication**: what it means for the goals / success criteria

6. **Expected vs surprising**:
   - Explicitly judge whether the observed behavior matches expectations:
     - What was expected given the plan/goals?
     - What looks strange or inconsistent?
   - If anomalies exist, propose 1–3 minimal follow-up plots/tests that would resolve ambiguity.

7. **Determine report location and create figures directory**:
   - Report location: `{artifact_path}/RESULTS_ANALYSIS.md`
   - Figures directory: `{artifact_path}/figures/` (create if it doesn't exist)
   - If computational code needs to generate new figures:
     - Execute the code (if it's a script) or note what needs to be run
     - Save all figures to `{artifact_path}/figures/`
     - Use descriptive filenames: `figure_01_<short_description>.png`

8. **Create the results analysis report (markdown)**:
   - Use the template from `vendor/ai-workspace-framework-core/templates/RESULTS_ANALYSIS_TEMPLATE.md`
   - Create `{artifact_path}/RESULTS_ANALYSIS.md`
   - **Report structure** (see template):
     - **Context**: Goals from plan/HUMAN_COMMENTS, what was computed
     - **Methodology**: Brief description of what was run and how
     - **Figures and Interpretation**: For each key figure:
       - Embedded figure: `![description](figures/figure_name.png)`
       - **Claim**: What it shows
       - **Evidence**: Visual features observed
       - **Implication**: What it means for the goals
     - **Expected vs Surprising**: Comparison to expectations
     - **Conclusions**: Summary of findings
     - **Confidence and Caveats**: Limitations, uncertainties
     - **Next Actions**: Proposed follow-up work (if any)
   - Include relative paths to all figures interpreted
   - Reference any relevant log files or metrics tables

9. **Important constraints**:
   - Do not modify frozen artifacts; only create reports in ACTIVE work directories
   - Do not create Jupyter notebooks; produce markdown reports only
   - Lead with figures; scalar metrics are supporting evidence only
   - Keep the report human-facing: it should convince the user the results are correct (or clearly show why they may not be)

## Output

- Creates: `{artifact_path}/RESULTS_ANALYSIS.md` (markdown report with embedded figures)
- Creates: `{artifact_path}/figures/` directory (if needed, containing generated plots)
- The report is self-contained: reader can understand findings by reading the markdown and viewing embedded figures

## Important

- **Evidence from plots is more valuable than scalar tables; lead with figures.**
- Keep this doc human-facing and persuasive.
- Do not create notebooks; markdown reports are the standard.
- Figures should be saved as PNG files in a dedicated `figures/` subdirectory for portability.
