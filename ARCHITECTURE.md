# ARCHITECTURE.md

## Goal
Build the most capable PDF/document reader practical on an **original iPad 1 with 256 MB RAM and iOS 5.1.1**, without sacrificing stability for feature count.

## Architecture principles

### 1. Device limits are the primary design constraint
Every feature must be classified before implementation:
- **Green:** low-memory, incremental, safe by design.
- **Yellow:** allowed only with hard bounds / serial processing / page-level work.
- **Red:** reject for on-device implementation.

Red examples:
- device-side OCR;
- AI/ML inference;
- whole-document bitmap rendering;
- large image/page caches;
- persistent full-document text indexing;
- heavy modern PDF engines/cloud SDKs with unknown footprint.

### 2. Rendering
`PDFPageView` uses Core Graphics / `CGPDFDocument` and renders the active page only.
Never keep multiple full-resolution page bitmaps.

### 3. Thumbnails
`ThumbnailViewController` is lazy and bounded.
- max cached thumbnails: **8**;
- purge on memory warning.

### 4. Search
`PDFTextExtractor` scans content streams with `CGPDFScanner`.
`SearchViewController` processes one page per run-loop step so the user can see progress and cancel.
- page-by-page only;
- no resident global index;
- max retained results: **40**.

### 5. Reflow
Reflow is page-scoped. Never concatenate the whole document into one large string.

### 6. Annotations
`AnnotationStore` + `AnnotationOverlayView` provide lightweight drawing, rectangular highlight, text notes and simple signatures.
Highlight selection is one-shot: scroll is disabled only while the selection is being drawn, then restored.
`PDFAnnotationExporter` flattens visible annotations into a new PDF instead of building heavy editable `/Annots` structures.

### 7. Document navigation
`DocumentNavigatorViewController` summarizes bookmarks, notes and highlights without indexing PDF text.
Memory limits:
- max annotation-summary items: **80**;
- max per kind: **40**.

`PDFOutlineParser` resolves lightweight direct outline destinations when possible. Unresolved/named destinations must fail gracefully.

### 8. Page operations
`PageManager` / `PageManagerViewController` reorder/delete/rotate and export to a **new PDF**. No in-place source mutation. Export occurs only after explicit user save.

### 9. Companion-app responsibility boundary
The iPad1 application family is intentionally modular:

```text
iPad1Files          -> shared filesystem, copy/move/rename/delete, Open With
iPad1FTPDownloader  -> FTP browse/download/upload/queue/resume
iPad1PDFReader      -> PDF reading/search/reflow/annotation/page management
```

Do not duplicate companion-app engines inside PDFReader.

Canonical shared root owned by iPad1Files:

```text
/var/mobile/Media/iPad1Files
```

PDFReader directly scans:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

Cross-app handoff contract:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Shared files are opened in-place when safe; they are not copied merely to enter PDFReader.

### 10. Networking
Existing built-in HTTP/FTP/WebDAV code is retained for compatibility/maintenance, but **feature growth belongs in companion apps** where possible.
Do not add SMB/SFTP libraries merely for parity. Revisit only for a concrete requirement and measured physical-device RAM impact.

### 11. OCR / AI
OCR and AI/ML are **out of scope on-device**.
If a document needs OCR, prepare a searchable PDF on PC/VPS first.

### 12. Memory management
Project is non-ARC / MRC.
- preserve manual retain/release;
- use local autorelease pools around repeated temporary work;
- clear disposable state on memory warning;
- avoid parallel heavy work;
- do not migrate to ARC or raise deployment target.

## Main components
- `AppDelegate` — bootstrap and URL/Open In handoff.
- `PDFLibraryViewController` — app Documents + iPad1Files shared PDF discovery.
- `PDFReaderViewController` — reader orchestration.
- `PDFPageView` — active-page Core Graphics rendering.
- `BookmarkStore` — last page + bookmark state.
- `RecentStore` — recent/favorite paths.
- `AppearanceStore` — reading theme state.
- `ThumbnailViewController` — bounded lazy thumbnails.
- `PDFTextExtractor` / `SearchViewController` — page-level cancellable search.
- `ReflowViewController` — single-page text mode.
- `AnnotationStore` / `AnnotationOverlayView` — lightweight annotations.
- `DocumentNavigatorViewController` — bounded bookmark/note/highlight summary.
- `PDFAnnotationExporter` — flattened annotation export.
- `PageManager` / `PageManagerViewController` — safe copy-based page operations.
- `PDFOutlineParser` / `OutlineViewController` — outline support and page jump.
- `URLImportViewController`, `WebDAVClient`, `NetworkCenterViewController` — legacy network compatibility.
- `MemoryBudget` — explicit iPad 1 limits.
