# CHANGELOG.md

## v3.2 development head — 2026-08-18
- Added zoom-centering and zoom-persistence UX improvements.
- Added double-tap zoom and direct page-number navigation.
- Added bounded Belge Gezgini for bookmarks, notes and highlights.
- Added incremental page-by-page search progress and Cancel; max 40 results.
- Added lightweight outline destination navigation where resolvable.
- Added page note add/view/edit/delete.
- Added lightweight region-highlight workflow and started fluorescent highlight-color support.
- Current next phase: page-local selectable-text highlight with yellow/green/pink/orange/cyan palette.
- Page Manager now exports only after explicit save and writes a new PDF.
- Added iPad1Files shared PDF discovery from `PDFs` and `Downloads`.
- Defined `ipad1pdf://open?path=...` handoff and in-place shared-file policy.
- Formalized modular app split: iPad1Files = file management, iPad1FTPDownloader = FTP transfer, iPad1PDFReader = PDF features.
- Built-in PDFReader HTTP/FTP/WebDAV is maintenance-only.
- OCR, AI/ML, whole-document caches/indexes and heavy network SDKs remain out of scope.
- Physical iPad 1 validation is still required before release tagging.

## 3.1.0-memorysafe
- Added explicit `MemoryBudget` policy.
- Thumbnail cache bounded to 8 small images.
- Thumbnail cache clears on memory warning.
- Search results capped at 40.
- Reflow changed to one-page-at-a-time text loading.
- Added memory-warning cleanup paths.
- Reaffirmed no on-device OCR / AI / large multi-page bitmap caches.

## 3.0.0
- Added `CGPDFScanner` content-stream text extraction/search.
- Added Reflow reading mode.
- Added WebDAV/network center foundation.
- Added page manager and PDF merge/export infrastructure.
- Added annotation flatten export.
- Added SMB/SFTP optional connector placeholders.

## 2.x development
- Added thumbnails, themes, search experiments, annotations, URL import, outline support and file management extensions.

## 1.0.0
- First working iPad 1 PDF reader.
- Core Graphics single-page rendering.
- PDF library, zoom, previous/next, bookmarks, resume-last-page, File Sharing.
- Proven build with `TARGET = iphone:clang:6.1:5.1` and legacy iPhoneOS6.1 SDK.
