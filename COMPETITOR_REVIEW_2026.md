# Competitor Review 2026 — Scoped for iPad 1

Compared against current GoodReader, PDF Expert and Documents capabilities, filtered through the iPad1 suite ownership rule and iPad 1 / A4 / 256 MB constraints.

## Keep / improve in iPad1PDFReader

High-value, low-memory features:
1. Unified document navigation: Outlines + PDF Bookmarks + Annotations.
2. Highlight management: recolor/delete existing lightweight highlight annotations.
3. Bounded back/forward reading-location history.
4. Edge-tap page turning.
5. Page lock to prevent accidental navigation/annotation gestures.
6. Day/Sepia/Night reading appearance only if implemented without duplicate full-page bitmap retention.
7. Selected-text Copy only if it reuses page-local selection state.

Already aligned and should remain:
- incremental PDF search;
- reflow;
- bookmarks/outlines;
- annotation summary/navigation;
- drawing/notes/signature;
- bounded thumbnails;
- rotate/delete/reorder/export to a new PDF;
- lightweight read-only TextReaderViewController.

## Route to iPad1Files

- filesystem browsing;
- file copy/move/rename/delete;
- folders;
- file-level favorites;
- general file search;
- ZIP/archive operations;
- file picker/Open With.

## Route to iPad1FTPDownloader

- HTTP/HTTPS download;
- FTP browse/download/upload;
- WebDAV transfer/listing;
- queues, retry, resume, progress, speed;
- saved servers;
- remote operations;
- future SMB/SFTP transfer work if physically justified.

## Route to iPad1Terminal

- shell/PTY and command execution;
- system utilities/permissions;
- terminal-oriented SSH workflows.

## Route to iPad1VNC

- remote desktop sessions;
- remote screen rendering;
- remote keyboard/mouse/session controls.

## Explicit rejects on iPad 1

- OCR/AI/ML;
- persistent whole-document text index;
- dual high-resolution PDF rendering / side-by-side PDFs;
- heavy cloud SDKs;
- full PDF content-stream text/image editing;
- large multi-page bitmap caches.
