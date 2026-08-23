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
- files above the limit are not loaded into `UITextView`; user receives a warning;
- wrap-off width is bounded to avoid an unbounded view surface;
- do not add background indexing or parsers.

Text Reader does not alter PDF rendering, annotation, search, bookmark or page-management code.

## Thumbnails
`ThumbnailViewController` is lazy and bounded.

Hard cache limit:

```text
8 thumbnails
```

## Search
`PDFTextExtractor` / `SearchViewController` use serial page-by-page extraction.

Rules:
- one page per incremental step;
- visible progress;
- user cancellation;
- no resident document-wide text index;
- max retained results: **40**.

Text Reader search is independent and operates only on its already loaded <=2 MiB string.

## Reflow
Reflow is page-scoped. Never concatenate the entire document into one large string.

## Annotation architecture
`AnnotationStore` persists lightweight dictionaries and `AnnotationOverlayView` draws them.

Supported/lightweight families:
- drawing;
- note;
- simple signature;
- region highlight;
- page-local semantic text highlight.

### Real text highlight
Real text highlight is **Yellow**.

Allowed design:
- extract/select only active-page text geometry;
- discard temporary selection geometry on page change/memory warning;
- persist only page + compact rect list + fluorescent color;
- no whole-document pre-indexing;
- no OCR fallback on-device.

Fluorescent palette target:
- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

Region highlight remains a fallback for image-only/scanned PDFs.

`PDFAnnotationExporter` should continue producing a new flattened PDF rather than implementing a heavy editable `/Annots` engine unless future profiling proves otherwise.

## Document navigation
`DocumentNavigatorViewController` provides bounded navigation across annotations/bookmarks.

Hard limits:
- max annotation-summary items: **80**;
- max **40 per kind**.

Outline resolution should remain lightweight and fail gracefully for unsupported named destinations.

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
iPad1Files          -> filesystem backbone
iPad1FTPDownloader  -> FTP/network transfer specialist
iPad1PDFReader      -> PDF specialist + lightweight read-only text viewer
```

### iPad1Files owns
- browse/copy/move/rename/delete;
- shared folders;
- favorites;
- Open With;
- file classification/organization.

### iPad1FTPDownloader owns
- FTP remote browse;
- download/upload;
- queue/resume/progress/speed;
- saved servers;
- remote file commands.

### iPad1PDFReader owns
- PDF rendering/read UX;
- search/reflow;
- bookmark/outline;
- annotations;
- page management/export;
- lightweight read-only rendering of supported plain-text files handed off by iPad1Files.

Text Reader must not grow into a general editor or file manager without a separate architectural decision.

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

Text files are primarily opened by iPad1Files handoff and should be opened in-place.

Cross-app contract:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The receiver checks the extension and routes PDF to PDF Reader or supported text to Text Reader. Shared files open in-place where safe; avoid duplicate physical copies.

## Networking
Existing HTTP/FTP/WebDAV code in PDFReader is **maintenance-only**.

Do not expand it merely for feature parity. Prefer iPad1FTPDownloader/iPad1Files handoff.

SMB/SFTP libraries are not bundled unless a future concrete need plus real iPad RAM profiling justifies them.

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
- `PDFReaderViewController` — PDF reader orchestration.
- `TextReaderViewController` — bounded read-only UTF-8 text viewing.
- `PDFPageView` — active-page rendering.
- `BookmarkStore` — bookmark/last-page state.
- `AppearanceStore` — reading appearance.
- `ThumbnailViewController` — bounded thumbnails.
- `PDFTextExtractor` / `SearchViewController` — incremental PDF search.
- `ReflowViewController` — page-local reflow.
- `AnnotationStore` / `AnnotationOverlayView` — lightweight annotations.
- `DocumentNavigatorViewController` — bounded document navigation.
- `PDFAnnotationExporter` — flattened export.
- `PageManager` / `PageManagerViewController` — safe page operations.
- `PDFOutlineParser` / `OutlineViewController` — outline handling.
- legacy network classes — compatibility only.
- `MemoryBudget` — explicit iPad 1 limits.
