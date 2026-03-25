#!/bin/bash

# Package anything-to-notebooklm skill for sharing
# Creates a slim tar.gz without large files

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="anything-to-notebooklm"
OUTPUT_DIR="${1:-$HOME/Desktop}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/${SKILL_NAME}_${TIMESTAMP}.tar.gz"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Packaging ${SKILL_NAME} Skill${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Files to include
FILES=(
    "SKILL.md"
    "COMMANDS.md"
    "EXAMPLES.md"
    "ERRORS.md"
    "README.md"
    "install.sh"
    "requirements.txt"
    ".gitignore"
)

DIRS=(
    "scripts"
)

# Create temp directory
TEMP_DIR=$(mktemp -d)
TEMP_SKILL="$TEMP_DIR/$SKILL_NAME"
mkdir -p "$TEMP_SKILL"

echo "📦 Packaging files..."

# Copy files
for file in "${FILES[@]}"; do
    if [ -f "$SKILL_DIR/$file" ]; then
        cp "$SKILL_DIR/$file" "$TEMP_SKILL/"
        echo "  ✓ $file"
    fi
done

# Copy directories
for dir in "${DIRS[@]}"; do
    if [ -d "$SKILL_DIR/$dir" ]; then
        cp -r "$SKILL_DIR/$dir" "$TEMP_SKILL/"
        echo "  ✓ $dir/"
    fi
done

# Create tar.gz
cd "$TEMP_DIR"
tar -czf "$OUTPUT_FILE" "$SKILL_NAME"

# Cleanup
rm -rf "$TEMP_DIR"

# Show results
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo ""
echo -e "${GREEN}✅ Package created successfully!${NC}"
echo ""
echo "📦 File: $OUTPUT_FILE"
echo "📊 Size: $FILE_SIZE"
echo ""
echo "📤 Sharing instructions:"
echo "  After receiving this file, run:"
echo "    cd ~/.claude/skills/"
echo "    tar -xzf ${SKILL_NAME}_${TIMESTAMP}.tar.gz"
echo "    cd ${SKILL_NAME}"
echo "    ./install.sh"
echo ""
echo "💡 Note: wexin-read-mcp is auto-cloned during install, no need to package it"
echo ""
