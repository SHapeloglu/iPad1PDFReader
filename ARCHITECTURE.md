# ARCHITECTURE.md

## Goal
Build the most capable PDF/document reader practical on an **original iPad 1 with 256 MB RAM and iOS 5.1.1**, without sacrificing stability for feature count.

## Architecture principles

### 1. Device limits are the primary design constraint
Every feature must be classified before implementation:
- **Green:** low-memory, incremental, safe by design.
- **Yellow:** allowed only with bounded caches / streaming / page-level processing.
- **Red:** reject for on-device implementation.

Red examples:
- device-side OCR;
- AI inference;
- whole-document bitmap rendering;
- large image caches;
- loading full large PDF text into one giant string;
- heavy modern PDF engines with unknown memory footprint.

### 2. Rendering
`PDFPageView` uses Core Graphics / `CGPDFDocument` and renders the active page only.

Rules:
- never pre-render the whole document;
- never keep multiple full-resolution page bitmaps;
- do not introduce tiled multi-page caches without measuring memory first;
- release page/cache resources aggressively on memory warning.

### 3. Thumbnails
`ThumbnailViewController` generates thumbnails lazily for visible rows and keeps only a small bounded LRU cache.

Current budget:
- max cached thumbnails: **8**;
- thumbnail size: intentionally small;
- cache purged on `didReceiveMemoryWarning`.

### 4. Search
`PDFTextExtractor` scans content streams using `CGPDFScanner`.

Search rules:
- page-by-page;
- bounded result count;
- no global text index resident in RAM;
- do not create a background indexing service on iPad 1.

Current maximum retained results: **40**.

### 5. Reflow
Reflow must be page-based.

Never concatenate an entire book/document into a single `NSString`. The current controller displays one extracted page at a time with previous/next navigation.

### 6. Annotations
Annotation editing data is stored separately by `AnnotationStore` and drawn through `AnnotationOverlayView`.

`PDFAnnotationExporter` creates a new PDF with visible annotations flattened onto pages. This is intentionally simpler and lighter than writing fully editable PDF `/Annots` structures.

### 7. Page operations
`PageManager` / `PageManagerViewController` provide reorder/delete/rotate/export and merge infrastructure.

Operations create a new PDF rather than attempting risky in-place mutation of the source file.

### 8. Networking
Built-in/low-cost paths:
- HTTP/HTTPS;
- FTP;
- WebDAV.

Optional only after profiling:
- SMB via `libsmb2`;
- SFTP via `libssh2`.

Do not add large cloud SDKs. Prefer protocol-level access or external transfer tools.

### 9. OCR
OCR is **off-device only**.

Recommended workflow:
`PC/VPS -> OCR -> searchable PDF -> iPad1PDFReader`

### 10. Memory management
Project is non-ARC.

Rules:
- preserve manual retain/release;
- use local autorelease pools around temporary rendering/text work where useful;
- release caches on memory warning;
- do not migrate to ARC unless an iOS 5.1.1-compatible build and runtime impact is proven first.

## Main components
- `AppDelegate` — application bootstrap / Open In handoff.
- `PDFLibraryViewController` — local PDF library.
- `PDFReaderViewController` — reader orchestration.
- `PDFPageView` — Core Graphics page rendering.
- `BookmarkStore` — last page + bookmark state.
- `RecentStore` — recent/favorite paths.
- `AppearanceStore` — reading theme state.
- `ThumbnailViewController` — bounded lazy thumbnail UI.
- `PDFTextExtractor` — page-level text extraction/search.
- `SearchViewController` — bounded results UI.
- `ReflowViewController` — single-page text reading mode.
- `AnnotationStore` / `AnnotationOverlayView` — lightweight annotations.
- `PDFAnnotationExporter` — flattened annotation PDF export.
- `PageManager` / `PageManagerViewController` — page operations.
- `PDFOutlineParser` / `OutlineViewController` — outline support.
- `URLImportViewController` — URL download.
- `WebDAVClient` / `NetworkCenterViewController` — network access.
- `MemoryBudget` — explicit iPad 1 memory policy constants.
