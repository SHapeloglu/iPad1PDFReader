# iPad1PDFReader

A lightweight advanced PDF reader built specifically for the **original iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7**.

The project deliberately prioritizes **stability, bounded memory and clear responsibility boundaries** over feature count.

## Current development state
Current source is a **v3.2 development head** on top of `v3.1.0-memorysafe`.

The active development work is on:

```text
feature/page-local-text-highlight
```

It must still be clean-built and validated on the physical iPad 1 after the latest highlight/integration work.

For development continuation, **`SESSION.md` is the single authoritative handoff document**.

## Ecosystem
This app is one part of a three-app iPad 1 ecosystem:

```text
iPad1Files
  -> shared filesystem, copy/move/rename/delete, Open With

iPad1FTPDownloader
  -> FTP browse/download/upload/queue/resume

iPad1PDFReader
  -> PDF read/search/reflow/bookmark/annotation/page management
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

PDF handoff:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Shared PDFs should be opened in-place where safe instead of creating unnecessary duplicate files.

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
- page-local text-aware highlight development;
- five fluorescent highlight colors;
- simple signature;
- flattened annotation export;
- page reorder/delete/rotate/export;
- iTunes File Sharing / Open In;
- iPad1Files shared-storage handoff;
- cold/warm `ipad1pdf://` handoff with MRC cleanup.

## Memory policy
Hard rules include:
- one active full page render;
- thumbnail cache max **8**;
- search results max **40**;
- search/Reflow page-by-page;
- no whole-document bitmap cache;
- no persistent whole-document text index;
- no on-device OCR;
- no AI/ML;
- no uncontrolled parallel heavy work.

Preferred engineering targets:
- normal reading roughly **30–50 MB**;
- special operations ideally well below **70–90 MB**.

See `SESSION.md` for the complete architecture, integration contract, limits, test checklist and current next action.

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

## Development handoff
Before changing code:

1. read `SESSION.md`;
2. inspect the current source code relevant to the task;
3. continue from `SESSION.md -> Immediate next action`.

No other handoff MD is required.

## Golden rule
**If a feature risks stability on Apple A4 / 256 MB RAM / iOS 5.1.1, redesign it as page-local/bounded, move it to the correct companion app, or do not add it.**
