#!/bin/bash

# anything-to-notebooklm Skill Installer
# Automatically installs all dependencies and guides environment setup

set -e  # Exit immediately on error

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="anything-to-notebooklm"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Multi-Source -> NotebookLM Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Check Python version and detect package manager
echo -e "${YELLOW}[1/6] Checking Python environment...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 not found. Please install Python 3.10+ first.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_VERSION="3.10"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${RED}❌ Python version too low (current: $PYTHON_VERSION, required: 3.10+)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python $PYTHON_VERSION${NC}"

# Prefer uv for faster, isolated installs; fall back to pip3
if command -v uv &> /dev/null; then
    INSTALLER="uv pip install"
    echo -e "${GREEN}✅ uv detected — using uv for package installation${NC}"
else
    INSTALLER="pip3 install"
    echo -e "${YELLOW}⚠️  uv not found — falling back to pip3 (consider: curl -LsSf https://astral.sh/uv/install.sh | sh)${NC}"
fi

# 2. Check and clone wexin-read-mcp
echo ""
echo -e "${YELLOW}[2/6] Installing MCP server...${NC}"
MCP_DIR="$SKILL_DIR/wexin-read-mcp"

if [ -d "$MCP_DIR" ]; then
    echo -e "${GREEN}✅ MCP server already exists${NC}"
else
    echo "Cloning wexin-read-mcp..."
    git clone https://github.com/Bwkyd/wexin-read-mcp.git "$MCP_DIR"
    echo -e "${GREEN}✅ MCP server cloned successfully${NC}"
fi

# 3. Install Python dependencies
echo ""
echo -e "${YELLOW}[3/6] Installing Python dependencies...${NC}"

# Install MCP server dependencies
if [ -f "$MCP_DIR/requirements.txt" ]; then
    echo "Installing MCP dependencies..."
    $INSTALLER -r "$MCP_DIR/requirements.txt" -q
    echo -e "${GREEN}✅ MCP dependencies installed${NC}"
fi

# Install Skill dependencies (including markitdown)
if [ -f "$SKILL_DIR/requirements.txt" ]; then
    echo "Installing Skill dependencies (including markitdown converter)..."
    $INSTALLER -r "$SKILL_DIR/requirements.txt" -q
    echo -e "${GREEN}✅ Skill dependencies installed${NC}"
    echo -e "${GREEN}✅ markitdown installed (supports 15+ file formats)${NC}"
fi

# 4. Install Playwright browser
echo ""
echo -e "${YELLOW}[4/6] Installing Playwright browser...${NC}"
echo "This may take a few minutes. Please wait..."

if python3 -c "from playwright.sync_api import sync_playwright" 2>/dev/null; then
    playwright install chromium
    echo -e "${GREEN}✅ Playwright browser installed${NC}"
else
    echo -e "${RED}❌ Playwright import failed. Please check installation.${NC}"
    exit 1
fi

# 5. Check and install notebooklm
echo ""
echo -e "${YELLOW}[5/6] Checking NotebookLM CLI...${NC}"

if command -v notebooklm &> /dev/null; then
    NOTEBOOKLM_VERSION=$(notebooklm --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ NotebookLM CLI installed ($NOTEBOOKLM_VERSION)${NC}"
else
    echo "Installing notebooklm-py..."
    $INSTALLER notebooklm-py -q

    if command -v notebooklm &> /dev/null; then
        echo -e "${GREEN}✅ NotebookLM CLI installed successfully${NC}"
    else
        echo -e "${RED}❌ NotebookLM CLI installation failed${NC}"
        echo "Install manually: uv pip install notebooklm-py   (or: pip install notebooklm-py)"
        exit 1
    fi
fi

# 6. Configuration guidance
echo ""
echo -e "${YELLOW}[6/6] Configuration guide${NC}"
echo ""

CLAUDE_CONFIG="$HOME/.claude/config.json"
CONFIG_SNIPPET="    \"weixin-reader\": {
      \"command\": \"python\",
      \"args\": [
        \"$MCP_DIR/src/server.py\"
      ]
    }"

echo -e "${BLUE}📝 Next step: Configure MCP server${NC}"
echo ""
echo "Edit: $CLAUDE_CONFIG"
echo ""
echo "Add this under \"mcpServers\":"
echo -e "${GREEN}$CONFIG_SNIPPET${NC}"
echo ""
echo "Full config example:"
echo -e "${GREEN}{
  \"primaryApiKey\": \"any\",
  \"mcpServers\": {
$CONFIG_SNIPPET
  }
}${NC}"
echo ""

# Check if already configured
if [ -f "$CLAUDE_CONFIG" ]; then
    if grep -q "weixin-reader" "$CLAUDE_CONFIG"; then
        echo -e "${GREEN}✅ Existing weixin-reader config detected${NC}"
    else
        echo -e "${YELLOW}⚠️  weixin-reader config not found. Please add it manually.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Claude config file not found. Please create it manually.${NC}"
fi

echo ""
echo -e "${BLUE}🔐 NotebookLM Authentication${NC}"
echo ""
echo "Before first use, run:"
echo -e "${GREEN}  notebooklm login${NC}"
echo -e "${GREEN}  notebooklm list  # verify authentication success${NC}"
echo ""

# Final summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "📦 Install path: $SKILL_DIR"
echo ""
echo "⚠️  Important reminders:"
echo "  1. Restart Claude Code after MCP server configuration"
echo "  2. Run notebooklm login before first use"
echo ""
echo "🚀 Usage example:"
echo "  Turn this article into a podcast https://mp.weixin.qq.com/s/xxx"
echo ""
