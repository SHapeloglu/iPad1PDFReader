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
- iPad1PDFReader owns PDF reading/search/reflow/annotation/page operations plus a small read-only Text Reader.

Text Reader must remain a viewer; file management stays in iPad1Files.

Prefer lightweight handoff over duplicated engines.

## Coding style
- legacy Objective-C compatible with iOS 5;
- explicit manual memory ownership;
- Foundation/UIKit/CoreGraphics first;
- avoid uncontrolled concurrency;
- keep temporary text/images/geometry short-lived;
- use hard caps for lists/caches;
- fail gracefully on unsupported PDF/file constructs.

## Current development priority
Current branch: `feature/text-reader-v1`.

Finish the lightweight Text Reader and prove it with the legacy toolchain and physical iPad 1.

Rules:
- separate `TextReaderViewController`;
- `UITextView`, UTF-8, read-only;
- 2 MiB source-file hard limit before full load;
- no editor/save;
- no syntax highlighting/render/parser stack;
- no OCR/AI/ML;
- existing PDF renderer/search/bookmark/highlight/note behavior must not regress.

Page-local real text highlight remains bounded and still requires full physical validation; do not create whole-document glyph/text indexes.

## New chat continuation
Always continue from:

```text
SESSION.md -> Immediate next action
```

Do not infer an older chat state if repository documentation says otherwise.
