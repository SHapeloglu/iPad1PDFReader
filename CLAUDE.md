# CLAUDE.md

Read `SESSION.md`, `ARCHITECTURE.md`, `INTEGRATION.md`, `TASKS.md`, `TESTING.md` and `AGENTS.md` before changing code.

## Core rule
**Never trade iPad 1 stability for feature count.**

Permanent target:
- iPad 1 / Apple A4
- 256 MB RAM
- iOS 5.1.1
- armv7
- non-ARC / MRC
- Theos + legacy iPhoneOS6.1 SDK

## Ecosystem rule
Do not turn iPad1PDFReader into a monolith.

- iPad1Files owns local file management/shared storage/Open With.
- iPad1FTPDownloader owns FTP transfer/browse/queue/resume.
- iPad1PDFReader owns PDF reading/search/reflow/annotation/page operations.

Prefer lightweight handoff over duplicated engines.

## Coding style
- legacy Objective-C compatible with iOS 5;
- explicit manual memory ownership;
- Foundation/UIKit/CoreGraphics first;
- avoid uncontrolled concurrency;
- keep temporary text/images/geometry short-lived;
- use hard caps for lists/caches;
- fail gracefully on unsupported PDF constructs.

## Current development priority
Real text highlight with fluorescent colors, page-local only.

Do not create whole-document text/glyph indexes. Do not add OCR/AI. Keep region highlight as fallback for image PDFs.

## New chat continuation
Always continue from:

```text
SESSION.md -> Immediate next action
```

Do not infer an older chat state if repository documentation says otherwise.
