# CHANGELOG.md

## 3.1.0-memorysafe — current development head
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
