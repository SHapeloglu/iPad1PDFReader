# INTEGRATION.md

## Purpose
This file is the authoritative integration contract between the iPad 1 specialist applications.

The goal is to make the applications complement each other without duplicating engines, storage or memory-heavy features.

## Platform contract
All integrations must preserve:
- iPad 1;
- Apple A4;
- 256 MB RAM;
- iOS 5.1.1;
- armv7;
- non-ARC / MRC;
- Theos;
- legacy iPhoneOS 6.1 SDK compatibility.

## Responsibility split

### iPad1Files
Owns canonical shared storage, local file/folder browsing, copy/move/rename/delete, pickers, favorites, local search, ZIP/archive and cross-app launch. It must not become a network-transfer, PDF-rendering or media-playback engine.

### iPad1FTPDownloader
Owns FTP connection, remote browsing, FTP download/upload, FTP transfer state, saved servers and remote FTP operations. It must not implement generic HTTP/HTTPS downloads.

### iPad1HTTPDownloader
Owns HTTP/HTTPS URL downloads, redirects, response/header handling, streamed writes, `.part` lifecycle, progress/speed/ETA, Range-based resume where supported, cancel/retry, bounded queue and HTTP-specific failure recovery. It must not become a file manager, PDF reader or media player.

### iPad1PDFReader
Owns PDF rendering, zoom/navigation, search/reflow, bookmarks, outline, annotations/highlights/notes/signature and PDF page operations/export. It must not duplicate HTTP/FTP transfer engines.

### iPad1Player
Owns local media decode/playback, seeking, codecs and subtitle discovery/rendering. It receives only completed accessible local media paths from downloader applications.

## Canonical shared filesystem
Owned by iPad1Files:

```text
/var/mobile/Media/iPad1Files
```

Common directories include `Downloads/`, `Documents/`, `PDFs/`, `Images/`, `Music/`, `Videos/`, `Archives/`, `Shared/`, `Temp/` and `AppData/`.

## Downloader storage contract
Both FTP and HTTP downloaders should write completed files directly under the canonical shared storage, normally:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

One logical transfer should produce one physical file. Do not copy a completed file into a downloader-private or reader-private directory merely for integration.

## Completed-file routing
After successful transfer and only after the local file is accessible:

```text
.mkv/.mp4/.mov/.m4v/.avi -> ipad1player://open?path=<percent-encoded-absolute-path>
.pdf                     -> ipad1pdf://open?path=<percent-encoded-absolute-path>
other                    -> ipad1files://show?path=<percent-encoded-absolute-path>
```

The sender passes the same physical file path. No integration copy is permitted.

## PDFReader discovery contract
PDFReader should directly discover at least:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

Shared PDFs should open in-place where permissions allow.

## PDF handoff URL scheme
Authoritative receiver contract:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Rules:
- sender passes an absolute path;
- path must be percent-encoded;
- PDFReader validates file existence and `.pdf` type before opening;
- shared files should not be copied solely because of the handoff;
- ordinary external `Open In` files may still be copied to an app-owned persistent location when necessary.

## Networking policy
Existing lightweight HTTP/FTP/WebDAV code inside PDFReader is maintenance-only. New HTTP/HTTPS download features belong to iPad1HTTPDownloader; FTP transfer features belong to iPad1FTPDownloader.

Do not add `libsmb2`, `libssh2`, cloud SDKs or other heavy stacks to PDFReader merely to match competitors.

## iPad 1 memory policy
- no device-side OCR or AI/ML;
- no whole-file download buffers;
- no duplicate integration copies;
- keep cross-app contracts path-based and lightweight.

## Change-control rule
Any change to canonical root, common folder names, URL schemes, application responsibility boundaries or AppData namespaces must update the relevant integration/handoff documentation in the same development phase. Physical iPad testing remains authoritative.
