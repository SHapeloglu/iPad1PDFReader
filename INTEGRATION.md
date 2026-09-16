# INTEGRATION.md

## Purpose
This file is the authoritative integration contract between the iPad 1 suite applications relevant to document/media handoff:

- `SHapeloglu/iPad1Files`
- `SHapeloglu/iPad1FTPDownloader`
- `SHapeloglu/iPad1PDFReader`
- `SHapeloglu/iPad1Player`

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
Owns:
- canonical shared storage;
- local file/folder browse;
- copy/move/rename/delete;
- multi-select;
- favorites;
- file information;
- local search;
- Open With / cross-app launch;
- ordinary extension-based suite routing;
- general ZIP/archive browsing, extraction and creation.

Must not become a PDF/DOCX rendering engine, media player or FTP engine.

### iPad1FTPDownloader
Owns:
- HTTP/HTTPS/FTP/WebDAV transfer work;
- FTP connection and remote browsing;
- download/upload;
- progress/speed;
- queue/resume/retry where supported;
- saved servers;
- remote file operations.

Must not become a general file manager, document reader or media player.

### iPad1Player
Owns:
- video/audio playback;
- media decoding;
- subtitle discovery/rendering;
- playback controls and media-session behavior.

Must not become a general file manager, downloader or document reader.

### iPad1PDFReader
Owns read-only document consumption for:
- PDF rendering/search/reflow/bookmarks/annotations/page operations/export;
- supported plain-text files;
- Markdown reading;
- planned lightweight DOCX reading.

The app does **not** own editing/save, rename/delete/copy/move, general archive handling, general file management, network transfer or media playback.

A DOCX file is ZIP-based, but a tiny read-only package/XML path used internally only to read `.docx` is considered part of document parsing. It must never expose general ZIP/file-management UI.

PDFReader remains not the suite's normal file router. Normal extension mapping belongs in iPad1Files.

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

## Download contract
Default destination for iPad1FTPDownloader should be:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

A downloaded file must not be duplicated into a second downloader-private folder merely for integration.

The same single-file principle applies to PDF, text, Markdown, DOCX and media files.

## PDFReader discovery contract
PDFReader may directly discover shared PDFs from:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

This direct discovery is a bounded PDF-library convenience and must not evolve into a general filesystem browser.

Text, Markdown and DOCX files are primarily opened by iPad1Files handoff and should open in-place without duplicate copies.

## PDFReader receiver contract
Authoritative receiver contract remains:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The historical scheme name is retained for backward compatibility even though the app reads more than PDF.

Rules:
- sender passes an absolute path;
- path must be percent-encoded;
- receiver validates file existence before opening;
- `.pdf` -> `PDFReaderViewController`;
- plain-text extensions -> `TextReaderViewController`;
- `.md` -> `TextReaderViewController`, with optional Markdown formatted mode when implemented;
- `.docx` -> planned `DocumentReaderViewController` only after implementation is physically proven;
- `.doc` remains unsupported until a separate feasibility phase passes;
- unsupported extensions show a user-visible unsupported-file message or a narrowly scoped specialist fallback;
- shared iPad1Files files must not be copied solely because of handoff;
- ordinary external `Open In` files may still be copied to an app-owned persistent location when necessary.

Supported plain-text family:

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
Current/proven mappings in iPad1Files may route:

```text
.pdf  -> iPad1PDFReader / PDF Reader
.txt  -> iPad1PDFReader / Text Reader
.md   -> iPad1PDFReader / Text/Markdown Reader
.log  -> iPad1PDFReader / Text Reader
.csv  -> iPad1PDFReader / Text Reader
.json -> iPad1PDFReader / Text Reader
.xml  -> iPad1PDFReader / Text Reader
.sql  -> iPad1PDFReader / Text Reader
.py   -> iPad1PDFReader / Text Reader
.sh   -> iPad1PDFReader / Text Reader
.ini  -> iPad1PDFReader / Text Reader
.conf -> iPad1PDFReader / Text Reader
.mkv  -> iPad1Player
.mp4  -> iPad1Player
.mov  -> iPad1Player
.m4v  -> iPad1Player
.avi  -> iPad1Player
```

Planned mapping, **only after DOCX reader physical validation**:

```text
.docx -> iPad1PDFReader / Document Reader
```

Do not add `.doc` to the supported registry until its binary-format feasibility work is complete and physically proven.

Future mappings belong in the iPad1Files registry rather than hard-coding every app relationship into PDFReader.

## Markdown policy
Markdown stays read-only.

Current safe baseline:
- UTF-8 plain text;
- 2 MiB hard source limit;
- A-/A+;
- Word Wrap;
- Find/Next/Previous.

Planned formatted mode may support a small subset of headings, emphasis, lists, blockquotes, code and basic links, while preserving plain-text fallback.

No JavaScript, remote asset loading, browser behavior, editing/save, OCR or AI.

## DOCX policy
DOCX support is text-first and read-only.

Planned v1:
- paragraphs;
- basic headings;
- bold/italic runs;
- line breaks;
- simple lists;
- simple tables;
- Find/Next/Previous;
- A-/A+;
- file path/size Info.

Initial engineering guards to validate on device:
- compressed `.docx` target max **8 MiB**;
- primary XML/text working-set target max **4 MiB**;
- only required XML parts are parsed;
- no persistent whole-package extraction solely for reading;
- embedded images deferred until text-first mode is stable;
- no macros, remote relationships, Office SDK, LibreOffice engine, full Word pagination, editing/save, OCR or AI.

## Legacy DOC policy
Classic `.doc` is a separate binary format and is not covered by DOCX parsing.

Only a compact text-extraction feasibility study is allowed initially. If it requires a heavy office engine or unsafe memory footprint, `.doc` remains unsupported.

## PDF-specific media handoff
PDFReader does not decode/play media.

If a PDF interaction resolves to an **already-local media file**, PDFReader may hand it to Player using:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

If the media target is remote and requires downloading first:

```text
PDFReader -> iPad1FTPDownloader -> shared storage -> iPad1Player
```

PDFReader must not implement the transfer itself.

## Networking policy
Existing lightweight HTTP/FTP/WebDAV code inside PDFReader is maintenance-only.

New transfer features belong to iPad1FTPDownloader.

Do not add cloud SDKs or other heavy stacks to PDFReader merely to match competitors.

## OCR / AI policy
No device-side OCR or AI/ML for this hardware target.

If OCR is needed:

```text
PC/VPS -> OCR -> searchable PDF -> shared storage -> iPad1PDFReader
```

## Single-file principle
Whenever possible:

```text
one logical file = one physical file
```

Avoid duplicate copies across Downloader, Files and PDFReader storage when all applications can safely reference the shared file.

## Change-control rule
Any change to:
- canonical root;
- common folder names;
- URL schemes;
- supported document routing;
- application responsibility boundaries;
- AppData namespaces;

must update `INTEGRATION.md`, `SESSION.md`, `ARCHITECTURE.md` and `README.md` in the same development phase.
