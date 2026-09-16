# ARCHITECTURE.md

## Goal
Build the most capable **lightweight document reader** practical on an **original iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1** without sacrificing stability for feature count.

The app remains named `iPad1PDFReader` for compatibility, but its read-only scope now includes:

```text
.pdf                  -> PDFReaderViewController
.txt/.log/.csv/...     -> TextReaderViewController
.md                   -> TextReaderViewController + optional lightweight Markdown Reading Mode
.docx                 -> DocumentReaderViewController (planned)
.doc                  -> DocumentReaderViewController only after separate feasibility proof
```

The goal is **reading**, not Office-compatible editing or desktop layout fidelity.

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
- **Yellow**: useful but requires hard bounds, page-local/chunked processing and physical-device profiling.
- **Red**: reject for on-device implementation.

Before memory classification, every feature also passes an **ownership gate**:
1. Is the operation part of read-only document consumption?
2. Does another iPad1 companion app already own the underlying subsystem?
3. Can the specialist be called through URL handoff instead of duplicating a general-purpose engine?

Internal parsing needed to read a document format is allowed when it stays format-specific. For example, a tiny read-only ZIP/XML path used only to open a `.docx` package is part of the document reader; a general ZIP browser/extractor remains the responsibility of `iPad1Files`.

Red examples:
- OCR;
- AI/ML;
- whole-document bitmap rendering;
- persistent full-document text indexes;
- high-resolution multi-page caches;
- heavy cloud SDKs;
- embedded LibreOffice/Office engines;
- full desktop Word pagination/layout engine.

## PDF Rendering
`PDFPageView` uses Core Graphics / `CGPDFDocument`.
Rules:
- render one active full page at a time;
- never pre-render an entire document;
- never retain several full-resolution page bitmaps;
- purge disposable state on memory warning.

## Text Reader
`TextReaderViewController` remains separate from `PDFReaderViewController`.

Supported plain-text extensions:
```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```

Base Text Reader rules:
- `UITextView`;
- read-only;
- UTF-8 only;
- no editing/save;
- no syntax highlighting;
- no JSON/XML parser;
- file name in navigation title;
- full path available from Info;
- font size controls;
- wrap toggle;
- Find / Next / Previous over the currently loaded text only.

Memory rule:
- inspect file size before reading;
- hard full-load limit: **2 MiB**;
- files above the limit are not loaded into `UITextView`;
- wrap-off width is bounded;
- no background index.

### Markdown Reading Mode v2 — planned
`.md` continues to open safely as plain text even if formatted mode fails or is disabled.

Planned lightweight formatted subset:
- headings `#` through `######`;
- bold and italic;
- bullet/numbered lists;
- blockquote;
- inline code and fenced code blocks;
- horizontal rule;
- basic links shown as readable text/URL.

Rules:
- no JavaScript;
- no remote asset loading;
- no general web browser behavior;
- no full CommonMark/GFM compliance requirement;
- no document-wide secondary index;
- parser output must be bounded by the existing 2 MiB source-file rule;
- plain-text mode remains the fallback and source-of-truth representation.

Tables, embedded HTML and remote images are deferred until measured on the physical iPad 1.

## DOCX Reader v1 — planned
`DocumentReaderViewController` will be separate from both PDF and Text Reader controllers.

Initial `.docx` goal is **readable content**, not pixel-identical Microsoft Word rendering.

Allowed v1 scope:
- open existing local `.docx` in-place;
- read-only;
- extract `word/document.xml` from the DOCX package;
- paragraphs;
- headings when safely derivable;
- basic bold/italic runs;
- line breaks;
- basic bullet/numbered list representation;
- simple tables rendered as lightweight rows/text;
- Find / Next / Previous over the currently loaded document text;
- A- / A+;
- file name, path and size Info;
- optional embedded images only after a strict size/downscale policy is physically proven.

DOCX implementation rules:
- package decompression is read-only and DOCX-specific; it must not expose a general ZIP UI;
- parse only required XML parts;
- do not extract the complete package to persistent storage merely to read it;
- avoid DOM-like full package object graphs when streaming/incremental parsing is practical;
- no macros;
- no external template fetching;
- no remote relationships/network loads;
- no editing/save;
- no tracked-change editing;
- no comments editor;
- no Office SDK;
- no LibreOffice engine;
- no desktop page-layout/pagination engine;
- no OCR/AI.

Initial safety targets, subject to physical profiling:
- compressed `.docx` size target: **<= 8 MiB**;
- primary document XML/text working-set target: **<= 4 MiB**;
- one embedded image decoded at a time;
- reject or skip oversized embedded media rather than risking memory pressure;
- no resident full-resolution image gallery/cache.

These are engineering guards, not claims of Word compatibility.

## Legacy `.doc` — deferred
Classic binary `.doc` is a different and substantially more complex format than `.docx`.

Phase 1 does **not** ship a new binary Word engine. Before implementation, evaluate whether a compact text-extraction-only path can be built and physically profiled on iPad 1.

If safe extraction cannot be achieved without a heavy dependency, `.doc` remains unsupported while `.docx` is supported.

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

Text/Markdown/DOCX search operates only on the currently loaded bounded reading representation and does not create a persistent index.

## Reflow
PDF Reflow is page-scoped. Never concatenate the entire PDF into one large string.

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
- persist compact page + rect list + color only;
- discard temporary geometry on page change/memory warning;
- no document-wide text index;
- no OCR fallback on-device.

Highlight may fall back to a rectangular region on image/scanned pages. Underline and strikeout require selectable text and fail safely when none exists.

Direct annotation interaction is page-local and bounded. `PDFReaderViewController` examines at most **80 current-page annotations** for tap hit-testing.

`PDFAnnotationExporter` produces a new flattened PDF and draws highlight, underline and strikeout marks without adding a heavy editable `/Annots` engine.

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
The application family remains modular:
```text
iPad1Files          -> filesystem backbone + normal suite routing
iPad1FTPDownloader  -> HTTP/FTP/WebDAV/network transfer specialist
iPad1Player         -> video/audio/subtitle playback specialist
iPad1Terminal       -> shell/system command specialist
iPad1VNC            -> remote desktop specialist
iPad1PDFReader      -> lightweight read-only document specialist: PDF + text + Markdown + DOCX
```

### iPad1Files owns
- browse/copy/move/rename/delete;
- shared folders;
- file-level favorites;
- Open With / file picker;
- normal extension-based suite routing;
- file classification/organization;
- general ZIP/archive management;
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
- PDF search/reflow/bookmarks/outlines/annotations/page management/export;
- lightweight read-only plain-text reading;
- lightweight Markdown reading;
- lightweight read-only DOCX reading;
- receiving supported document paths through the existing receiver contract.

PDFReader still does **not** own general filesystem management, network transfer, media playback, terminal or VNC functionality.

## Shared storage
Canonical root:
```text
/var/mobile/Media/iPad1Files
```

PDFReader directly scans PDF library locations only:
```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

Text/Markdown/DOCX are primarily opened by `iPad1Files` handoff and should open in-place. This must not evolve into a general filesystem browser.

Cross-app contracts:
```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
ipad1files://pick?callback=ipad1pdf
ipad1player://open?path=<percent-encoded-absolute-path>
```

The historical `ipad1pdf` scheme remains for backward compatibility even though the app now reads multiple document formats.

## Networking
Existing HTTP/FTP/WebDAV code in PDFReader is compatibility-only and scheduled for retirement after companion handoff is physically proven.

## Memory management
Project is MRC.
Rules:
- explicit ownership;
- release temporary objects aggressively;
- local autorelease pools around repeated temporary work;
- no uncontrolled parallel heavy work;
- clear temporary text/geometry/XML/image/list data on memory warning;
- never raise deployment target to solve coding convenience.

## Engineering RAM targets
- normal reading roughly **30–50 MB preferred**;
- special operations ideally remain well below **70–90 MB**;
- sustained unbounded growth fails testing.

## Main components
- `AppDelegate` — bootstrap + URL/Open In handoff.
- `PDFLibraryViewController` — PDF library convenience + document-type receiver routing.
- `PDFReaderViewController` — PDF reader orchestration + bounded direct annotation hit-testing.
- `TextReaderViewController` — bounded read-only UTF-8 text viewing and future Markdown mode.
- `DocumentReaderViewController` — planned bounded DOCX read-only viewing.
- `DOCXReader` / equivalent parser — planned DOCX-specific read-only package/XML extraction.
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
