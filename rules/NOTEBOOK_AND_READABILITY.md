# Notebook and Readability Rules

**Purpose:** Rules for producing computational work that humans can review and understand, and that AI agents can write and maintain reliably.

**Scope:** Applies to all projects that produce analysis notebooks, results, or computational artifacts.

---

## 1. Use Marimo, Not Jupyter

**Rule:** Use [marimo](https://marimo.io/) notebooks (`.py` files) instead of Jupyter (`.ipynb` files).

**Why:**
- **Version control:** Marimo notebooks are plain `.py` files. Diffs are readable. Merge conflicts are resolvable. Jupyter's JSON format makes both nearly impossible.
- **Reactive execution:** Marimo re-runs dependent cells automatically. No stale state bugs from running cells out of order.
- **AI-friendly:** AI agents can read, write, and edit `.py` files natively. Jupyter's JSON cell structure requires specialized tooling and is error-prone to edit.
- **HTML export:** `marimo export html notebook.py -o output.html` produces a self-contained HTML file that can be viewed in any browser — including via SSH tunnel from a remote machine.

### Marimo Gotcha: Unique Variable Names

Marimo requires that every variable name is defined in exactly one cell. If two cells both define `fig` or `ax`, you get a `MultipleDefinitionError`.

**Solution:** Prefix cell-local variables with `_` (underscore):

```python
# Cell 1: Evidence comparison
_fig, _ax = plt.subplots(figsize=(12, 6))
_subset = df[df['injection'] == 'aligned']
_ax.bar(_subset['run'], _subset['ln_evidence'])
_ax.set_title('Evidence: Aligned Injection')

# Cell 2: Timing breakdown
_fig2, _ax2 = plt.subplots(figsize=(12, 6))
_subset2 = df[df['bank'] == 'nrsur']
_ax2.bar(_subset2['run'], _subset2['total_min'])
_ax2.set_title('Timing: NRSur Bank')
```

Only variables that are **used across cells** (like DataFrames, loaded data, shared configuration) should have non-prefixed names.

---

## 2. HTML Export Is a Deliverable

**Rule:** Whenever you produce a marimo notebook, also export the HTML version to the project's `output/` directory.

```bash
marimo export html notebooks/analysis.py -o output/analysis.html
```

**Why:** The user will often review results by viewing the HTML via SSH tunnel from another machine, without needing to run the notebook. The HTML must be self-contained and up-to-date.

**Verification:** After writing a notebook, always run the export to verify it executes without errors. If the export fails, the notebook is broken.

---

## 3. Code Traceability

**Rule:** Never produce results, plots, or analysis from throwaway inline code. Every computation must be executed from a tracked, versioned file (script, notebook, or module).

**What this means:**
- If a plot exists, the exact code that generated it must be in a file that can be re-run to reproduce it.
- If a result is reported, the computation that produced it must be traceable to a committed file.
- Notebooks are the code — the notebook file itself must be what runs to produce the results. Do not write a notebook that merely displays results computed elsewhere.

**Violations:**
- Writing Python in a tool call that generates a plot, then writing a separate notebook that claims to produce it.
- Running ad-hoc analysis that produces numbers cited in a report, with no script to reproduce them.
- Creating a notebook that imports pre-computed results without the computation being traceable.

---

## 4. Human Readability

**Rule:** Code must be organized so that a human reading it can understand what's happening and why.

**This means:**
- **Clear variable names.** `chirp_mass` not `cm`. `n_survivors` not `ns`. The cost of typing is zero; the cost of confusion is high.
- **Logical cell ordering in notebooks.** Setup → data loading → computation → visualization → summary. A human reading top-to-bottom should follow the narrative.
- **Section headers.** Use markdown cells in marimo to label sections. Every notebook should read like a short report.
- **No opaque one-liners.** `df.groupby(['injection', 'bank']).agg({'ln_evidence': 'mean'}).unstack().plot()` does too much. Break it into steps the reader can follow.
- **Comments where logic isn't obvious.** Don't comment `x = x + 1  # increment x`. Do comment `threshold = global_max - 20  # max_incoherent_lnlike_drop parameter`.

**The test:** Could the user, looking at the HTML export on their laptop via tunnel, understand what the code does and whether the results make sense? If not, reorganize.

---

## 5. Notebook Structure Template

A well-structured marimo notebook follows this pattern:

```python
import marimo as mo

# Cell 1: Title and description (markdown)
mo.md("""
# Analysis: [Clear Title]
**Date:** YYYY-MM-DD
**Purpose:** [One sentence]
**Data:** [Where the input data comes from]
""")

# Cell 2: Imports and configuration
import numpy as np
import matplotlib.pyplot as plt
# ...
DATA_DIR = "/path/to/data"

# Cell 3: Data loading
# Load and prepare all data needed for analysis
data = load_data(DATA_DIR)

# Cell 4-N: Analysis sections
# Each section: markdown header → computation → visualization → interpretation

# Final cell: Summary
mo.md("""
## Summary
- [Key finding 1]
- [Key finding 2]
- [Key finding 3]
""")
```

---

## 6. When NOT to Use Notebooks

Notebooks are for **analysis and presentation**. They are not for:

- **Production scripts** that run in pipelines or SLURM jobs → use `.py` scripts
- **Library code** that is imported by multiple consumers → use modules in `lib/` or `src/`
- **Long-running computations** → use scripts, present results in notebooks

The notebook should be the last step: load pre-computed results, analyze, visualize, interpret. The computation itself belongs in scripts or library code.
