#!/usr/bin/env python3
"""
Environment check script for validating all anything-to-notebooklm dependencies.
"""

import sys
import json
from pathlib import Path

# Color output
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"


def print_status(status, message):
    """Print status message."""
    if status == "ok":
        print(f"{GREEN}✅ {message}{NC}")
    elif status == "warning":
        print(f"{YELLOW}⚠️  {message}{NC}")
    elif status == "error":
        print(f"{RED}❌ {message}{NC}")
    else:
        print(f"{BLUE}ℹ️  {message}{NC}")


def check_python_version():
    """Check Python version."""
    version = sys.version_info
    version_str = f"{version.major}.{version.minor}.{version.micro}"

    if (version.major, version.minor) >= (3, 10):
        print_status("ok", f"Python {version_str}")
        return True
    print_status("error", f"Python {version_str} (requires 3.10+)")
    return False


def check_module(module_name, import_name=None):
    """Check whether a Python module is installed."""
    if import_name is None:
        import_name = module_name

    try:
        __import__(import_name)
        print_status("ok", f"{module_name} is installed")
        return True
    except ImportError:
        print_status("error", f"{module_name} is not installed")
        return False


def check_command(cmd):
    """Check whether a command is available."""
    import shutil

    if shutil.which(cmd):
        # Try reading version info
        import subprocess

        try:
            result = subprocess.run(
                [cmd, "--version"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            version = result.stdout.split("\n")[0] if result.stdout else "unknown"
            print_status("ok", f"{cmd} is installed ({version})")
        except Exception:
            print_status("ok", f"{cmd} is installed")
        return True

    print_status("error", f"{cmd} not found")
    return False


def check_mcp_config():
    """Check MCP configuration."""
    config_path = Path.home() / ".claude" / "config.json"

    if not config_path.exists():
        print_status("error", f"Claude config file not found: {config_path}")
        return False

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)

        if "mcpServers" in config and "weixin-reader" in config["mcpServers"]:
            print_status("ok", "MCP server is configured")
            return True

        print_status("warning", "MCP server is not configured (manual setup required)")
        return False
    except Exception as e:
        print_status("error", f"Failed to read config file: {e}")
        return False


def check_mcp_server():
    """Check MCP server file."""
    skill_dir = Path(__file__).parent.parent
    mcp_server = skill_dir / "wexin-read-mcp" / "src" / "server.py"

    if mcp_server.exists():
        print_status("ok", "MCP server file exists")
        return True

    print_status("error", f"MCP server file not found: {mcp_server}")
    return False


def check_notebooklm_auth():
    """Check NotebookLM authentication status."""
    import subprocess

    try:
        result = subprocess.run(
            ["notebooklm", "list"],
            capture_output=True,
            text=True,
            timeout=10,
        )

        if result.returncode == 0:
            print_status("ok", "NotebookLM is authenticated")
            return True

        print_status(
            "warning", "NotebookLM is not authenticated (run notebooklm login)"
        )
        return False
    except subprocess.TimeoutExpired:
        print_status("warning", "NotebookLM auth check timed out")
        return False
    except Exception as e:
        print_status("error", f"NotebookLM auth check failed: {e}")
        return False


def main():
    print(f"\n{BLUE}========================================{NC}")
    print(f"{BLUE}  Environment Check - anything-to-notebooklm{NC}")
    print(f"{BLUE}========================================{NC}\n")

    results = []

    # 1. Python version
    print(f"{YELLOW}[1/9] Python version{NC}")
    results.append(check_python_version())
    print()

    # 2. Core dependencies
    print(f"{YELLOW}[2/9] Core Python dependencies{NC}")
    results.append(check_module("fastmcp"))
    results.append(check_module("playwright"))
    results.append(check_module("beautifulsoup4", "bs4"))
    results.append(check_module("lxml"))
    results.append(check_module("markitdown"))
    print()

    # 3. Playwright importability
    print(f"{YELLOW}[3/9] Playwright importability{NC}")
    try:
        import importlib.util

        if importlib.util.find_spec("playwright.sync_api") is not None:
            print_status("ok", "Playwright imports correctly")
            results.append(True)
        else:
            print_status("error", "Playwright import failed: module not found")
            results.append(False)
    except Exception as e:
        print_status("error", f"Playwright import failed: {e}")
        results.append(False)
    print()

    # 4. NotebookLM CLI
    print(f"{YELLOW}[4/9] NotebookLM CLI{NC}")
    results.append(check_command("notebooklm"))
    print()

    # 5. markitdown CLI
    print(f"{YELLOW}[5/9] markitdown CLI{NC}")
    results.append(check_command("markitdown"))
    print()

    # 6. Git command
    print(f"{YELLOW}[6/9] Git command{NC}")
    results.append(check_command("git"))
    print()

    # 7. MCP server file
    print(f"{YELLOW}[7/9] MCP server file{NC}")
    results.append(check_mcp_server())
    print()

    # 8. MCP config
    print(f"{YELLOW}[8/9] MCP configuration{NC}")
    results.append(check_mcp_config())
    print()

    # 9. NotebookLM authentication
    print(f"{YELLOW}[9/9] NotebookLM authentication{NC}")
    results.append(check_notebooklm_auth())
    print()

    # Summary
    print(f"{BLUE}========================================{NC}")
    passed = sum(results)
    total = len(results)

    if passed == total:
        print(
            f"{GREEN}✅ All checks passed ({passed}/{total}). Environment is fully configured.{NC}"
        )
    elif passed >= total * 0.8:
        print(
            f"{YELLOW}⚠️  Most checks passed ({passed}/{total}), but some issues need fixes.{NC}"
        )
    else:
        print(
            f"{RED}❌ Check failed ({passed}/{total}). Run install.sh to reinstall.{NC}"
        )

    print(f"{BLUE}========================================{NC}\n")

    if passed < total:
        print("💡 Suggested fixes:")
        print("  1. Run installer: ./install.sh")
        print("  2. Configure MCP: edit ~/.claude/config.json")
        print("  3. Authenticate NotebookLM: notebooklm login")
        print()

    sys.exit(0 if passed == total else 1)


if __name__ == "__main__":
    main()
