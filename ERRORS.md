# Error Handling and Troubleshooting

## Contents
- [Authentication errors](#authentication-errors)
- [Source errors](#source-errors)
- [Generation errors](#generation-errors)
- [Download errors](#download-errors)
- [WeChat / MCP errors](#wechat--mcp-errors)
- [Installation issues](#installation-issues)
- [Exit codes](#exit-codes)

---

## Authentication errors

### `NotebookLM authentication failed`
```
Error: Authentication failed
Checked: ~/.notebooklm/storage_state.json (not found or expired)
Checked: NOTEBOOKLM_AUTH_JSON env var (not set)
```
**Fix**: `notebooklm login` (opens Chromium for Google sign-in). Session lasts 1–2 weeks.

### Auth works on CLI but not in Claude Code
Cookies are stored in `~/.notebooklm/storage_state.json`. If running in a sandboxed env:
```bash
export NOTEBOOKLM_AUTH_JSON="$(cat ~/.notebooklm/storage_state.json)"
```

---

## Source errors

### Source stuck in `PROCESSING` or `PREPARING`
Sources take 30 seconds–10 minutes. Use:
```bash
notebooklm source wait {id} --timeout 600   # wait up to 10 min
notebooklm source list                       # check all statuses
```

### Source status `FAILED`
```bash
notebooklm source delete {id} --yes
# Then re-add. Possible causes:
# - File is password-protected, corrupted, or exceeds size limit
# - Unsupported encoding
# Convert first: markitdown /path/to/file.pdf -o /tmp/converted.txt
# Then: notebooklm source add /tmp/converted.txt --wait
```

### `SourceNotFoundError`
The source ID doesn't exist in the current notebook. Run `notebooklm source list` to see valid IDs.

### `Ambiguous ID 'abc' matches N sources`
Provide more characters of the UUID prefix (at least 6–8) to uniquely identify.

---

## Generation errors

### Generation fails immediately
```
Error: Artifact generation failed
```
Most common cause: sources are not READY yet.
```bash
notebooklm source list        # all sources must show READY
notebooklm source wait {id}   # wait for any still processing
```

### `No notebook context set`
```bash
notebooklm use {notebook_id}
# or: notebooklm generate audio -n {notebook_id} --wait
```

### `Rate limit exceeded`
```bash
notebooklm generate audio --retry 3 --wait   # retries with exponential backoff
# Max 3 concurrent generation tasks; wait for one to complete before starting another
```

### Generation task stuck (> 20 min for audio, > 60 min for video)
```bash
notebooklm artifact list       # check status
notebooklm artifact poll {id}  # single status check
# If still "pending": cancel not supported via CLI; use NotebookLM web UI to cancel
# Then retry: notebooklm generate audio --retry 3 --wait
```

### Content too short or too long
- Under ~100 words → low-quality or failed output; merge multiple short sources
- Over ~500,000 words → may fail; split the source file into parts

---

## Download errors

### `Artifact not found`
```bash
notebooklm artifact list --type audio    # find the correct artifact ID
notebooklm download audio ./out.mp3 -a {artifact_id}
```

### Download path error (directory doesn't exist)
```bash
mkdir -p ./output
notebooklm download audio ./output/podcast.mp3
```

---

## WeChat / MCP errors

### `MCP tool not found` / `weixin-reader:read_weixin_article not available`
1. Check MCP server is cloned: `ls ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp/`
2. Check `~/.claude/config.json` has `weixin-reader` in `mcpServers`
3. Restart Claude Code after any config change
4. Test the server directly:
   ```bash
   python ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp/src/server.py
   ```
5. If it fails, reinstall dependencies:
   ```bash
   cd ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp
   uv pip install -r requirements.txt   # or: pip install -r requirements.txt
   playwright install chromium
   ```

### WeChat article fetch failed
```
Error: Failed to fetch article content
```
Possible causes:
- Article deleted or requires login
- Anti-crawler blocked request

**Fix**: Retry after 2–3 seconds. If still failing, copy-paste article text and use:
```bash
notebooklm source add "pasted article text here" --title "Article Title" --wait
```

---

## Installation issues

### `notebooklm: command not found`
```bash
uv pip install notebooklm-py       # preferred
# or: pip install notebooklm-py
notebooklm --version               # verify
```

### `markitdown: command not found`
```bash
uv pip install "markitdown[all]"   # preferred
# or: pip install "markitdown[all]"
```

### markitdown OCR fails on scanned PDF
```bash
uv pip install "markitdown[pdf-ocr]"
# OCR requires system packages: tesseract-ocr
# Debian/Ubuntu: sudo apt install tesseract-ocr
# macOS: brew install tesseract
```

### `playwright install` fails or Chromium not found
```bash
playwright install chromium --with-deps   # installs system deps automatically
# If in a restricted env:
PLAYWRIGHT_BROWSERS_PATH=~/.playwright playwright install chromium
```

### Python version too old
notebooklm-py requires Python 3.10+. Check: `python3 --version`

---

## Exit codes

| Code | Meaning | Applicable commands |
|------|---------|---------------------|
| `0` | Success | all |
| `1` | Error (not found, failed, auth failure) | all |
| `2` | Timeout reached | `source wait`, `artifact wait` |

In shell scripts, check exit codes:
```bash
notebooklm source wait {id} --timeout 300
if [ $? -eq 2 ]; then
    echo "Source timed out — check status manually"
    notebooklm source list
fi

notebooklm generate audio --wait
if [ $? -ne 0 ]; then
    echo "Generation failed"
    notebooklm artifact list --type audio
fi
```
