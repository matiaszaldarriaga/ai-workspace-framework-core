# Verify Frozen Constraint

Verify that a plan explicitly states that frozen artifacts (code, explorations, runs) cannot be modified in any way, while allowing them to be copied, used, or called.

## Parameters
- `{plan_path}` - Optional path to the plan document to verify. If not provided, search for recent planning documents.

## Instructions

1. **Locate the plan document**:
   - If `{plan_path}` is provided, use that document.
   - Otherwise, search for recent planning documents (e.g., `IMPLEMENTATION_PLAN.md`, `REQUIREMENTS.md`, or similar in `docs/` directories).
   - If multiple plans exist, verify the most recent or active one.

2. **Review the plan for frozen constraint statements**:
   - Read the entire plan document carefully.
   - Look for explicit statements about:
     - Frozen artifacts (code, explorations, runs) being immutable
     - Prohibition on modifying frozen material
     - Permission to copy, use, or call frozen code (but not modify it)
     - References to `rules/AI-AGENT-CONTRACT.md` artifact state rules

3. **Check against project rules**:
   - Reference `rules/AI-AGENT-CONTRACT.md` section "Artifact state: ACTIVE vs FROZEN":
     - **FROZEN** artifacts are immutable sealed references
     - Must not be modified, re-run, or retroactively reinterpreted
     - Code can be copied, used, or called, but the integrity of frozen things cannot be compromised
   - Reference `rules/AI-AGENT-CONTRACT.md` section "Restart protocol" which explicitly forbids "touching frozen material"

4. **Verify explicit constraint statements**:
   The plan must explicitly state (or clearly imply in a way that is unambiguous):
   - **Frozen artifacts cannot be modified** - no edits, deletions, or changes to frozen code, explorations, or runs
   - **Frozen artifacts can be referenced** - frozen code can be copied, used as a library, called, or referenced
   - **Frozen integrity must be preserved** - the original frozen artifact must remain unchanged
   - **New work must be separate** - any modifications or extensions must be created as new artifacts (new files, new explorations, etc.)

5. **Identify gaps or ambiguities**:
   - If the constraint is missing entirely, note this as a critical gap.
   - If the constraint is mentioned but unclear or ambiguous, note specific areas of ambiguity.
   - If the constraint is present but not prominent enough, note where it should be emphasized.

6. **Propose improvements**:
   - If gaps or issues are found, propose specific improvements to the plan:
     - Add a dedicated section on "Frozen Artifact Constraints" or "Immutability Requirements"
     - Include explicit statements in relevant sections (e.g., Implementation Plan, Requirements)
     - Add reminders in step-by-step instructions
     - Reference the relevant rules (`rules/AI-AGENT-CONTRACT.md`)
   - Format improvements as concrete, actionable suggestions with example text if helpful.

7. **Report findings**:
   - **If constraint is present and clear**: Confirm that the plan properly addresses frozen artifact constraints.
   - **If constraint is missing or unclear**: 
     - Clearly state what is missing or ambiguous
     - Propose specific improvements with example text
     - Explain why the constraint is important (preserves integrity, enables reproducibility, follows project rules)
     - Present improvements to the user for approval before modifying the plan

## Important

- This verification step is useful even though the constraint is codified in `rules/AI-AGENT-CONTRACT.md` because:
  - Plans may be developed by agents that don't fully internalize the rules
  - Explicit statements in plans help prevent accidental violations
  - Plans serve as handoff documents and should be self-contained
- The constraint must be **explicit**, not just implicit
- Proposing improvements does not mean automatically modifying the plan - always present improvements to the user first
- Focus on clarity and prominence: the constraint should be hard to miss for an agent executing the plan

## Example Constraint Statement

A good constraint statement might look like:

```markdown
## Frozen Artifact Constraints

**CRITICAL**: This plan must not modify any FROZEN artifacts (code, explorations, runs).

- Frozen artifacts are immutable and must remain unchanged
- Frozen code can be copied, used as a library, or called, but the original files must not be edited
- Any modifications or extensions must be created as new artifacts (new files, new explorations)
- See `rules/AI-AGENT-CONTRACT.md` section "Artifact state: ACTIVE vs FROZEN" for details

If this plan requires changes to frozen material, those changes must be implemented as new artifacts, not modifications to existing frozen ones.
```

--- End Command ---
