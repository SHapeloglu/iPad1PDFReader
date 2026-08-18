# INTEGRATION.md

## Purpose
This file is the authoritative integration contract between:

- `SHapeloglu/iPad1Files`
- `SHapeloglu/iPad1FTPDownloader`
- `SHapeloglu/iPad1PDFReader`

The goal is to make the three applications complement each other without duplicating engines, storage or memory-heavy features.

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
Owns:
- canonical shared storage;
- local file/folder browse;
- copy/move/rename/delete;
- multi-select;
- favorites;
- file information;
- local search;
- Open With / cross-app launch.

Must not become a PDF engine or FTP engine.

### iPad1FTPDownloader
Owns:
- FTP connection and remote browsing;
- download/upload;
- progress/speed;
- queue/resume where supported;
- saved servers;
- remote file operations.

Must not become a general file manager or PDF reader.

### iPad1PDFReader
Owns:
- PDF rendering;
- zoom and navigation;
- search/reflow;
- bookmarks;
- outline;
- annotations/highlights/notes/signature;
- PDF page operations/export.

Must not grow into a general file manager or duplicate the FTP transfer engine.

## Canonical shared filesystem
Owned by iPad1Files:

```text
/var/mobile/Media/iPad1Files
```

Common directories:

```text
Downloads/
Documents/
PDFs/
Images/
Music/
Videos/
Archives/
Shared/
Temp/
AppData/
```

## FTP download contract
Default destination for iPad1FTPDownloader should be:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

A downloaded file must not be duplicated into a second FTP-private download folder merely for integration.

Example:

```text
FTP server
  -> iPad1FTPDownloader
  -> /var/mobile/Media/iPad1Files/Downloads/book.pdf
  -> iPad1Files sees the same physical file
  -> iPad1PDFReader opens the same physical file
```

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

## Open With direction
Initial extension mapping in iPad1Files:

```text
.pdf -> iPad1PDFReader
```

Future mappings belong in iPad1Files registry rather than hard-coding every app relationship into PDFReader.

## Networking policy
Existing lightweight HTTP/FTP/WebDAV code inside PDFReader is maintenance-only.

New transfer features should normally go to iPad1FTPDownloader or a future dedicated network component instead of PDFReader.

Do not add `libsmb2`, `libssh2`, cloud SDKs or other heavy stacks to PDFReader merely to match competitors.

## OCR / AI policy
No device-side OCR or AI/ML in these apps for this hardware target.

If OCR is needed:

```text
PC/VPS -> OCR -> searchable PDF -> shared storage -> iPad1PDFReader
```

## Single-file principle
Whenever possible:

```text
one logical file = one physical file
```

Avoid workflows such as:

```text
iPad1FTPDownloads/book.pdf
+ iPad1Files/Downloads/book.pdf
+ PDFReader/Documents/book.pdf
```

when all three apps can safely reference the shared file instead.

## Change-control rule
Any change to:
- canonical root;
- common folder names;
- URL schemes;
- application responsibility boundaries;
- AppData namespaces;

must update `INTEGRATION.md`, `SESSION.md`, `ARCHITECTURE.md` and `README.md` in the same development phase.
