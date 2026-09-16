# iPad1PDFReader

A lightweight **read-only document reader** built specifically for the **original iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7**.

The historical project name is retained for compatibility, but the reading scope now covers:

```text
PDF + plain text + Markdown + planned DOCX
```

The project deliberately prioritizes **stability, bounded memory and clear responsibility boundaries** over feature count or desktop fidelity.

## Current development state
Current work lives on:

```text
feature/text-reader-v1
```

The branch already contains advanced PDF and Text Reader work. Several PDF features are physically validated; newer PDF annotation changes, Markdown formatted mode and DOCX reading are tracked separately in `SESSION.md`, `TASKS.md` and `TESTING.md`.

## Ecosystem
This app is one specialist in a modular iPad 1 suite:

```text
iPad1Files
  -> shared filesystem + normal extension routing

iPad1FTPDownloader
  -> HTTP/HTTPS/FTP/WebDAV transfers

iPad1Player
  -> video/audio/subtitle playback

iPad1Terminal
  -> shell/system commands

iPad1VNC
  -> remote desktop

iPad1PDFReader
  -> lightweight read-only document reading
  -> PDF + text + Markdown + planned DOCX
```

The applications should **complement, not duplicate, each other**.

PDFReader is not a general file manager, downloader, media player or suite-wide file router.

Canonical shared root:

```text
/var/mobile/Media/iPad1Files
```

## URL handoff
Document receiver:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The scheme keeps the historical `ipad1pdf` name for backward compatibility.

Picker request:

```text
ipad1files://pick?callback=ipad1pdf
```

Routing into the app:
- `.pdf` -> PDF Reader;
- `.txt`, `.log`, `.csv`, `.json`, `.xml`, `.sql`, `.py`, `.sh`, `.ini`, `.conf` -> Text Reader;
- `.md` -> Text Reader now, optional formatted Markdown mode planned;
- `.docx` -> planned Document Reader after physical validation;
- `.doc` -> not supported until separate binary-format feasibility work succeeds.

Normal extension-based routing across the suite belongs to **iPad1Files**.

## PDF features
- Core Graphics PDF rendering;
- one active full page at a time;
- pinch/double-tap zoom;
- Fit Page / Fit Width;
- page navigation and edge-tap support;
- bookmarks + resume-last-page;
- bounded thumbnails;
- incremental text search with progress/cancel;
- page-at-a-time Reflow;
- bounded outline support;
- bounded `Gezinti Merkezi`;
- drawing;
- notes;
- region highlight;
- page-local semantic Highlight / Underline / Strikeout;
- direct note/text-mark interaction;
- fluorescent mark palette;
- simple signature;
- flattened annotation export;
- page reorder/delete/rotate/export;
- bounded reading-location Back/Forward;
- Day/Sepia/Night;
- Page Lock;
- shared-storage handoff.

## Text Reader
Supported extensions:

```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```

Current baseline:
- legacy `UITextView`;
- UTF-8;
- read-only;
- file name in title;
- full path and size in Info;
- A- / A+;
- Word Wrap;
- Find / Next / Previous;
- 2 MiB hard source-file limit.

No editing/save, syntax highlighting, JSON/XML parsing, OCR or AI/ML.

## Markdown Reader v2 — planned
`.md` will keep the existing plain-text fallback and may optionally render a small read-only subset:
- headings;
- bold/italic;
- bullet/numbered lists;
- blockquotes;
- inline/fenced code;
- horizontal rules;
- basic links.

Constraints:
- 2 MiB source limit remains;
- no JavaScript;
- no remote assets;
- no web-browser behavior;
- no full CommonMark/GFM compliance requirement;
- no background indexing.

Markdown tables, embedded HTML and images are deferred until physical profiling.

## DOCX Reader v1 — planned
DOCX support will live inside this app in a separate `DocumentReaderViewController`.

Goal: **readable Word content, not pixel-identical Word layout**.

Initial target:
- read-only `.docx`;
- paragraphs;
- basic headings;
- bold/italic runs;
- line breaks;
- simple bullets/numbering;
- simple tables;
- Find / Next / Previous;
- A- / A+;
- path/size Info;
- malformed-package safe failure.

DOCX-specific read-only ZIP/XML parsing is allowed as an internal implementation detail. General ZIP browsing/extraction remains an `iPad1Files` feature.

Initial engineering guards to validate on the physical device:
- compressed DOCX target max **8 MiB**;
- primary XML/text working-set target max **4 MiB**;
- no persistent whole-package extraction solely for reading;
- embedded images deferred until text-first mode is stable;
- no Office SDK;
- no LibreOffice engine;
- no full desktop Word pagination;
- no macros/remote relationships;
- no editing/save;
- no OCR/AI.

## Legacy `.doc`
Classic binary `.doc` is a separate format from `.docx`.

Only a compact text-extraction feasibility study is planned initially. If safe support requires a heavy office engine or unsafe RAM usage, `.doc` remains unsupported.

## Memory policy
Hard rules:
- one active full PDF page render;
- thumbnail cache max **8**;
- PDF search results max **40**;
- PDF search page-by-page;
- Reflow page-by-page;
- outline parse max **80**;
- document navigation annotation summary max **80**, max **40 per kind**;
- Text/Markdown source file max **2 MiB** for full load;
- planned DOCX compressed-file target max **8 MiB**;
- planned DOCX primary XML/text working-set target max **4 MiB**;
- no whole-document bitmap cache;
- no persistent whole-document PDF text index;
- no on-device OCR;
- no AI/ML;
- no uncontrolled parallel heavy work;
- disposable state clears on memory warning.

Preferred engineering targets:
- normal reading roughly **30–50 MB**;
- special operations ideally well below **70–90 MB**.

## Features intentionally delegated
Do not grow these inside iPad1PDFReader:
- general filesystem manager and normal suite routing -> **iPad1Files**;
- general ZIP/archive UI -> **iPad1Files**;
- HTTP/HTTPS/FTP/WebDAV download/upload/queue/resume/retry -> **iPad1FTPDownloader**;
- video/audio/subtitle playback -> **iPad1Player**;
- shell/system workflows -> **iPad1Terminal**;
- remote desktop -> **iPad1VNC**.

Existing built-in HTTP/FTP/WebDAV paths are maintenance-only pending proven handoff and controlled retirement.

## Build
Expected environment:
- Theos at `~/theos`;
- legacy `iPhoneOS6.1.sdk`.

```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```

Target must remain:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Do not switch to a modern SDK/deployment target for convenience.

## Documentation
Before development read:
1. `SESSION.md`
2. `ARCHITECTURE.md`
3. `INTEGRATION.md`
4. `TASKS.md`
5. `TESTING.md`
6. `AGENTS.md`
7. `COMPANION_APP_GUIDANCE.md`
8. `README.md`

Then continue from `SESSION.md -> Immediate next action`.

## Golden rule
**If a feature belongs to another suite app, hand it off. If a document-reading feature risks stability on Apple A4 / 256 MB RAM / iOS 5.1.1, redesign it as bounded/chunked or do not add it.**
