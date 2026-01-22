# Bye

Simple command to handoff current work and prepare for next agent. A convenience wrapper around `/create-handoff` with sensible defaults.

## Parameters
None - all parameters are inferred from context.

## Instructions

1. **Execute `/create-handoff`**:
   - Call `/create-handoff` command with no parameters
   - This will:
     - Execute `/ensure-clean-repo` (mandatory first step)
     - Infer handoff location from current working directory
     - Default status to `IN_PROGRESS`
     - Infer reason from context (e.g., "User requested pause")
     - Create handoff document
     - Create task file in `.ready/READY/` (if in a project)
     - Complete all necessary documentation

2. **No additional steps needed**:
   - `/create-handoff` handles everything
   - Task file is automatically created in the new tasks system
   - Work is ready for next agent

## Important

- **This is a convenience wrapper** - use `/create-handoff` with parameters if you need to specify status, reason, or location
- **All work is preserved** - `/create-handoff` ensures all work is committed before creating handoff
- **Task file is created automatically** - if working in a project, task file is created in `.ready/READY/`
- **Ready for next agent** - handoff document and task file are created, work can continue seamlessly

## Example Usage

```bash
# Simple handoff - everything inferred from context
/bye
```

For more control, use `/create-handoff` with parameters:
```bash
/create-handoff status=COMPLETED reason="Phase 2 complete, ready for testing"
```

--- End Command ---
