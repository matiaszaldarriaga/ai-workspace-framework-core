NORMS: Workspace Rules for ai-workspace-framework-core
=================================================

## Purpose

This document defines:
- **how this workspace is organized**, and
- **what counts as trusted (“real”) work**.

It intentionally avoids specifying detailed agent execution mechanics.
Those live in `rules/AI-AGENT-CONTRACT.md`.

---

## Scope and layout

- **All real work lives in `<project-root>/`**, one git repo per project.
- Each project repo is self-contained: code, docs, configs, automation, and either data or data pointers live inside the project repo.
- Do not create ad-hoc work at the workspace root. Only maintain workspace-wide docs like `README.md`, `rules/NORMS.md`, and `rules/AI-AGENT-CONTRACT.md`.

---

## Workspace-local notes (not committed)

Sometimes we want to keep small notes about improving the workspace itself (clarifications, TODOs, future refactors) without committing them to git.

- Put workspace-local notes under `workspace_notes/`.
- Contents of `workspace_notes/` are **ignored by git** by default.
- Do not put project work there; project work belongs inside the relevant repo under `<project-root>/`.

The directory itself is committed (via placeholder files) so it exists in fresh clones.

---

## Workspace-level project tracking (human-only)

Human-maintained project tracking files live at the workspace level under `docs/` (distinct from project-level `docs/` directories under each project).

- `PROJECT_NOTES.md (human-owned, optional)` — project status and notes for human tracking
- `FUTURE_PROJECTS.md (human-owned, optional)` — future project ideas and plans
- Agents may **read** these files for context, but should **not write** to them
- These are human-owned tracking files, not agent-authored documentation

---

## Required internal structure of every project

Every project repo under `<project-root>/` must contain at least:

- `docs/` — trusted documentation: questions, decisions, indices, and results. **This is the only required directory.**

Other directories are optional and depend on project type:

- `explorations/` — active, disposable work: notebooks, spikes, scratch code, experiments. (Optional, created on-demand for Science projects)
- `archaeology/` — archived/salvaged old work kept for reference (non-authoritative by default). (Optional, created on-demand for Science projects)
- `runs/` — reproducible executions: scripts, configs, logs, pinned environments. (Optional, created on-demand for Science projects)
- `src/` — promoted, reusable, maintained code. (Optional)

**Project types:**
- **Science** (default): Creates all 5 directories (`docs/`, `explorations/`, `archaeology/`, `runs/`, `src/`)
- **Minimal**: Creates only `docs/` directory

Empty directories can be safely deleted. Workspace-specific directories (`explorations/`, `runs/`, `archaeology/`) will be created on-demand when needed by commands.

---

## Trust and promotion rules

- **Nothing is trusted by default** unless:
  - it is promoted into `src/`, and/or
  - it is recorded in `docs/RESULTS.md` (or another clearly named results file under `docs/`).
- Material in `explorations/` is **disposable** and may be inconsistent or partially wrong.
- Material in `archaeology/` is **reference** and must not be treated as authoritative without explicit promotion.

### Bundles and remote execution (source of truth)

- **Bundles (`bundle/` trees, tarballs, or remote copies) are downstream artifacts**, not sources of truth for reusable code.
- **Reusable code intended for future runs must live in `src/` (or a clearly documented library directory under the project root)**:
  - Explorations (`explorations/`) are allowed to experiment, but **must not be used as bundle templates** for production/remote campaigns.
  - Runs (`runs/`) may contain bundles as **snapshots** of what was executed, but new campaigns must not copy code from older bundles or frozen runs.
- When building a bundle for remote execution, agents must:
  - **derive all vendored code from `src/` (or the project’s documented library dirs)**, not from `explorations/` or prior `runs/`,
  - use the project’s **canonical bundle builder** when one is defined (e.g., `scripts/build_bundle.sh` or a documented Python entrypoint),
  - treat any manual remote hotfixes as temporary: they must be round‑tripped back into `src/` (and the canonical builder) before being reused in new bundles.
- Frozen bundles and runs:
  - may be read and copied for provenance and debugging,
  - must not be retroactively edited,
  - must not become the upstream source for new bundles (new work should instead fix and promote code in `src/`).

### Promotion expectations (lightweight)

Promotion from `explorations/` or `archaeology/` into `src/` or trusted `docs/` should:
- capture key assumptions/decisions in `docs/`,
- ensure promoted code is minimally tested (where reasonable),
- remove, deprecate, or clearly mark obsolete exploratory artifacts.

### Where to look first

Before treating an artifact as authoritative:
1. check `src/`
2. check `docs/RESULTS.md` (or equivalent trusted results doc)
3. only then consult `explorations/` / `archaeology/` as context

---

## Default agent working location (workspace-level)

- Check if `explorations/` directory exists in the target project:
  - If `explorations/` exists: Assume there is a single **active exploration** inside the target project. Work only inside that active exploration unless explicitly told otherwise.
  - If `explorations/` doesn't exist: Work in project root or `src/` as appropriate for the project structure.
- Adapt behavior based on project structure (Science vs Minimal vs legacy projects).
- Never modify `src/` without explicit user instruction in the current session.

---

## Agent directory initialization (required)

- **Rules and commands structure:**
  - All workspace rules live in `rules/` directory (e.g., `rules/NORMS.md`, `rules/AI-AGENT-CONTRACT.md`).
  - All workspace commands live in `commands/` directory (e.g., `commands/create-project.md`).
  - Agent-specific directories (`.cursor/rules/`, `.cursor/commands/`, `.agent/workflows/`, `.claude/commands/`) contain symlinks to the base directories.
  
- **Before using agent-specific command/rule discovery directories**, ensure they exist with proper symlinks:
  - `.cursor/rules/` → symlinks to `../rules/`
  - `.cursor/commands/` → symlinks to `../commands/`
  - `.agent/workflows/` → symlinks to `../commands/` (Antigravity uses workflows for commands)
  - `.claude/commands/` → symlinks to `../commands/` (if using Claude Code)
  
- This check is idempotent: if directories and symlinks already exist correctly, no action is needed.
  
- **When creating new rules or commands:**
  - Always create new rules in `rules/` directory (not in agent-specific directories).
  - Always create new commands in `commands/` directory (not in agent-specific directories).
  - After creating a new rule or command, create symlinks in all relevant agent directories.
  - Use the `commands/add-new-rule.md` or `commands/add-new-command.md` commands to ensure proper setup.
  
- **Important:** Regardless of which agent you are (Cursor, Antigravity, Claude Code, or any other), you must:
  1. Create new rules in the base `rules/` directory
  2. Create new commands in the base `commands/` directory
  3. Create symlinks in all relevant agent-specific directories
  4. This ensures consistency across all agents and makes the structure work after cloning

---

## Canonical user commands (project-level)

When the user issues one of these commands in natural language, the agent should execute it mechanically with minimal back-and-forth.

### Command: Iterate (hands-off pipeline)

- Run an end-to-end iteration after a discussion with minimal human involvement:
  - checkpoint repo once at iteration boundary (`/ensure-clean-repo`)
  - create or use a plan (`/req-imp-test-plan`)
  - execute the plan (`/execute-plan`)
  - interpret results with a plot-first approach (`/interpret-results`)
  - create a handoff packet for continuation (`/create-handoff`)
- Human input should be captured in `<project-root>/docs/HUMAN_COMMENTS.md` rather than chat-only.

### Command: Create a new project

- Create `<project-root>/` (kebab-case recommended), initialize git, and create directories based on project type:
  - **Science** (default): Create all 5 directories: `docs/`, `explorations/`, `archaeology/`, `runs/`, `src/`
  - **Minimal**: Create only `docs/` directory
- Add stubs:
  - `README.md` (project goal + entry points)
  - `docs/QUESTIONS.md` (human-owned stub)
  - `docs/RESULTS.md` (validated results stub)
  - `docs/INDEX.md` (doc map)
- Optional parameter: `{project_type}` - "science" (default) or "minimal"

### Command: Create a new exploration

- Create `<project-root>/explorations/<exploration-id>/` and add:
  - `README.md` (scope-level description)
  - `questions.md` (human-owned stub)
  - `log.md` (dated stub)
- Update `<project-root>/docs/INDEX.md` to point to the active exploration.

### Command: Start an archaeology

- Create `<project-root>/archaeology/<archaeology-id>/` and add:
  - `README.md` (what is being salvaged and why)
  - `findings.md` (observations; not validated results)
  - `inventory.md` (what was examined vs skipped)

---

## End
