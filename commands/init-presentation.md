# Initialize a presentation

Create a new presentation directory with starter files for Slidev-based slides.

## Parameters
- `{project_path}` - Path to the project or exploration (e.g., `projects/gw231123-spin/explorations/ml-progressive-iob-v2`)
- `{presentation_id}` - Unique identifier for the presentation (e.g., `results-2026-01`)

## Instructions

1. **Verify the target location exists**:
   - Check that `{project_path}` exists
   - If it doesn't exist, ask the user to create the project or exploration first

2. **Create presentation directory**: `{project_path}/presentations/{presentation_id}/`

3. **Copy template files**:
   - Copy `templates/slidev/package.json` to the presentation directory
   - Copy `templates/slidev/slidev-defaults.yaml` to the presentation directory as `slidev-config.yaml`

4. **Create content.md** from template:
   - Use `templates/slidev/content-template.md` as starting point
   - Update the date to today's date
   - Update the title based on context (project name, exploration name)
   - Leave placeholders for the user to fill in

5. **Create comments.md**:
   ```markdown
   # Comments

   <!-- Add feedback for slide iterations here -->

   ## YYYY-MM-DD
   - Initial version
   ```

6. **Create empty slides.md** placeholder:
   ```markdown
   ---
   theme: default
   title: Presentation Title
   ---

   # Presentation Title

   Run `/update-slides` to generate slides from content.md
   ```

7. **Report created files** to the user and suggest next steps:
   - Edit `content.md` to add presentation content
   - Run `/update-slides` to generate the Slidev file
   - Run `/preview-slides` to view in browser
