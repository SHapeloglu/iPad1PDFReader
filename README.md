# iPad1PDFReader

A lightweight advanced PDF reader built specifically for the **original iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7**, with a deliberately small read-only Text Reader for plain-text files handed off by iPad1Files.

The project deliberately prioritizes **stability, bounded memory and clear responsibility boundaries** over feature count.

## Current development state
Current work lives on:

```text
feature/text-reader-v1
```

The combined branch clean-builds and has been launched on the physical iPad 1. Several reading/highlight features are physically validated; remaining handoff/Text Reader regressions are tracked in `SESSION.md` and `TESTING.md`.

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
  -> PDF read/search/reflow/bookmark/annotation/page management
  -> lightweight read-only text viewing
```

The applications should **complement, not duplicate, each other**.

PDFReader is not a general file manager, downloader, media player or suite-wide file router.

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
PDF/text receiver:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Picker request:

```text
ipad1files://pick?callback=ipad1pdf
```

Routing into PDFReader:
- `.pdf` -> PDF Reader;
- `.txt`, `.md`, `.log`, `.csv`, `.json`, `.xml`, `.sql`, `.py`, `.sh`, `.ini`, `.conf` -> Text Reader;
- unsupported extension -> user-visible safe failure or narrowly scoped specialist fallback.

Normal extension-based routing across the suite belongs to **iPad1Files**, not PDFReader.

If a PDF-specific interaction resolves to an already-local media file, PDFReader may hand it to Player:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

Typical local video types include `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi`. PDFReader must not decode or play them itself. If a media resource must first be downloaded from the network, transfer ownership remains with iPad1FTPDownloader.

## PDFReader features
- Core Graphics PDF rendering;
- one active full page at a time;
- pinch/double-tap zoom;
- page navigation;
- bookmarks + resume-last-page;
- bounded thumbnails;
- incremental text search with progress/cancel;
- page-at-a-time Reflow;
- outline support;
- bounded document navigation for bookmarks/notes/highlights;
- drawing;
- page notes;
- region highlight;
- bounded page-local text highlight;
- fluorescent highlight palette;
- highlight edit/recolor/delete;
- simple signature;
- flattened annotation export;
- page reorder/delete/rotate/export;
- bounded reading-location Back/Forward;
- Day/Sepia/Night appearance modes;
- Page Lock;
- edge-tap navigation support;
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

Not included:
- editing/save;
- syntax highlighting;
- Markdown rendering;
- JSON/XML parsing;
- OCR;
- AI/ML.

## Memory policy
Hard rules:
- one active full PDF page render;
- thumbnail cache max **8**;
- PDF search results max **40**;
- PDF search page-by-page;
- Reflow page-by-page;
- document navigation annotation summary max **80**, max **40 per kind**;
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
- general filesystem manager and normal suite routing -> **iPad1Files**;
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
**If a feature belongs to another suite app, hand it off. If a PDF feature risks stability on Apple A4 / 256 MB RAM / iOS 5.1.1, redesign it as page-local/bounded or do not add it.**
