# CLI Command Reference

Full reference for `notebooklm` CLI (notebooklm-py v0.3.4+).

## Contents
- [Global options and env vars](#global-options-and-env-vars)
- [Session and notebook commands](#session-and-notebook-commands)
- [Source management](#source-management)
- [Generation commands](#generation-commands)
- [Artifact management](#artifact-management)
- [Download commands](#download-commands)
- [Chat and research](#chat-and-research)

---

## Global options and env vars

```
notebooklm [--storage PATH] [-v|-vv] [--version] COMMAND
```

| Option | Description | Default |
|--------|-------------|---------|
| `--storage PATH` | Override auth file location | `~/.notebooklm/storage_state.json` |
| `-v` / `-vv` | Logging verbosity (INFO / DEBUG) | off |
| `--version` | Show version and exit | |

| Environment variable | Purpose |
|---------------------|---------|
| `NOTEBOOKLM_HOME` | Base directory for all config files (default: `~/.notebooklm/`) |
| `NOTEBOOKLM_AUTH_JSON` | Inline auth JSON for CI/CD (no file writes needed) |
| `NOTEBOOKLM_DEBUG_RPC` | Set to `1` for RPC debug logging |

Config files inside `NOTEBOOKLM_HOME`:
- `storage_state.json` — Chromium session cookies (login)
- `context.json` — active notebook ID and conversation
- `browser_profile/` — persistent Chromium profile

---

## Session and notebook commands

```bash
notebooklm login                         # browser-based Google auth (saves session)
notebooklm status                        # check auth + current context
notebooklm list [--json]                 # list all notebooks
notebooklm create "Title" [--json]       # create notebook + set context
notebooklm use {notebook_id}             # set current notebook context
notebooklm clear                         # clear current context
notebooklm rename {notebook_id} "Title"  # rename notebook
notebooklm delete {notebook_id} [-y]     # delete notebook (-y skips confirmation)
```

`--json` output for `create`:
```json
{"notebook": {"id": "nb_abc123...", "title": "...", "created_at": "..."}}
```

**Partial ID support**: All commands accepting IDs support prefix matching (type 4–6 chars of the UUID prefix; CLI resolves uniquely or lists ambiguous matches).

---

## Source management

```bash
notebooklm source list [-n NB_ID] [--json]
notebooklm source add CONTENT [-n NB_ID] [--type TYPE] [--title TITLE] [--wait] [--json]
notebooklm source add-drive DRIVE_URL [-n NB_ID] [--json]
notebooklm source add-research "query" [-n NB_ID] [--json]
notebooklm source get SOURCE_ID [-n NB_ID] [--json]
notebooklm source delete SOURCE_ID [-n NB_ID] [-y]
notebooklm source rename SOURCE_ID "Title" [-n NB_ID]
notebooklm source refresh SOURCE_ID [-n NB_ID]   # re-fetch URL/Drive source
notebooklm source wait SOURCE_ID [-n NB_ID] [--timeout 120] [--json]
notebooklm source fulltext SOURCE_ID [-n NB_ID]  # get indexed text content
notebooklm source guide SOURCE_ID [-n NB_ID]     # AI-generated summary of source
notebooklm source stale SOURCE_ID [-n NB_ID]     # check if source needs refresh
```

`source add` auto-detects type from CONTENT:
- `https://youtube.com/...` → `youtube`
- `https://...` → `url`
- existing file path → `file`
- anything else → `text` (inline pasted content)

Override with `--type [url|youtube|file|text]`.

Source status lifecycle: `PREPARING` → `PROCESSING` → `READY` (or `FAILED`)

`source wait` exit codes: `0` = ready, `1` = failed/not found, `2` = timeout

`--json` output for `source add`:
```json
{"source_id": "src_...", "title": "...", "status": "processing"}
```

---

## Generation commands

All generation commands share these options:
- `-n, --notebook ID` — notebook ID (uses context if omitted)
- `-s, --source ID` — limit to specific source(s), repeatable (default: all)
- `--language LANG` — output language code (default: `en`)
- `--wait` — block until generation completes
- `--json` — return task info as JSON immediately
- `--retry N` — retry on rate limits with exponential backoff

```bash
notebooklm generate audio [--format FORMAT] [--length LENGTH] [-s SRC] [--wait]
notebooklm generate video [--format FORMAT] [--style STYLE] [-s SRC] [--wait]
notebooklm generate report ["custom prompt"] [--format FORMAT] [-s SRC] [--wait]
notebooklm generate slide-deck [--format FORMAT] [--length LENGTH] [-s SRC] [--wait]
notebooklm generate quiz [--difficulty DIFF] [--quantity QTY] [-s SRC] [--wait]
notebooklm generate flashcards [--difficulty DIFF] [--quantity QTY] [-s SRC] [--wait]
notebooklm generate infographic [--orientation ORI] [--detail DETAIL] [-s SRC] [--wait]
notebooklm generate data-table "description" [-s SRC] [--wait]
notebooklm generate mind-map [-s SRC]   # synchronous, no --wait needed
```

### Option values

| Command | Option | Values |
|---------|--------|--------|
| `audio` | `--format` | `deep-dive` (default), `brief`, `critique`, `debate` |
| `audio` | `--length` | `short`, `default`, `long` |
| `video` | `--format` | `explainer`, `brief` |
| `video` | `--style` | `auto`, `classic`, `whiteboard`, `kawaii`, `anime`, `watercolor`, `retro-print`, `heritage`, `paper-craft` |
| `report` | `--format` | `briefing-doc`, `study-guide`, `blog-post`, `custom` |
| `slide-deck` | `--format` | `detailed`, `presenter` |
| `slide-deck` | `--length` | `default`, `short` |
| `quiz` / `flashcards` | `--difficulty` | `easy`, `medium`, `hard` |
| `quiz` / `flashcards` | `--quantity` | `fewer`, `standard`, `more` |
| `infographic` | `--orientation` | `landscape`, `portrait`, `square` |
| `infographic` | `--detail` | `concise`, `standard`, `detailed` |

`--json` output for generation commands:
```json
{"task_id": "task_abc123...", "status": "pending"}
```

---

## Artifact management

```bash
notebooklm artifact list [-n NB_ID] [--type TYPE] [--json]
notebooklm artifact get ARTIFACT_ID [-n NB_ID] [--json]
notebooklm artifact poll TASK_ID [-n NB_ID] [--json]    # single status check (non-blocking)
notebooklm artifact wait ARTIFACT_ID [-n NB_ID] [--timeout 300] [--interval 2] [--json]
notebooklm artifact delete ARTIFACT_ID [-n NB_ID] [-y]
notebooklm artifact rename ARTIFACT_ID "New Title" [-n NB_ID]
notebooklm artifact export ARTIFACT_ID --title "Title" [--type docs|sheets] [-n NB_ID]
notebooklm artifact suggestions [-n NB_ID] [--json]
```

`--type` filter for `artifact list`: `all`, `audio`, `video`, `slide-deck`, `quiz`, `flashcard`, `infographic`, `data-table`, `mind-map`, `report`

`artifact wait` exit codes: `0` = completed, `1` = failed or timeout

`artifact export` sends to Google Drive; `--type docs` (default) → Google Docs, `--type sheets` → Google Sheets.

Mind maps cannot be renamed. Mind map deletion clears content but Google may garbage collect later.

---

## Download commands

```bash
notebooklm download audio PATH [-n NB_ID] [-a ARTIFACT_ID]
notebooklm download video PATH [-n NB_ID] [-a ARTIFACT_ID]
notebooklm download slide-deck PATH [-n NB_ID] [-a ARTIFACT_ID]
notebooklm download quiz PATH [--format json|markdown] [-n NB_ID] [-a ARTIFACT_ID]
notebooklm download flashcards PATH [--format json|markdown] [-n NB_ID] [-a ARTIFACT_ID]
notebooklm download infographic PATH [-n NB_ID] [-a ARTIFACT_ID]
notebooklm download data-table PATH [-n NB_ID] [-a ARTIFACT_ID]   # outputs CSV (UTF-8 BOM)
notebooklm download mind-map PATH [-n NB_ID] [-a ARTIFACT_ID]     # outputs JSON
notebooklm download report PATH [-n NB_ID] [-a ARTIFACT_ID]
```

Without `-a`, downloads the most recent artifact of that type. Specify `-a ARTIFACT_ID` to target a specific one.

---

## Chat and research

```bash
notebooklm ask "question" [-n NB_ID] [--json]    # single Q&A with citations
notebooklm chat [-n NB_ID]                        # interactive multi-turn conversation
notebooklm research "query" [-n NB_ID] [--json]  # web/Drive research agent
```

`ask` output includes answer text and citation references (source title + page/timestamp).
