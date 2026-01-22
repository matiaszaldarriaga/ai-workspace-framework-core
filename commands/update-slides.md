# Update slides

Generate or update `slides.md` from `content.md` and `comments.md` for a presentation.

## Parameters
- `{presentation_path}` - Path to the presentation directory (e.g., `projects/gw231123-spin/explorations/ml-progressive-iob-v2/presentations/results-2026-01`)

## Instructions

1. **Read the source files**:
   - Read `{presentation_path}/content.md` for the slide structure and content
   - Read `{presentation_path}/comments.md` for any iteration feedback to incorporate
   - Read `{presentation_path}/slidev-config.yaml` if it exists, for configuration overrides

2. **Parse content.md structure**:
   - Extract frontmatter (theme, date, author)
   - Identify sections marked with `## Section: <name>`
   - Identify slides marked with `### Slide: <title>`
   - Parse bullet points as slide content
   - Identify `Figure: <path>` references for image embeds
   - Extract `Notes:` for speaker notes

3. **Generate slides.md** in Slidev format:
   - Add frontmatter with theme, title, and configuration
   - Use `---` to separate slides
   - For section dividers, use `layout: section`
   - For title slides, use `layout: cover`
   - Embed images using `<img src="path" class="mx-auto h-80" />`
   - Add speaker notes in `<!-- ... -->` comments at slide bottom
   - Apply any feedback from comments.md

4. **Slidev syntax reference**:
   ```markdown
   ---
   theme: default
   title: Presentation Title
   ---

   # Title Slide

   Subtitle text

   ---
   layout: section
   ---

   # Section Name

   ---

   # Regular Slide

   - Bullet point
   - Another point

   <img src="./artifacts/plot.png" class="mx-auto h-80" />

   <!--
   Speaker notes go here
   -->
   ```

5. **Write the generated slides.md** to `{presentation_path}/slides.md`

6. **Report what was generated**:
   - Number of slides created
   - Any images referenced
   - Suggest running `/preview-slides` to view
