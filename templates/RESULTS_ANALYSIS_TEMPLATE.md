# Results Analysis: [Title/Description]

*Created: [Date]*
*Artifact Path: [Path to artifacts being analyzed]*

---

## Context

### Goals

*What was this computation/analysis trying to achieve? Reference the plan document, research questions, or human comments that motivated this work.*

- Goal 1: ...
- Goal 2: ...
- Success criteria: ...

### What Was Computed

*Brief technical description of what was executed. Include:*
- Input data/parameters used
- Key algorithms or methods applied
- Output artifacts produced

*Example:*
> This analysis ran SVD decomposition on MCMC chain samples from Planck 2018 ΛCDM cosmology, computing principal components of cosmological distance measurements at 7 redshift bins. The code executed was `scripts/run_svd_analysis.py` with parameters from `config.yaml`.

---

## Methodology

*Brief description of the computational approach. Keep this section short - focus on what's needed to interpret the figures.*

- Input: ...
- Processing: ...
- Output: ...

---

## Figures and Interpretation

*This is the core section. For each key figure, provide: embedded image, claim, evidence, implication.*

### Figure 1: [Descriptive Title]

![figure_01](figures/figure_01_description.png)

**Claim:** [What this plot demonstrates - one sentence]

**Evidence:** [Visual features observed in the plot that support the claim]
- Observation 1: ...
- Observation 2: ...

**Implication:** [What this means for the goals/success criteria]

**Interpretation:** [Deeper analysis if needed]

---

### Figure 2: [Descriptive Title]

![figure_02](figures/figure_02_description.png)

**Claim:** [What this plot demonstrates]

**Evidence:** [Visual features observed]

**Implication:** [What it means for the goals]

---

### Figure N: [Descriptive Title]

![figure_N](figures/figure_N_description.png)

**Claim:**

**Evidence:**

**Implication:**

---

## Expected vs Surprising

### Expected Behavior

*What outcomes were anticipated based on the plan, prior work, or theoretical understanding?*

- Expected: ...
- Rationale: ...

### Surprising Observations

*What results were unexpected, inconsistent, or anomalous?*

- Surprise 1: ...
  - Why surprising: ...
  - Possible explanations: ...

### Proposed Follow-up

*If anomalies or questions remain, propose minimal diagnostic tests/plots that would resolve ambiguity.*

1. Follow-up test 1: ...
2. Follow-up plot 2: ...

---

## Conclusions

### Key Findings

*Summarize the main results from the figures. Number them and be specific.*

1. Finding 1: [Reference Figure X]
2. Finding 2: [Reference Figure Y]
3. Finding 3: [Reference Figure Z]

### Assessment Against Goals

*How well did this work meet the stated goals and success criteria?*

- Goal 1: ✓ Met / ✗ Not met / ⚠ Partial — [explanation]
- Goal 2: ...

---

## Confidence and Caveats

### Confidence Level

*How confident are we in these results? What evidence supports this confidence level?*

- High confidence: [aspects with strong evidence]
- Medium confidence: [aspects with some uncertainty]
- Low confidence: [aspects requiring validation]

### Limitations

*Known limitations, assumptions, or potential sources of error*

1. Limitation 1: ...
2. Limitation 2: ...

### Caveats

*Important caveats for interpreting these results*

- Caveat 1: ...
- Caveat 2: ...

---

## Next Actions

*Concrete next steps based on these results. Be specific.*

### Immediate

1. Action 1: ...
2. Action 2: ...

### Future Work

1. ...
2. ...

---

## Evidence Index

*Quick reference to all artifacts produced/analyzed*

### Figures
- `figures/figure_01_description.png` — [one-line description]
- `figures/figure_02_description.png` — [one-line description]
- ...

### Data Files
- `data/output.csv` — [description]
- ...

### Logs
- `logs/execution.log` — [description]
- ...

### Metrics Tables
- `metrics/summary.json` — [description]
- ...

---

## Reproducibility

*How to reproduce this analysis*

**Command:**
```bash
# Exact command used to generate these results
python scripts/run_analysis.py --config config.yaml
```

**Environment:**
- Python version: ...
- Key dependencies: ...
- Random seeds (if applicable): ...

**Runtime:** [e.g., "~5 minutes on 8-core CPU"]

---

## References

*Links to related documents, plans, or prior work*

- Plan document: `[path/to/plan.md]`
- Prior analysis: `[path/to/prior/RESULTS_ANALYSIS.md]`
- Research questions: `docs/QUESTIONS.md`
- Human comments: `docs/HUMAN_COMMENTS.md`
