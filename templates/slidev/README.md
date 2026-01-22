# Slidev Presentation System

A reusable presentation system based on [Slidev](https://sli.dev/) for creating slides from structured content. This system separates content authoring from slide rendering, enabling AI-assisted slide generation.

## Overview

The system uses two files:
- **`content.md`**: Human-authored structure and bullet points
- **`slides.md`**: AI-generated Slidev presentation

This separation allows:
- Easy editing of content without worrying about slide syntax
- AI-assisted transformation from notes to polished slides
- Version control of source content
- Iteration based on feedback in `comments.md`

## Quick Start

### 1. Install Node.js

Choose one method from `setup/INSTALL.md`:

```bash
# Homebrew (macOS)
brew install node@20

# Or via Conda
conda env create -f templates/slidev/setup/environment.yml
conda activate slidev
```

### 2. Create a Presentation

Use the `/init-presentation` command:

```
/init-presentation project_path=projects/my-project presentation_id=results-2026-01
```

Or manually create the structure:

```
presentations/my-presentation/
├── content.md      # Your content (edit this)
├── comments.md     # Feedback for iterations
├── slides.md       # Generated slides
└── package.json    # Dependencies
```

### 3. Generate Slides

Use `/update-slides` to transform content.md into slides.md:

```
/update-slides presentation_path=projects/my-project/presentations/results-2026-01
```

### 4. Preview

```bash
cd projects/my-project/presentations/results-2026-01
npm install
npm run dev
```

Opens http://localhost:3030 in your browser.

### 5. Export

```bash
npm run export      # PDF
npm run export-png  # PNG images
npm run export-pptx # PowerPoint
```

## Content Format

Structure your content.md like this:

```markdown
# Presentation: My Talk

theme: default
date: 2026-01-19
author: Name

---

## Section: Introduction

### Slide: Title
- title: Presentation Title
- subtitle: Descriptive subtitle

### Slide: Key Points
- First point
- Second point
- Figure: ../artifacts/diagram.png

Notes: Speaker notes go here.
```

### Conventions

- `## Section: <name>` creates a section divider slide
- `### Slide: <title>` starts a new content slide
- `- point` becomes a bullet point
- `- Figure: <path>` embeds an image
- `Notes:` adds speaker notes (not shown on slide)

## Commands

| Command | Description |
|---------|-------------|
| `/init-presentation` | Create a new presentation directory |
| `/update-slides` | Generate slides.md from content.md |
| `/preview-slides` | Launch development server |
| `/export-slides` | Export to PDF/PNG/PPTX |

## Slidev Features

The generated slides can use:

- **Layouts**: `layout: section`, `layout: cover`, `layout: center`
- **Animations**: `<v-clicks>` for reveal animations
- **Code blocks**: Syntax highlighting included
- **Math**: LaTeX via KaTeX (`$inline$` or `$$block$$`)
- **Diagrams**: Mermaid support (`mermaid` code blocks)
- **Images**: `<img src="path" class="mx-auto h-80" />`

### Navigation Keys

- Arrow keys: Navigate slides
- `o`: Overview mode
- `d`: Dark mode toggle
- `g`: Go to slide
- `f`: Fullscreen

## Directory Structure

```
templates/slidev/
├── README.md              # This file
├── package.json           # Slidev dependencies
├── slidev-defaults.yaml   # Default configuration
├── content-template.md    # Example content structure
└── setup/
    ├── INSTALL.md         # Installation instructions
    └── environment.yml    # Conda environment
```

## Versioning

- Git tracks `content.md` changes (source of truth)
- Commit `slides.md` for reproducibility
- Different audiences → separate presentation directories
- Iterate via `comments.md` feedback

## Example

See `projects/gw231123-spin/explorations/ml-progressive-iob-v2/presentations/results-2026-01/` for a working example.

## Troubleshooting

See `setup/INSTALL.md` for common issues and solutions.
