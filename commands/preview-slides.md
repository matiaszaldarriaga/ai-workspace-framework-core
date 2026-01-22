# Preview slides

Launch the Slidev development server to preview slides in a browser.

## Parameters
- `{presentation_path}` - Path to the presentation directory (e.g., `projects/gw231123-spin/explorations/ml-progressive-iob-v2/presentations/results-2026-01`)

## Instructions

Run the preview shell script:

```bash
./preview-slides.sh {presentation_path}
```

Or if the user is unsure of the path, help them find it and run the script for them.

The script will:
1. Activate the `slidev` conda environment
2. Install npm dependencies if needed
3. Start the server and wait for it to be ready
4. Open http://localhost:3030 in the browser
5. Keep running until Ctrl+C

## Useful navigation in Slidev

- Arrow keys: Navigate slides
- `o`: Overview mode (see all slides)
- `d`: Toggle dark mode
- `g`: Go to slide by number
- `f`: Fullscreen
- `Esc`: Exit fullscreen/overview

## Notes

- The server watches for file changes and hot-reloads
- Press Ctrl+C to stop the server
- For a different port: `./preview-slides.sh {presentation_path} 3031`
