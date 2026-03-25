---
name: anything-to-notebooklm
description: Fetches content from WeChat articles, webpages, YouTube, PDFs, Office docs, ebooks, images, audio, CSV, ZIP, and search queries, then uploads to NotebookLM and generates podcasts, videos, slides, quizzes, flashcards, mind maps, infographics, data tables, or reports. Use when a user wants to upload any content to NotebookLM or generate AI study materials from any source.
argument-hint: "[URL, file path, or search keywords] [optional: podcast|slides|quiz|flashcards|mind-map|report|infographic|video]"
---

# Multi-Source Content → NotebookLM

## Prerequisites

### 1. NotebookLM authentication (required)
```bash
notebooklm login        # opens Chromium for Google sign-in
notebooklm list         # verify (session valid 1–2 weeks)
```

### 2. Install dependencies
```bash
# Preferred: uv (fast, isolated)
uv pip install notebooklm-py "markitdown[all]" playwright
playwright install chromium

# Alternative: pip
pip install notebooklm-py "markitdown[all]" playwright
playwright install chromium
```

### 3. WeChat MCP server (only needed for WeChat articles)
Run `install.sh` then add to `~/.claude/config.json`:
```json
{
  "mcpServers": {
    "weixin-reader": {
      "command": "python",
      "args": ["~/.claude/skills/anything-to-notebooklm/wexin-read-mcp/src/server.py"]
    }
  }
}
```
Restart Claude Code after config changes.

### 4. CI/CD / headless environments
```bash
export NOTEBOOKLM_AUTH_JSON='{"cookies": {...}}'   # skip login, no file writes
export NOTEBOOKLM_HOME=~/custom-dir                # override ~/.notebooklm/
```

---

## Source detection

| Input pattern | Source type | Processing |
|--------------|-------------|------------|
| `https://mp.weixin.qq.com/s/...` | WeChat article | `weixin-reader:read_weixin_article` → TXT |
| `https://youtube.com/...` or `youtu.be/...` | YouTube | pass URL directly to NotebookLM |
| `https://` or `http://` | Webpage | pass URL directly to NotebookLM |
| Google Docs/Slides/Sheets link | Google Drive | `notebooklm source add-drive [URL]` |
| `/path/to/file.pdf` | PDF | `markitdown` → TXT (OCR if scanned) |
| `/path/to/file.epub` | EPUB | `markitdown` → TXT |
| `/path/to/file.docx` | Word | `markitdown` → TXT |
| `/path/to/file.pptx` | PowerPoint | `markitdown` → TXT |
| `/path/to/file.xlsx` | Excel | `markitdown` → TXT |
| `/path/to/file.md` | Markdown | upload directly |
| `/path/to/file.csv` / `.json` / `.xml` | Structured data | `markitdown` → TXT |
| `/path/to/image.jpg` (jpg/png/gif/webp) | Image | `markitdown` OCR → TXT |
| `/path/to/audio.mp3` (mp3/wav) | Audio | `markitdown` transcription → TXT |
| `/path/to/archive.zip` | ZIP | extract → `markitdown` batch → TXT |
| keyword text (no URL or path) | Search query | WebSearch → summarize → TXT |

---

## Core workflow

### Step 1 — Fetch / convert content

**WeChat article**: Call `weixin-reader:read_weixin_article` (returns title, author, publish_time, content). Save to `/tmp/weixin_{title}_{timestamp}.txt`.

**Webpage / YouTube / Google Drive**: Pass URL directly — NotebookLM handles extraction.

**Local file** (PDF, EPUB, DOCX, PPTX, XLSX, CSV, images, audio):
```bash
markitdown /path/to/file.pdf -o /tmp/converted_{timestamp}.txt
```

**Search keywords**: Use WebSearch, summarize top 3–5 results, save to `/tmp/search_{query}_{timestamp}.txt`.

### Step 2 — Create notebook and add sources
```bash
notebooklm create "{title}"                       # creates notebook + sets context
notebooklm source add /tmp/converted.txt           # file upload (auto-detects type)
notebooklm source add "https://example.com/..."    # URL (auto-detects type)
notebooklm source add-drive "https://docs.google.com/..."
```

Use `--json` for scripting to capture IDs:
```bash
NB_ID=$(notebooklm create "Title" --json | python3 -c "import sys,json; print(json.load(sys.stdin)['notebook']['id'])")
```

### Step 3 — Wait for source processing

⚠️ Sources start as `PREPARING` and take 30 seconds–10 minutes to become `READY`. Never generate before sources are ready.

```bash
notebooklm source add /tmp/file.txt --wait         # block until READY (recommended)
# or after the fact:
notebooklm source wait {source_id} --timeout 600
# verify all ready:
notebooklm source list
```

### Step 4 — Generate output

All generation commands support: `-n NOTEBOOK_ID`, `-s SOURCE_ID` (repeatable), `--language LANG`, `--wait`, `--json`, `--retry N`.

| Intent | Command | Key options |
|--------|---------|-------------|
| podcast / audio | `notebooklm generate audio --wait` | `--format [deep-dive\|brief\|critique\|debate]`, `--length [short\|default\|long]` |
| video | `notebooklm generate video --wait` | `--format [explainer\|brief]`, `--style [auto\|classic\|whiteboard\|kawaii\|anime\|watercolor\|retro-print\|heritage\|paper-craft]` |
| report / briefing | `notebooklm generate report --wait` | `--format [briefing-doc\|study-guide\|blog-post\|custom]` |
| slide deck | `notebooklm generate slide-deck --wait` | `--format [detailed\|presenter]`, `--length [default\|short]` |
| quiz | `notebooklm generate quiz --wait` | `--difficulty [easy\|medium\|hard]`, `--quantity [fewer\|standard\|more]` |
| flashcards | `notebooklm generate flashcards --wait` | `--difficulty [easy\|medium\|hard]`, `--quantity [fewer\|standard\|more]` |
| infographic | `notebooklm generate infographic --wait` | `--orientation [landscape\|portrait\|square]`, `--detail [concise\|standard\|detailed]` |
| data table | `notebooklm generate data-table "description" --wait` | description (required) |
| mind map | `notebooklm generate mind-map` | synchronous — no `--wait` needed |

Non-blocking pattern (for parallel generation):
```bash
TASK=$(notebooklm generate audio --json | python3 -c "import sys,json; print(json.load(sys.stdin)['task_id'])")
notebooklm artifact wait $TASK --timeout 1800
```

### Step 5 — Download results

```bash
notebooklm download audio ./output.mp3
notebooklm download video ./output.mp4
notebooklm download slide-deck ./slides.pdf
notebooklm download quiz ./quiz.md --format markdown
notebooklm download flashcards ./cards.md --format markdown
notebooklm download infographic ./info.png
notebooklm download data-table ./data.csv
notebooklm download mind-map ./map.json
notebooklm download report ./report.md

# Export to Google Drive:
notebooklm artifact export {artifact_id} --title "Title" --type docs    # Google Docs
notebooklm artifact export {artifact_id} --title "Title" --type sheets  # Google Sheets
```

---

## Natural language → output type

| User says | Output type |
|-----------|-------------|
| "podcast" / "audio" / "audio overview" | `generate audio` |
| "slides" / "slide deck" / "presentation" | `generate slide-deck` |
| "mind map" / "concept map" | `generate mind-map` |
| "quiz" / "test" / "questions" | `generate quiz` |
| "flashcards" / "study cards" / "memory cards" | `generate flashcards` |
| "video" / "video overview" | `generate video` |
| "report" / "summary" / "briefing doc" / "study guide" / "blog post" | `generate report` |
| "infographic" / "visualize" | `generate infographic` |
| "data table" / "table" / "extract data" | `generate data-table` |

If no generation intent is stated, upload sources only and wait for follow-up.

---

## Common patterns

### Add to existing notebook
```bash
notebooklm list                        # find notebook
notebooklm use {notebook_id}           # set context
notebooklm source add {content} --wait
```

### Query notebook content (no artifact)
```bash
notebooklm ask "What are the key findings?"   # single question + citations
notebooklm chat                               # interactive multi-turn
```

### AI-suggested report topics
```bash
notebooklm artifact suggestions
# → list of topics; use: notebooklm generate report "<suggested prompt>"
```

### Add web search results as sources
```bash
notebooklm source add-research "2026 AI benchmarks"
```

### Multiple outputs from one source
```bash
notebooklm generate audio --wait && notebooklm download audio ./podcast.mp3
notebooklm generate quiz --wait  && notebooklm download quiz ./quiz.md --format markdown
```

---

## Generation timing

| Artifact | Typical time | Notes |
|----------|-------------|-------|
| mind-map | instant | synchronous |
| quiz / flashcards | 1–3 min | |
| report / data-table / infographic / slide-deck | 2–5 min | |
| audio | 10–20 min | async |
| video | 15–45 min | async |

---

## Error quick reference

| Error | Fix |
|-------|-----|
| Auth failed | `notebooklm login` |
| Source stuck in PROCESSING | `notebooklm source wait {id} --timeout 600` |
| No notebook context | `notebooklm use {id}` or add `-n {id}` |
| Rate limited | Add `--retry 3` to generate command |
| Generation failed | Check `notebooklm source list` — all sources must be READY |
| `notebooklm` not found | `uv pip install notebooklm-py` |
| WeChat fetch failed | Retry after 2–3s; or paste text manually |

See [ERRORS.md](ERRORS.md) for detailed troubleshooting, exit codes, and recovery steps.

---

## Reference files

- **[COMMANDS.md](COMMANDS.md)** — full CLI reference: all notebook, source, artifact, chat, download commands
- **[EXAMPLES.md](EXAMPLES.md)** — end-to-end examples for all source types (WeChat, YouTube, PDF, EPUB, mixed, etc.)
- **[ERRORS.md](ERRORS.md)** — detailed error handling, troubleshooting, and exit codes

## Utility scripts

- **`scripts/check_env.py`** — validates all dependencies are installed and auth is configured:
  ```bash
  python ${CLAUDE_SKILL_DIR}/scripts/check_env.py
  ```
- **`scripts/package.sh`** — packages the skill for distribution:
  ```bash
  bash ${CLAUDE_SKILL_DIR}/scripts/package.sh [output_dir]
  ```
