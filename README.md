# iPad1PDFReader

A lightweight advanced PDF reader built specifically for the **original iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7**, with a deliberately small read-only Text Reader for plain-text files handed off by iPad1Files.

The project deliberately prioritizes **stability, bounded memory and clear responsibility boundaries** over feature count.

## Current development state
Current Text Reader work lives on:

```text
feature/text-reader-v1
```

This branch is based on `feature/page-local-text-highlight-v2`, so current PDF highlight work is preserved while Text Reader changes remain isolated from `main`.

Neither Text Reader v1 nor real selectable-text highlight should be considered release-proven until the combined branch is clean-built and validated on the physical iPad 1. See `SESSION.md`.

## Ecosystem
This app is one part of a three-app iPad 1 ecosystem:

```text
iPad1Files
  -> shared filesystem, copy/move/rename/delete, Open With

iPad1FTPDownloader
  -> FTP browse/download/upload/queue/resume

iPad1PDFReader
  -> PDF read/search/reflow/bookmark/annotation/page management
  -> lightweight read-only text viewing
```

The applications should **complement, not duplicate, each other**.

Canonical shared root:

```text
/var/mobile/Media/iPad1Files
```

PDFReader discovers shared PDFs from at least:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

Text files are primarily opened by iPad1Files handoff and should use the same physical file in-place.

## URL handoff
The existing compatibility scheme remains:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Routing:
- `.pdf` -> PDF Reader;
- `.txt`, `.md`, `.log`, `.csv`, `.json`, `.xml`, `.sql`, `.py`, `.sh`, `.ini`, `.conf` -> Text Reader;
- unsupported extension -> user-visible error.

Example:

```text
ipad1pdf://open?path=/var/mobile/Media/iPad1Files/Documents/test.txt
```

## PDFReader features
- Core Graphics PDF rendering;
- one active full page at a time;
- pinch zoom;
- zoom persistence across page navigation;
- double-tap zoom;
- direct page-number navigation;
- bookmarks + resume-last-page;
- bounded thumbnails;
- incremental text search with progress/cancel;
- page-at-a-time Reflow;
- outline support;
- Belge Gezgini for bookmarks/notes/highlights;
- drawing;
- page notes;
- region highlight;
- bounded page-local text highlight development;
- fluorescent highlight palette;
- simple signature;
- flattened annotation export;
- page reorder/delete/rotate/export;
- PDF merge infrastructure;
- iTunes File Sharing / Open In;
- iPad1Files shared-storage handoff.

## Text Reader v1
Supported extensions:

```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```

All are displayed as **plain text**.

Features:
- legacy `UITextView`;
- UTF-8;
- read-only;
- file name in title;
- full path and size in Info;
- A- / A+ font size;
- Word Wrap on/off;
- Find / Next / Previous;
- 2 MiB hard full-load source-file limit.

Not included in v1:
- editing/save;
- syntax highlighting;
- Markdown rendering;
- JSON/XML parsing;
- OCR;
- AI/ML.

## Current PDF highlight phase
The desired normal-text workflow is:

```text
select text -> Highlight -> fluorescent color
```

Target colors:
- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

For scanned/image-only PDFs with no text layer, region highlight remains the lightweight fallback.

Real text highlight must remain page-local; no whole-document text/glyph index is allowed.

## Memory policy
Hard rules:
- one active full PDF page render;
- thumbnail cache max **8**;
- PDF search results max **40**;
- PDF search page-by-page;
- Reflow page-by-page;
- Belge Gezgini annotation summary max **80**, max **40 per kind**;
- Text Reader source file max **2 MiB** for full load;
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
Do not grow these inside PDFReader:
- general file manager -> **iPad1Files**;
- FTP browse/download/upload/queue/resume -> **iPad1FTPDownloader**.

Text Reader v1 is viewer-only; file management still belongs to iPad1Files.

Existing built-in HTTP/FTP/WebDAV paths are maintenance-only.

## Build
Expected environment:
- Theos at `~/theos`;
- legacy `iPhoneOS6.1.sdk`.

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Target must remain:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Do not switch to modern iPhoneOS9.3 SDK for this project.

## Documentation
Before development read:
1. `SESSION.md`
2. `ARCHITECTURE.md`
3. `INTEGRATION.md`
4. `TASKS.md`
5. `TESTING.md`
6. `AGENTS.md`
7. `CLAUDE.md`
8. `README.md`

Then continue from `SESSION.md -> Immediate next action`.

## Golden rule
**If a feature risks stability on Apple A4 / 256 MB RAM / iOS 5.1.1, redesign it as page-local/bounded, move it to the correct companion app, or do not add it.**
