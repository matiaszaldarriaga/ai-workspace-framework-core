#!/bin/bash
# Preview a Slidev presentation
# Usage: preview.sh <presentation_path>
#
# Example:
#   ./preview.sh projects/gw231123-spin/explorations/ml-progressive-iob-v2/presentations/results-2026-01

set -e

# Resolve the actual script location (following symlinks)
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get presentation path (absolute or relative to workspace)
PRES_PATH="$1"
PORT="${2:-3030}"

if [ -z "$PRES_PATH" ]; then
    echo "Usage: preview.sh <presentation_path> [port]"
    echo "Example: preview.sh projects/my-project/presentations/my-pres"
    exit 1
fi

# Make path absolute if relative
if [[ "$PRES_PATH" != /* ]]; then
    PRES_PATH="$WORKSPACE_ROOT/$PRES_PATH"
fi

# Check slides.md exists
if [ ! -f "$PRES_PATH/slides.md" ]; then
    echo "Error: $PRES_PATH/slides.md not found"
    exit 1
fi

# Source conda
source ~/anaconda3/etc/profile.d/conda.sh 2>/dev/null || \
source ~/miniforge3/etc/profile.d/conda.sh 2>/dev/null || \
source ~/miniconda3/etc/profile.d/conda.sh 2>/dev/null || \
{ echo "Error: Could not find conda"; exit 1; }

conda activate slidev

# Install dependencies if needed
if [ ! -d "$PRES_PATH/node_modules" ]; then
    echo "Installing dependencies..."
    cd "$PRES_PATH"
    npm install
fi

cd "$PRES_PATH"

# Start slidev in background
echo "Starting Slidev server..."
npx slidev slides.md --port "$PORT" &
SLIDEV_PID=$!

# Wait for server to be ready (up to 30 seconds)
echo "Waiting for server to start..."
for i in {1..30}; do
    if curl -s -o /dev/null http://localhost:$PORT 2>/dev/null; then
        echo "Server ready at http://localhost:$PORT"
        open "http://localhost:$PORT"
        break
    fi
    sleep 1
done

# Keep script running and show how to stop
echo ""
echo "Press Ctrl+C to stop the server"
wait $SLIDEV_PID
