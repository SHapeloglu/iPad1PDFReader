# AGENTS.md

## Read first
Before editing this repository, read in this order:
1. `SESSION.md`
2. `ARCHITECTURE.md`
3. `INTEGRATION.md`
4. `TASKS.md`
5. `TESTING.md`
6. `README.md`
7. `CLAUDE.md`

Then continue from `SESSION.md -> Immediate next action`.

## Non-negotiable platform
- iPad 1
- Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- non-ARC / manual retain-release
- Theos
- legacy iPhoneOS 6.1 SDK

Required Makefile target:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Never modernize deployment target or introduce unavailable post-iOS-5 APIs merely for convenience.

## Three-app ecosystem boundary
Do not duplicate sibling-app responsibilities.

```text
iPad1Files          = shared filesystem/file management/Open With
iPad1FTPDownloader  = FTP browse/download/upload/queue/resume
iPad1PDFReader      = PDF specialist + lightweight read-only Text Reader
```

Text Reader v1 may display supported plain-text files handed off by iPad1Files, but must not become an editor or file manager.

PDFReader's legacy HTTP/FTP/WebDAV code is maintenance-only. Do not grow it for competitor parity.

Canonical shared root:

```text
/var/mobile/Media/iPad1Files
```

Handoff remains:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Route `.pdf` to PDF Reader and supported text extensions to `TextReaderViewController`.

## Feature classification
- **Green**: low-memory/incremental -> generally safe.
- **Yellow**: requires hard caps/page-local work/device profiling.
- **Red**: reject on-device.

Red examples:
- OCR;
- AI/ML;
- whole-document bitmap caches;
- persistent full-document PDF text index;
- large cloud SDKs;
- heavy PDF/network engines without measured need.

## Hard memory rules
- one active full PDF page render;
- thumbnail cache max 8;
- PDF search results max 40;
- PDF search page-by-page;
- Reflow page-by-page;
- Belge Gezgini annotation summary max 80, max 40 per kind;
- Text Reader source file max 2 MiB for full load;
- no background text index/parser for Text Reader;
- no parallel heavy work;
- clear disposable state on memory warning;
- MRC ownership correctness is mandatory.

## Current priority
Current branch is `feature/text-reader-v1`.

Finish legacy clean-build and physical validation of the new **read-only Text Reader** while preserving all existing PDF behavior.

Text Reader rules:
- separate `TextReaderViewController`;
- UTF-8 only;
- read-only;
- supported extensions only;
- 2 MiB full-load hard limit;
- A-/A+, Wrap, Info, Find/Next/Previous;
- no edit/save, syntax highlighting, Markdown rendering, JSON/XML parsing, OCR, AI or ML.

The page-local real-text highlight work remains present underneath this branch and is still not fully device-proven. Do not weaken its bounds.

## Definition of done
A feature is not done until:
- legacy build succeeds;
- physical iPad 1 test succeeds;
- memory is bounded;
- relevant `TESTING.md` checks pass;
- documentation is updated.
