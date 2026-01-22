# Requirements, Implementation, and Test Plan

Produce a comprehensive planning document from a discussion that enables another agent instance to execute the work end-to-end with complete information.

## Parameters
None - this command operates on the current discussion context in the chat.

## Instructions

1. **Repo checkpointing (Option A)**:
   - If this planning step is part of a larger iteration pipeline (e.g., invoked via `/iterate`), assume the iteration boundary checkpoint has already been done and **do not** re-run `/ensure-clean-repo` here.
   - If you are running this command standalone (not under `/iterate`), run `/ensure-clean-repo` once before producing the plan.

2. **Analyze the discussion context**:
   - Review the conversation history to extract:
     - The problem or task being discussed
     - Key decisions made
     - Constraints and assumptions
     - Any technical requirements mentioned
     - Success criteria or acceptance conditions
   - If present, also incorporate durable human input from `docs/HUMAN_COMMENTS.md` (project-level).

3. **Produce a comprehensive planning document** that includes:

   ### Objectives
   - Clear, measurable goals for the work
   - Success criteria
   - Scope boundaries (what is in and out of scope)
   - Any constraints or assumptions

   ### Requirements
   - Functional requirements (what the system/feature must do)
   - Non-functional requirements (performance, security, maintainability, etc.)
   - Dependencies (libraries, services, external systems)
   - Environment requirements
   - Data requirements (if applicable)
   - **Frozen artifact constraints** (explicitly state that frozen code, explorations, and runs cannot be modified; they can be copied, used, or called, but their integrity must be preserved)

   ### Implementation Plan
   - High-level architecture or approach
   - Step-by-step implementation phases
   - File structure and organization (following `rules/NORMS.md` structure: `docs/`, `explorations/`, `src/`, etc.)
   - Key components/modules to be created
   - Integration points
   - Dependencies between phases
   - Estimated complexity or effort indicators (if applicable)

   ### Testing Requirements
   - Unit test requirements
   - Integration test requirements
   - End-to-end test scenarios
   - Acceptance criteria
   - Test data requirements
   - Performance/load testing needs (if applicable)
   - Manual testing checklists (if applicable)

4. **Ensure completeness for handoff**:
   - The document must be self-contained and sufficient for another agent to:
     - Understand the full context without reading the original discussion
     - Execute the implementation without ambiguity
     - Verify completion through the testing requirements
   - Include references to any relevant project rules (`rules/NORMS.md`, `rules/AI-AGENT-CONTRACT.md`)
   - Specify artifact locations following workspace conventions

5. **Save the planning document**:
   - If working within a project: save to `projects/<project-name>/docs/IMPLEMENTATION_PLAN.md` or similar appropriate location
   - If workspace-level: save to an appropriate location in the workspace
   - Update `docs/INDEX.md` if applicable to reference the new planning document

6. **Verify frozen constraints** (recommended):
   - Run `/verify-frozen-constraint` on the created plan to ensure frozen artifact constraints are explicit and clear
   - If the verification identifies gaps, propose improvements to the user before updating the plan

7. **Follow project rules**:
   - Adhere to all requirements in `rules/NORMS.md`:
     - Use proper project structure (`docs/`, `explorations/`, `src/`, etc.)
     - Work in appropriate directories (explorations for active work, src for promoted code)
     - Follow trust and promotion rules
   - Adhere to all requirements in `rules/AI-AGENT-CONTRACT.md`:
     - Be explicit about assumptions
     - Provide evidence-based planning
     - Clearly mark artifact state (ACTIVE/FROZEN)
     - Include sufficient context for handoff

## Important

- **Option A**: Prefer repo checkpointing at iteration boundaries (e.g., `/iterate`). If running standalone, checkpoint once at the start.
- The planning document must be comprehensive enough for a fresh agent instance to execute without the original discussion context
- All requirements, constraints, and assumptions from the discussion must be explicitly captured
- The implementation plan should be actionable with clear phases and deliverables
- Testing requirements must be specific and verifiable
- Follow workspace conventions for file organization and documentation structure

--- End Command ---
