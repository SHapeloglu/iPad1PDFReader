# SESSION.md

## Project
**iPad1PDFReader** — lightweight advanced PDF reader for the original iPad 1, with a small read-only Text Reader for plain-text files handed off by iPad1Files.

Repository: `SHapeloglu/iPad1PDFReader`

## Immutable target
- Device: **iPad 1**
- CPU: **Apple A4**
- RAM: **256 MB total physical RAM**
- OS: **iOS 5.1.1**
- Architecture: **armv7**
- Objective-C: **non-ARC / MRC**
- Build: **Theos**
- SDK: **legacy iPhoneOS 6.1 SDK**
- Makefile target must remain:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Never modernize deployment target/frameworks merely to simplify development.

## Ecosystem architecture — authoritative decision
Three companion apps intentionally divide responsibilities so code, RAM and maintenance are not duplicated.

```text
iPad1Files
  -> shared filesystem backbone
  -> browse/copy/move/rename/delete/search/favorites/Open With

iPad1FTPDownloader
  -> FTP/network transfer specialist
  -> browse/download/upload/progress/queue/resume/remote operations

iPad1PDFReader
  -> PDF specialist
  -> render/read/search/reflow/bookmark/annotation/page management
  -> lightweight read-only Text Reader for supported plain-text handoff
```

Text Reader must not become a general editor or file manager in v1.

### Canonical shared root

```text
/var/mobile/Media/iPad1Files
```

Important shared directories include:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
/var/mobile/Media/iPad1Files/Documents
```

Files handed off from iPad1Files should open **in place** where safe. Do not create duplicate physical copies solely for handoff.

### URL handoff contract
The existing scheme is retained for compatibility:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Receiver behavior:
- `.pdf` -> existing PDF Reader;
- supported text extension -> `TextReaderViewController`;
- unsupported extension -> `Bu dosya türü desteklenmiyor`;
- missing path/file -> fail safely.

Supported text extensions:

```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```

## Current development branches
Base PDF/highlight branch:

```text
feature/page-local-text-highlight-v2
```

Current Text Reader branch:

```text
feature/text-reader-v1
```

The Text Reader branch was created from the highlight branch so current PDF work remains present, while Text Reader changes stay isolated from `main`.

## Current PDF development status
Already present in source:
- Core Graphics active-page rendering;
- zoom centering improvement;
- zoom scale retained between page changes;
- approximate viewport position retention;
- double-tap zoom;
- direct page-number navigation;
- bookmarks and resume-last-page;
- bounded thumbnails;
- page-by-page Reflow;
- page notes add/view/edit/delete;
- drawing, highlight-region and simple signature annotations;
- bounded `Belge Gezgini` for bookmarks/notes/highlights;
- search progress + cancel with max 40 retained results;
- lightweight direct outline destination resolution;
- explicit Page Manager save/export;
- iPad1Files shared PDFs/Downloads discovery;
- `ipad1pdf://` receiver registration;
- bounded page-local text highlight code with fluorescent palette support.

The highlight branch clean-build succeeded with the legacy toolchain. Physical iPad 1 testing has confirmed launch and scanned/image-PDF fallback behavior, but real selectable-text highlight is **not yet fully device-proven**.

## Text Reader v1 architecture
Text Reader is separate from `PDFReaderViewController`.

Controller:

```text
TextReaderViewController
```

Version 1 behavior:
- `UITextView`;
- UTF-8 only;
- read-only;
- file name in navigation title;
- Info shows full path and file size;
- A- / A+ font size controls;
- Word Wrap on/off;
- Find / Next / Previous;
- no edit/save;
- no syntax highlighting;
- no Markdown rendering;
- no JSON/XML parsing;
- no OCR/AI/ML.

### Text Reader memory rule
Before reading, inspect file size.

Hard full-load limit:

```text
2 MiB
```

Rules:
- <=2 MiB valid UTF-8 may be loaded into `UITextView`;
- >2 MiB is rejected before full read and user is warned;
- no background text indexing;
- search scans only the already-loaded string;
- wrap-off view width is bounded;
- off-screen loaded text may be discarded on memory warning.

This is intentionally conservative because `UITextView` layout/text storage costs exceed raw file size on a 256 MB device.

## Current highlight rules
Target UX for normal searchable PDFs:

```text
select text -> Highlight -> fluorescent color
```

Fluorescent palette:
- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

Real text highlight is allowed only page-by-page:
- process only the active page;
- do not index the whole PDF;
- do not retain whole-document glyph/word geometry;
- clear temporary selection geometry on page change and memory warning;
- persist only small annotation data such as page + rect(s) + color;
- if a PDF has no selectable text layer, do not OCR on-device; retain optional region highlight instead.

## Next low-memory UX candidates
After current Text Reader + PDF regression validation:
- highlight color change/delete;
- tap a note marker to open/edit it;
- add Outline/Contents into the unified document navigation experience;
- lightweight reading history/back-forward with a hard small cap;
- optional left/right edge page taps if they do not conflict with zoom/annotation gestures;
- text copy only if it can reuse the page-local text-selection work safely.

## Features intentionally NOT added/grown
Because companion apps own them or they are too heavy:
- general filesystem manager;
- advanced copy/move/rename/favorites UI;
- Text Reader editing/save in v1;
- FTP client growth;
- FTP transfer queue/resume engine;
- general network file browser.

Existing PDFReader HTTP/FTP/WebDAV code is **maintenance-only**. Do not grow it for feature parity.

## Red / out of scope on-device
- OCR engine;
- AI/ML inference;
- whole-document bitmap cache;
- persistent whole-document PDF text index;
- high-resolution multi-page pre-rendering;
- modern cloud SDKs;
- heavy SMB/SFTP libraries merely for parity;
- heavy replacement PDF engine without measured real-device proof.

## Memory budgets
PDF:
- one active full PDF page render;
- thumbnail cache max **8**;
- search result cap **40**;
- Belge Gezgini annotation summary max **80**, max **40 per kind**;
- Reflow page-scoped.

Text Reader:
- full source file max **2 MiB**;
- no background index/parser;
- one loaded document only.

Global:
- no parallel heavy processing;
- purge disposable state on memory warning.

Preferred engineering ranges:
- normal reading roughly **30–50 MB**;
- special operations ideally stay well below **70–90 MB**;
- any unbounded growth is a failure.

## Current validation status
Text Reader v1 source is **not yet proven** until it clean-builds with the legacy SDK and passes physical iPad 1 tests in `TESTING.md`.

Existing PDF features must be regression-tested on the same combined branch before merge/release.

## Build environment
WSL Ubuntu + Theos + legacy iPhoneOS6.1 SDK.

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Do not switch to iPhoneOS9.3 SDK.

## Immediate next action
1. Checkout/pull `feature/text-reader-v1`.
2. Clean-build with the legacy iPhoneOS6.1 SDK.
3. Fix only real iOS 5.1.1 / legacy SDK / MRC compile errors; do not change platform targets.
4. Keep Text Reader isolated from PDF rendering classes.
5. Install the combined branch on physical iPad 1 when ready for the consolidated test pass.
6. Run Text Reader tests in `TESTING.md`, including UTF-8 Turkish, search, wrap, 2 MiB limit, iPad1Files handoff and unsupported extension.
7. Run mandatory PDF regressions: open/render, zoom, navigation, search, bookmark, highlight, notes and iPad1Files handoff.
8. Do not mark Text Reader or real-text highlight as complete until physical iPad 1 validation passes.

## New-chat starter
Use this in a new conversation:

```text
We are continuing https://github.com/SHapeloglu/iPad1PDFReader.
Read SESSION.md first; it is authoritative.
Current feature branch is feature/text-reader-v1.
Preserve iPad 1 / A4 / 256 MB / iOS 5.1.1 / armv7 / non-ARC / Theos / iPhoneOS6.1 SDK constraints.
Keep TextReaderViewController separate from PDFReaderViewController.
Continue from SESSION.md -> Immediate next action.
```
