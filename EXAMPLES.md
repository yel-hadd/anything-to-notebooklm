# End-to-End Examples

## Contents
- [WeChat article → podcast](#wechat-article--podcast)
- [YouTube video → mind map](#youtube-video--mind-map)
- [Search keywords → report](#search-keywords--report)
- [Mixed sources → slides](#mixed-sources--slides)
- [EPUB ebook → podcast](#epub-ebook--podcast)
- [Markdown → hard quiz](#markdown--hard-quiz)
- [Custom audio format + source selection](#custom-audio-format--source-selection)
- [Google Drive → flashcards](#google-drive--flashcards)
- [Scanned PDF → infographic](#scanned-pdf--infographic)
- [Multiple outputs from one source](#multiple-outputs-from-one-source)
- [Export to Google Docs](#export-to-google-docs)
- [Parallel generation (scripting)](#parallel-generation-scripting)

---

## WeChat article → podcast

**User**: `Turn this article into a podcast https://mp.weixin.qq.com/s/abc123xyz`

```bash
# 1. Fetch via MCP (weixin-reader:read_weixin_article)
#    → returns title, author, publish_time, content
#    → saved to /tmp/weixin_deep_learning_1711234567.txt

# 2. Create notebook and upload
notebooklm create "Future Trends in Deep Learning"
notebooklm source add /tmp/weixin_deep_learning_1711234567.txt --wait

# 3. Generate
notebooklm generate audio --format deep-dive --wait

# 4. Download
notebooklm download audio ./podcast.mp3
```

Output:
```
✅ WeChat article converted to podcast!
📄 Article: Future Trends in Deep Learning
👤 Author: John Doe  |  📅 2026-01-20
🎙️ deep-dive format  |  📁 ./podcast.mp3  |  ~8 min  |  12.3 MB
```

---

## YouTube video → mind map

**User**: `Generate a mind map from https://www.youtube.com/watch?v=abc123`

```bash
notebooklm create "Quantum Computing Overview"
notebooklm source add "https://www.youtube.com/watch?v=abc123" --wait
notebooklm generate mind-map          # synchronous
notebooklm download mind-map ./map.json
```

---

## Search keywords → report

**User**: `Search 'AI trend development 2026' and generate a report`

```bash
# 1. WebSearch → summarize top 5 results
#    → saved to /tmp/search_ai_trend_2026_1711234567.txt

notebooklm create "AI Trend Development 2026"
notebooklm source add /tmp/search_ai_trend_2026_1711234567.txt --wait
notebooklm generate report --format briefing-doc --wait
notebooklm download report ./report.md
```

---

## Mixed sources → slides

**User**:
```
Turn this article, this video, and this PDF into slides:
- https://example.com/article
- https://youtube.com/watch?v=xyz
- /home/user/Documents/research.pdf
```

```bash
notebooklm create "Multi-Source Research"

# Add all sources (URL/YouTube passed directly, PDF converted first)
notebooklm source add "https://example.com/article"
notebooklm source add "https://youtube.com/watch?v=xyz"
markitdown /home/user/Documents/research.pdf -o /tmp/research_1711234567.txt
notebooklm source add /tmp/research_1711234567.txt

# Wait for all to be ready before generating
notebooklm source list   # confirm all show READY

notebooklm generate slide-deck --format detailed --wait
notebooklm download slide-deck ./slides.pdf
```

---

## EPUB ebook → podcast

**User**: `Turn this ebook into a podcast /home/user/Books/sapiens.epub`

```bash
markitdown /home/user/Books/sapiens.epub -o /tmp/sapiens_1711234567.txt
notebooklm create "Sapiens - A Brief History of Humankind"
notebooklm source add /tmp/sapiens_1711234567.txt --wait
notebooklm generate audio --format deep-dive --length long --wait
notebooklm download audio ./sapiens_podcast.mp3
```

---

## Markdown → hard quiz

**User**: `Generate a hard quiz from /home/user/notes/machine_learning.md`

```bash
notebooklm create "Machine Learning Notes"
notebooklm source add /home/user/notes/machine_learning.md --wait
notebooklm generate quiz --difficulty hard --quantity standard --wait
notebooklm download quiz ./quiz.md --format markdown
```

---

## Custom audio format + source selection

**User**: `Create a debate-format podcast from only the first two sources in my AI notebook`

```bash
# Find notebook and sources
notebooklm list --json
notebooklm use {ai_notebook_id}
notebooklm source list --json
# → get source IDs

notebooklm generate audio --format debate -s {src_id_1} -s {src_id_2} --wait
notebooklm download audio ./debate.mp3
```

---

## Google Drive → flashcards

**User**: `Generate flashcards from this Google Doc https://docs.google.com/document/d/abc123`

```bash
notebooklm create "Study Flashcards"
notebooklm source add-drive "https://docs.google.com/document/d/abc123" --wait
notebooklm generate flashcards --difficulty medium --quantity more --wait
notebooklm download flashcards ./cards.md --format markdown
```

---

## Scanned PDF → infographic

**User**: `Make a portrait infographic from this scanned report /path/to/scan.pdf`

```bash
# markitdown runs OCR automatically on scanned PDFs
markitdown /path/to/scan.pdf -o /tmp/scan_ocr_1711234567.txt
notebooklm create "Scanned Report"
notebooklm source add /tmp/scan_ocr_1711234567.txt --wait
notebooklm generate infographic --orientation portrait --detail standard --wait
notebooklm download infographic ./infographic.png
```

---

## Multiple outputs from one source

**User**: `Generate both a podcast and flashcards from this article https://mp.weixin.qq.com/s/abc123`

```bash
# 1. Fetch + upload once
# (weixin-reader:read_weixin_article → /tmp/weixin_article.txt)
notebooklm create "Article Study Pack"
notebooklm source add /tmp/weixin_article.txt --wait

# 2. Generate sequentially
notebooklm generate audio --wait
notebooklm download audio ./podcast.mp3

notebooklm generate flashcards --wait
notebooklm download flashcards ./cards.md --format markdown
```

---

## Export to Google Docs

**User**: `Generate a study guide from this article and save it to Google Docs`

```bash
notebooklm create "Study Guide"
notebooklm source add "https://example.com/article" --wait
notebooklm generate report --format study-guide --wait

# Get artifact ID then export
ARTIFACT_ID=$(notebooklm artifact list --type report --json | python3 -c "import sys,json; print(json.load(sys.stdin)['artifacts'][0]['id'])")
notebooklm artifact export $ARTIFACT_ID --title "Study Guide" --type docs
```

---

## Parallel generation (scripting)

Start multiple generation tasks concurrently, then wait for all:

```bash
notebooklm create "Research Pack"
notebooklm source add "https://example.com/paper" --wait

# Start both non-blocking
AUDIO_TASK=$(notebooklm generate audio --json | python3 -c "import sys,json; print(json.load(sys.stdin)['task_id'])")
QUIZ_TASK=$(notebooklm generate quiz --difficulty hard --json | python3 -c "import sys,json; print(json.load(sys.stdin)['task_id'])")

# Wait for both
notebooklm artifact wait $AUDIO_TASK --timeout 1800
notebooklm artifact wait $QUIZ_TASK --timeout 300

# Download
notebooklm download audio ./podcast.mp3
notebooklm download quiz ./quiz.md --format markdown
```
