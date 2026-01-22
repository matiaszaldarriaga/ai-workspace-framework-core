# Slidev Installation Guide

Slidev requires Node.js 18+ to run. Choose one of the following installation methods.

## Option 1: Homebrew (Recommended for macOS)

```bash
# Install Node.js 20 LTS
brew install node@20

# Add to PATH if not automatically linked
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

## Option 2: Conda Environment

```bash
# Create environment from template
conda env create -f templates/slidev/setup/environment.yml

# Activate environment
conda activate slidev

# Verify installation
node --version  # Should show v20.x.x
```

## Option 3: nvm (Node Version Manager)

```bash
# Install nvm if not present
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Restart terminal, then install Node.js 20
nvm install 20
nvm use 20

# Verify installation
node --version  # Should show v20.x.x
```

## Setting Up a Presentation

Once Node.js is installed:

```bash
# Navigate to presentation directory
cd projects/<project>/presentations/<id>/

# Install dependencies (first time only)
npm install

# Start development server
npm run dev

# This opens http://localhost:3030 in your browser
```

## Exporting Slides

```bash
# Export to PDF (default)
npm run export

# Export to PNG (one image per slide)
npm run export-png

# Export to PPTX (PowerPoint)
npm run export-pptx
```

Note: First export may take longer as it downloads Playwright/Chromium for rendering.

## Troubleshooting

### "slidev: command not found"
Ensure you've run `npm install` in the presentation directory.

### Playwright installation issues
```bash
npx playwright install chromium
```

### Port 3030 already in use
```bash
npx slidev slides.md --port 3031
```

### Images not loading
Verify image paths in content.md are relative to the slides.md location.
