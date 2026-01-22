# Discuss and plan

Analyze a request, gather information from the codebase and artifacts, and propose possible plans or ideas. **NO ACTION may be taken** - this is a forensic and planning exercise only.

## Parameters
- `{request}` - The user's request or question to discuss and plan for

## Instructions

1. **Understand the request**:
   - Parse the user's request/question carefully
   - Identify what information is needed to address it
   - Clarify any ambiguities by asking questions if necessary

2. **Gather information first** (CRITICAL - do this before proposing solutions):
   - **Read relevant code files** - don't assume, inspect actual code
   - **Examine existing artifacts** - check `docs/`, `explorations/`, `runs/`, `src/` for relevant work
   - **Read human input file** (if present): `docs/HUMAN_COMMENTS.md` (primary human-owned input channel)
   - **Review documentation** - look at `docs/RESULTS.md`, `docs/QUESTIONS.md`, handoff packets, etc.
   - **Check git history** - see what has been done before
   - **Look at test results** - if tests exist, examine their outputs
   - **Inspect logs** - check `runs/` for execution logs or error messages
   - **Search the codebase** - use semantic search to find related code/patterns

3. **Forensic analysis**:
   - Document what you found (cite specific files, line numbers, artifacts)
   - Identify patterns or inconsistencies in the codebase
   - Note any existing solutions or approaches that have been tried
   - Identify gaps in information that need to be filled

4. **Ground proposals in evidence**:
   - **Every proposed idea must reference specific data/artifacts**
   - Cite file paths, line numbers, commit messages, or artifact locations
   - Explain how the evidence supports each proposal
   - If you don't have enough information, state what needs to be gathered

5. **Propose possible plans/ideas**:
   - Present multiple approaches if applicable
   - For each approach:
     - Reference the evidence that supports it
     - Explain the rationale based on what you found
     - Identify potential challenges based on the codebase structure
     - Estimate complexity based on existing code patterns
   - If significant information is missing, propose how to gather it first

6. **Make it clear this is planning only**:
   - Explicitly state: "This is a planning discussion. No changes will be made."
   - Do not execute any file modifications, commands, or code changes
   - Do not create files or directories
   - Only read, analyze, and propose

## Important

- **NO EXECUTION**: This command is for discussion and planning only. No actions may be taken.
- **Evidence-first**: Always gather information from the codebase/artifacts before proposing solutions
- **Ground in data**: Every proposal must reference specific evidence (files, artifacts, code)
- **Prefer inspection over assumption**: Read the code, don't assume how it works
- **Cite sources**: Always include file paths, line numbers, or artifact references
- **Acknowledge gaps**: If information is missing, state what needs to be gathered

## Example Response Format

```
## Understanding the Request
[Clarification of what the user is asking for]

## Information Gathered

### Code Inspection
- Examined `src/component.ts` (lines 45-67): Found pattern X
- Reviewed `docs/RESULTS.md`: Previous attempt showed Y
- Checked `runs/log-2024-01-13.log`: Error pattern Z observed

### Artifacts Found
- `explorations/prototype-1/`: Contains similar work from last month
- `docs/QUESTIONS.md`: Question #3 relates to this issue

### Gaps Identified
- Need to check test coverage in `tests/`
- Missing documentation about API endpoint behavior

## Proposed Approaches

### Approach 1: [Name]
**Evidence**: Based on pattern found in `src/component.ts:45-67` and similar solution in `explorations/prototype-1/`
**Rationale**: [Explanation grounded in the evidence]
**Challenges**: [Based on codebase structure]
**Next steps**: [What information to gather or how to proceed]

### Approach 2: [Alternative]
[Same structure]

## Important Note
⚠️ **This is a planning discussion only. No code changes, file modifications, or actions will be taken without explicit approval.**

```
