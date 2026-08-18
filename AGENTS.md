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
iPad1PDFReader      = PDF rendering/search/reflow/annotation/page management
```

PDFReader's legacy HTTP/FTP/WebDAV code is maintenance-only. Do not grow it for competitor parity.

Canonical shared root:

```text
/var/mobile/Media/iPad1Files
```

PDF handoff:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

## Feature classification
- **Green**: low-memory/incremental -> generally safe.
- **Yellow**: requires hard caps/page-local work/device profiling.
- **Red**: reject on-device.

Red examples:
- OCR;
- AI/ML;
- whole-document bitmap caches;
- persistent full-document text index;
- large cloud SDKs;
- heavy PDF/network engines without measured need.

## Hard memory rules
- one active full PDF page render;
- thumbnail cache max 8;
- search results max 40;
- search page-by-page;
- Reflow page-by-page;
- Belge Gezgini annotation summary max 80, max 40 per kind;
- no parallel heavy work;
- clear disposable state on memory warning;
- MRC ownership correctness is mandatory.

## Current priority
Finish page-local **real text highlight + fluorescent color** UX.

Rules:
- active page only;
- no whole-document glyph/text index;
- temporary selection geometry must be released on page change/memory warning;
- persist compact rect(s) + color only;
- image/scanned PDF may use region highlight fallback;
- never add OCR to make scanned PDFs selectable.

## Definition of done
A feature is not done until:
- legacy build succeeds;
- physical iPad 1 test succeeds;
- memory is bounded;
- relevant `TESTING.md` checks pass;
- documentation is updated.
