# Companion App Guidance

This document records cross-app ownership rules for the iPad 1 application family.

## Core rule

A feature belongs to the application whose specialty owns the underlying operation. iPad1PDFReader must not absorb another application's subsystem merely for feature parity with monolithic competitors.

## iPad1Files owns

- filesystem browsing and folder navigation;
- copy, move, rename, delete;
- folder creation;
- file-level favorites;
- general filesystem search;
- ZIP/archive management;
- Open With and file picker responsibilities.

PDFReader integration should use URL handoff / callback, opening the same physical file in-place whenever safe.

Recommended contract:

```text
ipad1files://pick?callback=ipad1pdf
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

## iPad1FTPDownloader owns

- HTTP/HTTPS/FTP/WebDAV transfer work;
- FTP remote browsing;
- download/upload;
- queue, resume, retry, progress and speed;
- saved servers;
- remote file operations;
- future SMB/SFTP transfer support if justified by physical-device profiling.

PDFReader should launch the transfer specialist instead of implementing or expanding its own network engine. Existing PDFReader HTTP/FTP/WebDAV code is compatibility-only and should be removed after handoff regression is proven.

## iPad1Terminal owns

- shell/PTY behavior;
- command execution;
- system utilities;
- chmod/chown and similar system commands;
- terminal-oriented SSH workflows if supported there.

No terminal or shell subsystem belongs in PDFReader.

## iPad1VNC owns

- remote desktop connection;
- remote screen rendering;
- keyboard/mouse forwarding for VNC sessions;
- connection/session controls.

No VNC subsystem belongs in PDFReader.

## iPad1PDFReader owns

- PDF rendering and reading UX;
- zoom and page navigation;
- incremental PDF search;
- page-local text selection;
- highlight, drawing, notes and signature;
- PDF bookmarks and outlines;
- bounded annotation navigation/summary;
- reflow;
- PDF page rotate/delete/reorder/export;
- reading history and appearance;
- lightweight, read-only TextReaderViewController for supported plain text files;
- receiving document paths from companion apps.

## Important naming distinction

PDFReader may own **PDF bookmarks / reading locations** and **recently opened PDF history**.

General **file favorites** belong to iPad1Files and should not be duplicated in PDFReader.

## Feature gate for every future change

Before implementation ask:

1. Is the underlying operation PDF/text reading specific?
2. Is another companion app already the specialist?
3. Can the workflow be fulfilled by handoff rather than duplicate code?
4. Is the change safe for iPad 1 / A4 / 256 MB / iOS 5.1.1 / MRC?

If another companion app owns the operation, implement only the launcher/handoff on the PDFReader side.
