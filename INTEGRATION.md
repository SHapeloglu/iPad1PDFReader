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
- PDF page operations/export;
- lightweight read-only viewing of supported plain-text files.

Text Reader v1 does **not** own editing, save, rename, delete, copy/move, syntax parsing or file management.

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

Example PDF:

```text
FTP server
  -> iPad1FTPDownloader
  -> /var/mobile/Media/iPad1Files/Downloads/book.pdf
  -> iPad1Files sees the same physical file
  -> iPad1PDFReader opens the same physical file
```

The same single-file principle applies to supported text files.

## PDFReader discovery contract
PDFReader should directly discover at least:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

Shared PDFs should open in-place where permissions allow.

Text files do not need to be duplicated into PDFReader storage. They are primarily opened by iPad1Files handoff and should open in-place.

## Handoff URL scheme
Authoritative receiver contract remains:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The scheme name is retained for backward compatibility even though the receiver can now route supported text files.

Rules:
- sender passes an absolute path;
- path must be percent-encoded;
- receiver validates file existence before opening;
- `.pdf` routes to existing PDF Reader;
- supported text extensions route to Text Reader;
- unsupported extensions show a user-visible unsupported-file message;
- shared iPad1Files files must not be copied solely because of handoff;
- ordinary external `Open In` files may still be copied to an app-owned persistent location when necessary.

Supported Text Reader extensions:

```text
.txt
.md
.log
.csv
.json
.xml
.sql
.py
.sh
.ini
.conf
```

## Open With direction
Extension mapping in iPad1Files may route:

```text
.pdf  -> iPad1PDFReader / PDF Reader
.txt  -> iPad1PDFReader / Text Reader
.md   -> iPad1PDFReader / Text Reader
.log  -> iPad1PDFReader / Text Reader
.csv  -> iPad1PDFReader / Text Reader
.json -> iPad1PDFReader / Text Reader
.xml  -> iPad1PDFReader / Text Reader
.sql  -> iPad1PDFReader / Text Reader
.py   -> iPad1PDFReader / Text Reader
.sh   -> iPad1PDFReader / Text Reader
.ini  -> iPad1PDFReader / Text Reader
.conf -> iPad1PDFReader / Text Reader
```

Future mappings belong in iPad1Files registry rather than hard-coding every app relationship into PDFReader.

## Text Reader policy
Version 1 is intentionally small:
- UTF-8;
- `UITextView`;
- read-only;
- A- / A+;
- Word Wrap toggle;
- Find / Next / Previous;
- file info including full path;
- 2 MiB hard full-load limit.

No editing/save, syntax highlighting, Markdown rendering, JSON/XML parsing, OCR, AI or ML.

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
