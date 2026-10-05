# BACKLOG.md — iPad1PDFReader

Scheduled work: `TASKS.md` (P0 prove current head on device → P1 real text highlight + fluorescent palette → P2 annotation/document UX → P3 memory/stability). Every idea must be classified **Green / Yellow / Red** per `ARCHITECTURE.md` before moving to `TASKS.md`.

## Yellow — possible with hard bounds and device profiling

- Text copy from the active page (reuse page-local selection state only).
- Bounded reading history / back-forward (10–20 locations).
- Edge-tap page turning, if it doesn't conflict with zoom/annotation gestures.
- Outline/Contents inside the unified document navigator, if low-cost.
- Night/sepia rendering mode via page-local color transform.
- Per-document last-zoom/last-page restore (compact metadata only).

## Red — rejected on-device (record here so they aren't re-proposed)

OCR · AI/ML inference · whole-document high-resolution bitmap cache · persistent full-document text index · large background indexing · modern cloud SDKs · SMB/SFTP libraries for parity · heavy PDF engine replacement without measured proof.

## Maintenance-only areas

Existing HTTP/FTP/WebDAV import code (`URLImportViewController`, `WebDAVClient`, `NetworkCenterViewController`) — fix bugs only; new transfer features belong to iPad1FTPDownloader / iPad1Files hand-off.
