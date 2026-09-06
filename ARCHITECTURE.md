# ARCHITECTURE.md

## Goal
Build the most capable PDF reader practical on an **original iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1** without sacrificing stability for feature count. A small read-only Text Reader may handle plain-text handoff from iPad1Files, but PDF remains the primary purpose.

## Immutable platform

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

- non-ARC / manual retain-release;
- Theos;
- legacy iPhoneOS 6.1 SDK;
- no post-iOS-5 dependency unless optional and runtime-guarded.

## Feature classification
Before implementation every feature is classified:
- **Green**: low-memory, incremental, safe by design.
- **Yellow**: useful but requires hard bounds, page-local processing and physical-device profiling.
- **Red**: reject for on-device implementation.

Before memory classification, every feature also passes an **ownership gate**:
1. Is the underlying operation specific to PDF or lightweight read-only text reading?
2. Does another iPad1 companion app already own the operation?
3. Can PDFReader launch that specialist through URL handoff/callback instead of duplicating its subsystem?

If another companion app owns the work, PDFReader implements only the handoff. See `COMPANION_APP_GUIDANCE.md`.

Red examples:
- OCR;
- AI/ML;
- whole-document bitmap rendering;
- persistent full-document text indexes;
- high-resolution multi-page caches;
- heavy cloud SDKs;
- heavy PDF engine replacement without measured proof.

## Rendering
`PDFPageView` uses Core Graphics / `CGPDFDocument`.
Rules:
- render one active full page at a time;
- never pre-render an entire document;
- never retain several full-resolution page bitmaps;
- purge disposable state on memory warning.

## Text Reader
`TextReaderViewController` is deliberately separate from `PDFReaderViewController`.
Supported plain-text extensions:
```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```
Version 1 rules:
- `UITextView` only;
- read-only;
- UTF-8 only;
- no Markdown rendering;
- no syntax highlighting;
- no JSON/XML parsing;
- no editing/save;
- file name in navigation title;
- full path available from Info;
- font size controls;
- wrap toggle;
- Find / Next / Previous search over the currently loaded text only.

Memory rule:
- inspect file size before reading;
- hard full-load limit: **2 MiB**;
- files above the limit are not loaded into `UITextView`;
- wrap-off width is bounded;
- do not add background indexing or parsers.

## Thumbnails
`ThumbnailViewController` is lazy and bounded.
Hard cache limit: **8 thumbnails**.

## Search
`PDFTextExtractor` / `SearchViewController` use serial page-by-page extraction.
Rules:
- one page per incremental step;
- visible progress;
- user cancellation;
- no resident document-wide text index;
- max retained results: **40**.

## Reflow
Reflow is page-scoped. Never concatenate the entire document into one large string.

## Annotation architecture
`AnnotationStore` persists lightweight dictionaries and `AnnotationOverlayView` draws them.

Supported/lightweight families:
- drawing;
- note;
- simple signature;
- region highlight;
- page-local semantic text highlight;
- page-local underline;
- page-local strikeout.

### Page-local text marks
Highlight, underline and strikeout reuse only the active page's bounded text geometry.
Rules:
- extract/select only active-page geometry;
- max temporary text geometry remains bounded by the extractor call;
- persist compact page + rect list + color only;
- discard temporary geometry on page change/memory warning;
- no document-wide text index;
- no OCR fallback on-device.

Highlight may fall back to a rectangular region on image/scanned pages. Underline and strikeout require selectable text and fail safely when none exists.

Direct annotation interaction is also page-local and bounded. `PDFReaderViewController` examines at most **80 current-page annotations** for tap hit-testing. Existing note/highlight/underline/strikeout data is reused; no spatial index or background cache is created.

Fluorescent/text-mark palette:
- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

`PDFAnnotationExporter` produces a new flattened PDF and now draws highlight, underline and strikeout marks without adding a heavy editable `/Annots` engine.

## Document navigation
`DocumentNavigatorViewController` provides bounded navigation across outline/bookmarks/notes/text marks.
Hard limits:
- outline parse max **80** entries;
- max annotation-summary items: **80**;
- max **40 per kind/section**.

## Page operations
`PageManager` / `PageManagerViewController`:
- reorder;
- delete;
- rotate;
- export to a **new PDF**;
- never silently mutate the original;
- export only after explicit save.

## Ecosystem boundary
The application family is intentionally modular:
```text
iPad1Files          -> filesystem backbone + normal suite routing
iPad1FTPDownloader  -> HTTP/FTP/WebDAV/network transfer specialist
iPad1Player         -> video/audio/subtitle playback specialist
iPad1Terminal       -> shell/system command specialist
iPad1VNC            -> remote desktop specialist
iPad1PDFReader      -> PDF specialist + lightweight read-only text viewer
```

### iPad1Files owns
- browse/copy/move/rename/delete;
- shared folders;
- file-level favorites;
- Open With / file picker;
- normal extension-based suite routing;
- file classification/organization;
- ZIP/archive management;
- general filesystem search.

### iPad1FTPDownloader owns
- HTTP/HTTPS/FTP/WebDAV transfer work;
- FTP remote browse;
- download/upload;
- queue/resume/progress/speed;
- saved servers;
- remote file commands.

### iPad1Player owns
- video/audio decode and playback;
- local media playback UI;
- subtitle discovery/rendering and media-session controls.

### iPad1Terminal owns
- shell/PTY behavior;
- command execution;
- system utilities.

### iPad1VNC owns
- remote desktop sessions;
- remote screen rendering;
- VNC keyboard/mouse forwarding and session controls.

### iPad1PDFReader owns
- PDF rendering/read UX;
- search/reflow;
- bookmark/outline;
- annotations including highlight/underline/strikeout;
- page management/export;
- PDF reading locations and recent-document history;
- lightweight read-only rendering of supported plain-text files handed off by iPad1Files;
- receiving document paths and launching companion specialists through narrowly scoped handoff.

PDFReader is **not** the suite's normal file router. iPad1Files owns ordinary extension routing.

## Shared storage
Canonical root:
```text
/var/mobile/Media/iPad1Files
```
PDFReader directly scans:
```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```
This direct scan is a bounded PDF-library convenience only.

Cross-app contracts:
```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
ipad1files://pick?callback=ipad1pdf
ipad1player://open?path=<percent-encoded-absolute-path>
```

## Networking
Existing HTTP/FTP/WebDAV code in PDFReader is compatibility-only and scheduled for retirement after companion handoff is physically proven.

## Memory management
Project is MRC.
Rules:
- explicit ownership;
- release temporary objects aggressively;
- local autorelease pools around repeated temporary work;
- no uncontrolled parallel heavy work;
- clear temporary text/geometry/list data on memory warning;
- never raise deployment target to solve coding convenience.

## Engineering RAM targets
- normal reading roughly **30–50 MB preferred**;
- special operations ideally remain well below **70–90 MB**;
- sustained unbounded growth fails testing.

## Main components
- `AppDelegate` — bootstrap + URL/Open In handoff.
- `PDFLibraryViewController` — local/shared PDF discovery and document-type routing.
- `PDFReaderViewController` — PDF reader orchestration + bounded direct annotation hit-testing.
- `TextReaderViewController` — bounded read-only UTF-8 text viewing.
- `PDFPageView` — active-page rendering.
- `BookmarkStore` — bookmark/last-page state.
- `AppearanceStore` — reading appearance.
- `ThumbnailViewController` — bounded thumbnails.
- `PDFTextExtractor` / `SearchViewController` — incremental PDF search.
- `ReflowViewController` — page-local reflow.
- `AnnotationStore` / `AnnotationOverlayView` — lightweight annotations/text marks.
- `DocumentNavigatorViewController` — bounded document navigation.
- `PDFAnnotationExporter` — flattened export.
- `PageManager` / `PageManagerViewController` — safe page operations.
- `PDFOutlineParser` / `OutlineViewController` — bounded outline handling.
- legacy network classes — compatibility only until handoff retirement.
- `MemoryBudget` — explicit iPad 1 limits.
