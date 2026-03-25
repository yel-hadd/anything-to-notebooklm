<div align="center">

# 🎯 Multi-Source Content -> NotebookLM Smart Processor

**Turn one sentence into a podcast, slides, mind map, quiz, and more...**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![GitHub stars](https://img.shields.io/github/stars/yel-hadd/anything-to-notebooklm?style=social)](https://github.com/yel-hadd/anything-to-notebooklm/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/yel-hadd/anything-to-notebooklm?style=social)](https://github.com/yel-hadd/anything-to-notebooklm/network/members)
[![GitHub issues](https://img.shields.io/github/issues/yel-hadd/anything-to-notebooklm)](https://github.com/yel-hadd/anything-to-notebooklm/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/yel-hadd/anything-to-notebooklm)](https://github.com/yel-hadd/anything-to-notebooklm/commits/main)

[Quick Start](#-quick-start) • [Supported Sources](#-supported-content-sources) • [Examples](#-usage-examples) • [FAQ](#-faq)

</div>

---

> This repository is a maintained fork of the original project by [joeseesun/anything-to-notebooklm](https://github.com/joeseesun/anything-to-notebooklm), with expanded English documentation, stricter setup guidance, and improved operational references.

## ✨ What is this?

A **Claude Code Skill** that lets you turn **any content** into **any output format** using natural language.

```
You say: Turn this WeChat article into a podcast
AI says: ✅ 8-minute podcast generated -> podcast.mp3

You say: Convert this EPUB book into a mind map
AI says: ✅ Mind map generated -> mindmap.json

You say: Turn this YouTube video into slides
AI says: ✅ 25-slide deck generated -> slides.pdf
```

**How it works**: Automatically fetch content from multiple sources -> upload to [Google NotebookLM](https://notebooklm.google.com/) -> generate your target format

## 🧩 What's new in this fork

- Complete English-first docs and examples for onboarding and collaboration
- Expanded reference docs: `COMMANDS.md`, `EXAMPLES.md`, and `ERRORS.md`
- Operational scripts consolidated under `scripts/` (`check_env.py`, `package.sh`)
- CI/headless support via `NOTEBOOKLM_AUTH_JSON` and `NOTEBOOKLM_HOME`
- Installation guidance with `uv` as the preferred package manager
- Setup aligned to `Python 3.10+` requirements enforced by `install.sh`

## 🚀 Supported Content Sources (15+ formats)

<table>
<tr>
<td width="50%">

### 📱 Social Media
- **WeChat Official Account articles** (anti-crawler bypass)
- **YouTube videos** (auto subtitle extraction)

### 🌐 Web
- **Any webpage** (news, blogs, docs)
- **Search keywords** (auto summarize top results)

### 📄 Office Documents
- **Word** (.docx)
- **PowerPoint** (.pptx)
- **Excel** (.xlsx)

</td>
<td width="50%">

### 📚 Ebooks & Documents
- **PDF** (OCR for scanned files)
- **EPUB** (ebooks)
- **Markdown** (.md)

### 🖼️ Images & Audio
- **Images** (JPEG/PNG/GIF, OCR)
- **Audio** (WAV/MP3, transcription)

### 📊 Structured Data
- **CSV/JSON/XML**
- **ZIP archives** (batch processing)

</td>
</tr>
</table>

**Powered by**: [Microsoft markitdown](https://github.com/microsoft/markitdown)

## 🎨 What can it generate?

| Output | Use case | Typical time | Trigger examples |
|--------|----------|--------------|------------------|
| 🎙️ **Podcast** | Learn while commuting | 10-20 min (async) | "generate a podcast", "make audio" |
| 📊 **Slides (PPT)** | Team sharing | 1-3 min | "make slides", "generate a deck" |
| 🗺️ **Mind map** | Structure understanding | instant (sync) | "draw a mind map", "generate a map" |
| 📝 **Quiz** | Self-test | 1-2 min | "generate a quiz", "ask me questions" |
| 🎬 **Video** | Visual explanation | 15-45 min (async) | "make a video" |
| 📄 **Report** | Deep analysis | 2-4 min | "generate a report", "summarize this" |
| 📈 **Infographic** | Data visualization | 2-3 min | "make an infographic" |
| 📋 **Flashcards** | Memory reinforcement | 1-2 min | "make flashcards" |
| 📊 **Data table** | Structured extraction | 2-5 min | "generate a data table", "extract fields" |

**Pure natural language. No command memorization needed.**

## ⚡ Quick Start

### Prerequisites

- ✅ Python 3.10+
- ✅ Git (preinstalled on macOS/Linux)

**That's it.** Everything else installs automatically.

### Install (3 steps)

```bash
# 1. Clone into Claude skills directory
cd ~/.claude/skills/
git clone https://github.com/yel-hadd/anything-to-notebooklm
cd anything-to-notebooklm

# 2. Install all dependencies in one step
./install.sh

# 3. Configure MCP as prompted, then restart Claude Code
```

### First run

```bash
# NotebookLM auth (one time only)
notebooklm login
notebooklm list  # verify success

# Environment check (optional)
python scripts/check_env.py
```

## 💡 Usage Examples

### Scenario 1: Fast learning - article -> podcast

```
You: Turn this article into a podcast https://mp.weixin.qq.com/s/abc123

AI automatically:
  ✓ Fetches WeChat article content
  ✓ Uploads to NotebookLM
  ✓ Generates podcast (typically 10-20 minutes)

✅ Output: /tmp/article_podcast.mp3 (8 min, 12.3 MB)
💡 Use case: Finish one deep article during your commute
```

### Scenario 2: Team sharing - ebook -> slides

```
You: Turn this book into slides /Users/joe/Books/sapiens.epub

AI automatically:
  ✓ Extracts ebook content (~150k words)
  ✓ Refines key points with AI
  ✓ Generates professional slides

✅ Output: /tmp/sapiens_slides.pdf (25 pages, 3.8 MB)
💡 Use case: Ready for book-club sharing
```

### Scenario 3: Self-test learning - video -> quiz

```
You: Generate a quiz from this YouTube video https://youtube.com/watch?v=abc

AI automatically:
  ✓ Extracts video subtitles
  ✓ Analyzes key knowledge points
  ✓ Generates questions automatically

✅ Output: /tmp/video_quiz.md (15 questions: 10 MCQ + 5 short answer)
💡 Use case: Check your learning retention
```

### Scenario 4: Information synthesis - multi-source -> report

```
You: Turn these sources into one report:
    - https://example.com/article1
    - https://youtube.com/watch?v=xyz
    - /Users/joe/research.pdf

AI automatically:
  ✓ Aggregates 3 different source types
  ✓ Performs integrated analysis
  ✓ Generates a combined report

✅ Output: /tmp/multi_source_report.md (7 sections, 15.2 KB)
💡 Use case: Comprehensive topic research
```

### Scenario 5: Document digitization - scan -> text

```
You: Convert this scanned image into a document /Users/joe/scan.jpg

AI automatically:
  ✓ OCRs text from image
  ✓ Extracts plain text
  ✓ Produces a structured document

✅ Output: /tmp/scan_document.txt (95%+ OCR accuracy)
💡 Use case: Digital archiving for scanned files
```

## 🎯 Core Features

### 🧠 Smart source detection
Automatically identifies input type, no manual flag required.

```
https://mp.weixin.qq.com/s/xxx   -> WeChat article
https://youtube.com/watch?v=xxx  -> YouTube video
/path/to/file.epub               -> EPUB ebook
"search 'AI trends'"             -> search query
```

### 🚀 Fully automated pipeline
From fetch to generation, end-to-end.

```
Input -> Fetch -> Convert -> Upload -> Generate -> Download
         ^____________ fully automated ____________^
```

### 🌐 Multi-source integration
Blend different source types in one output.

```
Article + Video + PDF + Search results -> Integrated report
```

### 🔒 Local-first handling
Sensitive data is processed locally first.

```
WeChat article -> local MCP fetch -> local conversion -> NotebookLM
```

## 📦 Technical Architecture

```
┌─────────────────────────────────────┐
│     User natural-language input     │
│ "Turn this article into podcast..." │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         Claude Code Skill           │
│  • Smart source-type detection      │
│  • Automatic tool routing           │
└──────────────┬──────────────────────┘
               │
      ┌────────┴────────┐
      │                 │
      ▼                 ▼
┌──────────┐     ┌─────────────┐
│ WeChat    │     │ Other formats│
│ MCP fetch │     │ markitdown   │
└─────┬────┘     └──────┬──────┘
      │                 │
      └────────┬────────┘
               │
               ▼
┌─────────────────────────────────────┐
│          NotebookLM API             │
│  • Upload sources                   │
│  • Generate target output           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│          Generated files            │
│      .mp3 / .pdf / .json / .md      │
└─────────────────────────────────────┘
```

## 🔧 Advanced Usage

### Use an existing notebook

```
Add this article to my [AI Research] notebook https://example.com
```

### Batch processing

```
Turn all of these into podcasts:
1. https://mp.weixin.qq.com/s/abc123
2. https://example.com/article2
3. /Users/joe/notes.md
```

### ZIP batch conversion

```
Turn all docs in this zip into podcasts /path/to/files.zip
```

Automatic unzip, detect, convert, and merge.

## 🐛 Troubleshooting

### MCP tool not found

```bash
# Test MCP server
python ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp/src/server.py

# Reinstall dependencies
cd ~/.claude/skills/anything-to-notebooklm/wexin-read-mcp
pip install -r requirements.txt
playwright install chromium
```

### NotebookLM authentication failed

```bash
notebooklm login     # log in again
notebooklm list      # verify
```

### Environment check

```bash
python scripts/check_env.py       # full 13-item check
./install.sh         # reinstall
```

## 🤝 Contributing

PRs, issues, and suggestions are welcome.

## ❓ FAQ

<details>
<summary><b>Q: What languages are supported?</b></summary>

A: NotebookLM supports multiple languages. Chinese and English currently perform best.
</details>

<details>
<summary><b>Q: Whose voice is used for podcasts?</b></summary>

A: Google AI speech synthesis. English usually uses two-host dialogue; Chinese is typically single-speaker narration.
</details>

<details>
<summary><b>Q: Content length limits?</b></summary>

A:
- Minimum: ~500 words
- Maximum: ~500,000 words
- Recommended: 1,000-10,000 words for best quality
</details>

<details>
<summary><b>Q: Can this be used commercially?</b></summary>

A:
- This Skill: MIT open source, free to use
- Generated output: follow NotebookLM Terms of Service
- Source material: follow original copyright rules
- Recommendation: personal learning/research usage
</details>

<details>
<summary><b>Q: Why is MCP required?</b></summary>

A: WeChat Official Account pages use anti-crawler protection, so MCP browser simulation is needed. Other sources (web pages, YouTube, PDF) do not require MCP.
</details>

## 📄 License

[MIT License](LICENSE)

## 🙏 Acknowledgements

- [Google NotebookLM](https://notebooklm.google.com/) - AI content generation
- [Microsoft markitdown](https://github.com/microsoft/markitdown) - file conversion
- [wexin-read-mcp](https://github.com/Bwkyd/wexin-read-mcp) - WeChat fetching
- [notebooklm-py](https://github.com/teng-lin/notebooklm-py) - NotebookLM CLI

### Apify MCP resources

Disclosure: Some links below are affiliate links (including `?fpr=use-apify`). If you sign up or purchase through them, I may earn a commission at no additional cost to you.

Apify's MCP offer is practical for production workflows: one MCP server can expose thousands of Actors/tools, supports hosted OAuth at `https://mcp.apify.com`, and includes a visual configurator for fast setup.

- Start with the official integration guide: [Apify MCP docs](https://docs.apify.com/platform/integrations/mcp)
- Explore ready-to-use MCP servers and tools: [Apify MCP catalog (affiliate)](https://apify.com/mcp?fpr=use-apify)
- Follow a step-by-step Claude Desktop setup with prompt examples: [Apify MCP + Claude Desktop guide](https://use-apify.com/blog/apify-mcp-claude-desktop)

## 📮 Contact

- **Issues**: [GitHub Issues](https://github.com/yel-hadd/anything-to-notebooklm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yel-hadd/anything-to-notebooklm/discussions)

---

<div align="center">

**If this helps, please give it a ⭐ Star!**

Fork maintained by [yel-hadd](https://github.com/yel-hadd), based on original work by [Joe](https://github.com/joeseesun).

</div>
