# Competitor Feature Routing

This document routes competitor-inspired features to the correct application in the iPad 1 suite.

## iPad1Files
- filesystem browsing and folder navigation
- copy/move/rename/delete
- folder creation
- file-level favorites/stars
- general filesystem search
- ZIP/archive operations
- file organization/classification
- Open With and reusable file-picker UX

Recommended handoff:
```text
ipad1files://pick?callback=ipad1pdf
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

## iPad1FTPDownloader
- HTTP/HTTPS downloads
- FTP remote browsing and transfer
- WebDAV transfer/listing if retained in the suite
- upload/download
- queue/resume/retry/progress/speed
- saved servers
- remote file operations
- future SMB/SFTP transfer support only if physical-device profiling justifies it

PDFReader's existing HTTP/FTP/WebDAV code is compatibility-only and should retire after handoff is physically proven.

## iPad1Terminal
- shell/PTY
- command execution
- system utilities
- chmod/chown and similar system operations
- terminal-oriented SSH workflows

## iPad1VNC
- remote desktop connection
- remote screen rendering
- VNC keyboard/mouse forwarding
- connection/session controls

## iPad1PDFReader
Keep competitor features here only when they are genuinely PDF-reading responsibilities and remain safe for A4 / 256 MB:
- PDF rendering, zoom, page navigation
- incremental PDF search
- page-local text selection
- highlight, highlight recolor/delete
- drawing, notes, signature
- PDF bookmarks and outlines
- bounded annotation navigation/summary
- bounded back/forward reading-location history
- edge-tap page turning
- day/sepia/night viewing without duplicate full-page bitmaps
- page lock
- reflow
- page rotate/delete/reorder/export
- recent document reading history
- lightweight read-only TextReaderViewController

## Naming distinction
PDFReader may own PDF bookmarks/reading locations and recent-document history. General file favorites belong to iPad1Files.
