# SESSION.md

## Project
**iPad1PDFReader** — lightweight read-only document reader for the original iPad 1.

The historical app/repository name is retained for compatibility, but the reading scope now includes:

```text
PDF + plain text + Markdown + planned DOCX
```

Repository: `SHapeloglu/iPad1PDFReader`
Current branch: `feature/text-reader-v1`

## Immutable target
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1 / armv7
- Objective-C / non-ARC MRC
- Theos / legacy iPhoneOS 6.1 SDK

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Never modernize the platform merely for coding convenience.

## Authoritative suite ownership rule
Every feature first passes the ownership gate.

```text
iPad1Files          -> filesystem, file picker, copy/move/rename/delete, ZIP, normal suite routing
iPad1FTPDownloader  -> HTTP/HTTPS/FTP/WebDAV transfer, queue/resume/retry/progress
iPad1Player         -> video/audio/subtitle playback
iPad1Terminal       -> shell/PTY/system commands
iPad1VNC            -> remote desktop
iPad1PDFReader      -> lightweight read-only document specialist: PDF + text + Markdown + DOCX
```

Core rule:
```text
Her uygulama kendi uzmanlık alanını yapar.
Başka uygulamanın uzmanlığı gerekiyorsa URL handoff ile onu çağırır.
```

Important refinement: format-specific parsing required to **read** a document belongs to iPad1PDFReader. Therefore a tiny read-only DOCX package/XML reader is allowed. General ZIP browsing/extracting/creating still belongs to iPad1Files.

Canonical shared root:
```text
/var/mobile/Media/iPad1Files
```

Cross-app contracts:
```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
ipad1files://pick?callback=ipad1pdf
ipad1player://open?path=<percent-encoded-absolute-path>
```

The `ipad1pdf` URL scheme is retained for backward compatibility even as the app gains more read-only document formats.

PDFReader is not the suite's normal file router. Existing HTTP/FTP/WebDAV code is compatibility-only and must not grow.

## Current source status
Implemented in source:
- Core Graphics active-page PDF rendering;
- zoom/navigation + direct page number;
- bookmarks/resume-last-page;
- thumbnails max 8;
- incremental PDF search max 40 results;
- page-local Reflow;
- bounded outline parsing max 80;
- bounded `Gezinti Merkezi`: İçindekiler / Yer İmleri / Notlar / İşaretler;
- notes/drawing/signature;
- page-local semantic highlight + region-highlight fallback;
- Highlight / Underline / Strikeout;
- direct current-page annotation tap/edit flows;
- Day / Sepia / Night;
- Page Lock;
- reading-location Back/Forward max 20;
- edge-tap navigation;
- Fit Page / Fit Width;
- Page Manager and flattened annotation export;
- shared iPad1Files PDF discovery;
- lightweight read-only TextReader.

## Text Reader v1
Supported extensions:
```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```

Current behavior:
- `UITextView`, UTF-8, read-only;
- A-/A+, Word Wrap, Find/Next/Previous;
- file path + size Info;
- max full-load source size **2 MiB**;
- `.md` currently opens as plain text;
- no edit/save, syntax highlighting, JSON/XML parsing, OCR, AI/ML.

## Markdown Reader v2 — approved scope, not implemented yet
`.md` remains supported in plain-text mode and will gain an optional lightweight formatted reading mode.

Target subset:
- headings;
- bold/italic;
- bullet/numbered lists;
- blockquote;
- inline/fenced code;
- horizontal rule;
- basic link text/URL.

Rules:
- plain-text fallback always remains available;
- 2 MiB source limit remains;
- no JavaScript;
- no remote assets;
- no web-browser behavior;
- no full CommonMark/GFM compliance requirement;
- no document-wide background index.

Markdown tables, embedded HTML and images are deferred until physical profiling proves them safe.

## DOCX Reader v1 — approved scope, not implemented yet
A separate `DocumentReaderViewController` will handle `.docx` inside the same application.

Goal: **readable content**, not pixel-identical Microsoft Word layout.

Initial target:
- local/shared `.docx` opened in-place;
- read-only;
- paragraphs;
- line breaks;
- basic headings;
- bold/italic runs;
- simple bullets/numbering;
- simple tables;
- Find / Next / Previous;
- A- / A+;
- file path + size Info;
- safe failure for malformed/unsupported packages.

Implementation constraints:
- read only required DOCX package/XML parts;
- no persistent full-package extraction merely for reading;
- no macros;
- no external relationship/network fetching;
- no editing/save;
- no Office SDK;
- no LibreOffice engine;
- no desktop Word pagination engine;
- no OCR/AI/ML.

Initial engineering guards, to be validated on physical iPad 1:
- compressed DOCX target max **8 MiB**;
- primary XML/text working-set target max **4 MiB**;
- embedded images deferred until text-first DOCX reading is stable;
- if images are enabled later, decode one at a time and enforce strict downscale/size limits.

## Legacy `.doc`
Classic binary `.doc` support is **not approved as implemented functionality**.

Next step is feasibility only:
- consider compact text extraction;
- measure dependency size/RAM;
- reject any approach requiring a heavy Office/LibreOffice-style engine.

If it cannot be kept lightweight, `.doc` will remain unsupported.

## Current memory budgets
PDF:
- one active full PDF page render;
- thumbnail cache max **8**;
- PDF search max **40** results;
- outline parse max **80**;
- navigator annotation summary max **80**, max **40 per section/kind**;
- direct annotation tap checks max **80 current-page annotations**;
- semantic text selection max **160 active-page rects**, persisted mark max **32 rects**;
- reading history max **20** locations;
- Reflow page-scoped.

Text/Markdown:
- source full-load max **2 MiB**;
- no background index.

Planned DOCX:
- initial compressed-file target max **8 MiB**;
- primary XML/text working-set target max **4 MiB**;
- no full-resolution multi-image cache.

Preferred engineering ranges:
- normal reading roughly **30–50 MB**;
- special operations ideally remain well below **70–90 MB**.

## Physical device validation status
Physically PASS from the previously installed build:
- build/package/install/launch;
- PDF open/render;
- reading-location Back/Forward;
- Page Lock;
- Day / Sepia / Night;
- Highlight create/edit/recolor/delete;
- scanned/image-page region-highlight fallback.

Source changes made after that physical build are **NOT PASS yet**:
- Fit Page / Fit Width;
- no-history labels/alerts;
- unified `Gezinti Merkezi` with bounded outline;
- edge-tap navigation;
- direct Note tap;
- direct Highlight tap;
- Underline;
- Strikeout;
- Underline/Strikeout flattened export.

Markdown formatted mode and DOCX reader are **planned only**, not implemented and not PASS.

## iPad1Files external work
`ipad1files://pick?callback=ipad1pdf` belongs to iPad1Files.
Required behavior:
- picker stays under `/var/mobile/Media/iPad1Files`;
- callback survives nested folder navigation;
- selected file returns via `ipad1pdf://open?path=...`;
- same physical file is opened in-place;
- no system-root exposure and no duplicate copy.

When DOCX reader is physically proven, iPad1Files normal extension routing should add:
```text
.docx -> iPad1PDFReader
```

`.doc` must not be routed as supported until its feasibility phase passes.

## Build
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```
Expected package:
```text
packages/com.olap.ipad1pdfreader_3.1.0_iphoneos-arm.deb
```
Accepted warning:
```text
ld: warning: building for iOS 5.1.0 is deprecated
```

## Immediate next action
1. Pull latest `feature/text-reader-v1`.
2. Clean-build the already implemented PDF annotation/reading changes.
3. Fix only real compile/runtime/MRC issues without changing platform constraints.
4. Install and physically validate the current PDF feature package first.
5. After the current branch is stable, implement **Markdown Reader v2** as an optional formatted mode while preserving plain-text fallback and the 2 MiB limit.
6. Physically test Markdown mode for rendering, search, wrap/font behavior and repeated mode switching.
7. Then implement **DOCX Reader v1 text-first** with a separate `DocumentReaderViewController` and bounded DOCX-specific package/XML reader.
8. Start DOCX with paragraphs/basic runs/lists/tables/search/font controls; do not implement embedded images until text-first reading passes physical tests.
9. Add `.docx` routing to the receiver and then to iPad1Files normal routing only after the DOCX path is physically proven.
10. Evaluate legacy `.doc` separately; do not add a heavy binary Word engine.
11. Do not mark Markdown formatted mode, DOCX or DOC as PASS before physical iPad 1 validation.

## New-chat starter
```text
https://github.com/SHapeloglu/iPad1PDFReader
Bu projeye kaldığımız yerden devam edelim.
Önce SESSION.md, ARCHITECTURE.md, INTEGRATION.md, TASKS.md, TESTING.md ve AGENTS.md dosyalarını oku.
SESSION.md authoritative handoff belgesidir.
Current branch: feature/text-reader-v1
Immediate next action bölümünden devam et.
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / legacy iPhoneOS 6.1 SDK / non-ARC-MRC sınırlarından sapma.
Uygulama artık read-only document reader scope'unda PDF + text + Markdown + planlı DOCX okur; genel file manager/downloader/media işlerini kopyalama.
Fiziksel cihazda doğrulanmamış özellikleri PASS kabul etme.
```
