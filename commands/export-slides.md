# Export slides

Export a Slidev presentation to PDF, PNG, or PPTX format.

## Parameters
- `{presentation_path}` - Path to the presentation directory (e.g., `projects/gw231123-spin/explorations/ml-progressive-iob-v2/presentations/results-2026-01`)
- `{format}` - Optional: "pdf" (default), "png", or "pptx"

## Prerequisites

- Node.js 18+ must be installed
- Dependencies must be installed (`npm install` in presentation directory)
- First export will download Playwright/Chromium if not present

## Instructions

1. **Verify presentation exists**:
   - Check that `{presentation_path}/slides.md` exists
   - If not, suggest running `/update-slides` first

2. **Check if dependencies are installed**:
   - Check if `{presentation_path}/node_modules/` exists
   - If not, run `npm install` in the presentation directory first

3. **Run the export command** based on format:
   ```bash
   cd {presentation_path}

   # PDF (default)
   npx slidev export slides.md

   # PNG (one image per slide)
   npx slidev export slides.md --format png

   # PPTX (PowerPoint)
   npx slidev export slides.md --format pptx
   ```

4. **Export options**:
   - `--output <name>`: Custom output filename (default: slides-export)
   - `--dark`: Export in dark mode
   - `--with-clicks`: Export each click animation step as separate page
   - `--timeout <ms>`: Increase timeout for complex slides (default: 30000)

5. **Report the export result**:
   - Location of exported file (e.g., `slides-export.pdf`)
   - Number of pages/slides exported
   - Any warnings or errors

## Troubleshooting

### Playwright not installed
```bash
npx playwright install chromium
```

### Export times out
Increase timeout:
```bash
npx slidev export slides.md --timeout 60000
```

### Images missing in export
Ensure image paths are relative to slides.md location.
