# SESSION.md

## Project
**iPad1PDFReader** — lightweight advanced PDF reader for the original iPad 1.

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
```

### Canonical shared root

```text
/var/mobile/Media/iPad1Files
```

Important shared directories for PDFReader:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

PDFReader must open shared PDFs **in place** where safe. Do not create duplicate physical copies just to hand a PDF between these apps.

### PDF URL handoff contract

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

## Current development head
Current source is a **v3.2 development head** on top of `v3.1.0-memorysafe`.

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
- `ipad1pdf://` receiver registration.

## Current highlight phase
The previous drag-rectangle highlight is useful mainly for scanned/image PDFs, but it is not the desired primary UX for normal text PDFs.

Target UX:

```text
select text -> Highlight -> fluorescent color
```

Planned fluorescent palette:
- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

The last-used highlight color may be remembered.

### Memory rule for real text highlight
This is **Yellow**, allowed only if implemented page-by-page:
- process only the active page;
- do not index the whole PDF;
- do not retain whole-document glyph/word geometry;
- clear temporary selection geometry on page change and memory warning;
- persist only small annotation data such as page + rect(s) + color;
- if a PDF has no selectable text layer, do not OCR on-device; retain optional region highlight instead.

Current source already contains early highlight-color support in `AnnotationOverlayView`; user-facing text-selection/color workflow is not yet considered complete or device-proven.

## Next low-memory UX candidates
After the current highlight phase and physical validation:
- highlight color change/delete;
- tap a note marker to open/edit it;
- add Outline/Contents into the unified document navigation experience;
- lightweight reading history/back-forward with a hard small cap;
- optional left/right edge page taps if they do not conflict with zoom/annotation gestures;
- text copy only if it can reuse the page-local text-selection work safely.

## Features intentionally NOT added/grown in PDFReader
Because companion apps own them:
- general filesystem manager;
- advanced copy/move/rename/favorites UI;
- FTP client growth;
- FTP transfer queue/resume engine;
- general network file browser.

Existing PDFReader HTTP/FTP/WebDAV code is **maintenance-only**. Do not grow it for feature parity.

## Red / out of scope on-device
- OCR engine;
- AI/ML inference;
- whole-document bitmap cache;
- persistent whole-document text index;
- high-resolution multi-page pre-rendering;
- modern cloud SDKs;
- heavy SMB/SFTP libraries merely for parity;
- heavy replacement PDF engine without measured real-device proof.

## Memory budgets
- one active full PDF page render;
- thumbnail cache max **8**;
- search result cap **40**;
- Belge Gezgini annotation summary max **80**, max **40 per kind**;
- Reflow page-scoped;
- no parallel heavy processing;
- purge disposable state on memory warning.

Preferred engineering ranges:
- normal reading roughly **30–50 MB**;
- special operations ideally stay well below **70–90 MB**;
- any unbounded growth is a failure.

## Current validation status
The latest development source, including the newest highlight-color work, is **not yet a proven release** until it is clean-built and tested on the physical iPad 1.

## Build environment
WSL Ubuntu + Theos + legacy iPhoneOS6.1 SDK.

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Do not switch to iPhoneOS9.3 SDK; it previously caused simulator `.tbd` warnings and armv7 `liblaunch.dylib` link failure.

## Immediate next action
1. Pull/download current `main`.
2. Read `SESSION.md`, `ARCHITECTURE.md`, `INTEGRATION.md`, `TASKS.md`, `TESTING.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`.
3. Finish the **page-local real text highlight + fluorescent color UX** without whole-document indexing.
4. Keep rectangle/area highlight only as a fallback for PDFs without selectable text.
5. Clean-build with the legacy toolchain.
6. Fix only real legacy compile errors without changing platform constraints.
7. Install on physical iPad 1.
8. Run the highlight, integration and memory tests in `TESTING.md`.
9. Do not start heavier features until this phase is stable.

## New-chat starter
Use this in a new conversation:

```text
We are continuing https://github.com/SHapeloglu/iPad1PDFReader.
Read SESSION.md, ARCHITECTURE.md, INTEGRATION.md, TASKS.md,
TESTING.md, AGENTS.md, CLAUDE.md and README.md before changing code.
Continue exactly from SESSION.md -> Immediate next action.
Preserve iPad 1 / A4 / 256 MB / iOS 5.1.1 / armv7 / non-ARC / Theos constraints.
Do not duplicate iPad1Files or iPad1FTPDownloader responsibilities.
```
