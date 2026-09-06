# SESSION.md

## Project
**iPad1PDFReader** — lightweight advanced PDF reader for the original iPad 1, with a small read-only Text Reader for plain-text files handed off by iPad1Files.

Repository: `SHapeloglu/iPad1PDFReader`

## Immutable target
- Device: **iPad 1**
- CPU: **Apple A4**
- RAM: **256 MB total physical RAM**
- OS: **iOS 5.1.1**
- Architecture: **armv7**
- Objective-C: **non-ARC / MRC**
- Build: **Theos**
- SDK: **legacy iPhoneOS 6.1 SDK**

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Never modernize deployment target/frameworks merely to simplify development.

## Ecosystem architecture — authoritative decision
Every feature must first pass the ownership gate. Each suite application performs only its specialist responsibility; another app's subsystem must not be copied into PDFReader merely for feature parity.

```text
iPad1Files
  -> filesystem backbone + normal extension routing
  -> browse/copy/move/rename/delete/search/favorites/Open With/file picker

iPad1FTPDownloader
  -> HTTP/HTTPS/FTP/WebDAV/network transfer specialist
  -> download/upload/progress/queue/resume/retry/remote operations

iPad1Player
  -> video/audio/subtitle playback specialist

iPad1Terminal
  -> shell/PTY/system command specialist

iPad1VNC
  -> remote desktop specialist

iPad1PDFReader
  -> PDF specialist
  -> render/read/search/reflow/bookmark/annotation/page management
  -> lightweight read-only Text Reader for supported plain-text handoff
```

Core rule:

```text
Her uygulama kendi uzmanlık alanını yapar.
Başka uygulamanın uzmanlığı gerekiyorsa URL handoff ile onu çağırır.
```

PDFReader is **not** the suite's normal file router. Ordinary file-type routing belongs to iPad1Files. PDFReader may reject or perform a narrowly scoped fallback only when it directly receives a misrouted/unsupported path.

Text Reader must not become a general editor or file manager.

### Canonical shared root

```text
/var/mobile/Media/iPad1Files
```

Important shared directories:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
/var/mobile/Media/iPad1Files/Documents
```

Files handed off from iPad1Files should open **in place** where safe. Do not create duplicate physical copies solely for handoff.

### URL handoff contracts
PDF/text receiver:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Picker request:

```text
ipad1files://pick?callback=ipad1pdf
```

Local media handoff, only when a PDF-specific interaction already resolves to a local media file:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

If a PDF media target requires network download first, PDFReader must hand transfer work to iPad1FTPDownloader; it must not download the media itself.

Receiver behavior:
- `.pdf` -> PDF Reader;
- supported text extension -> `TextReaderViewController`;
- unsupported extension -> user-visible safe failure or narrowly scoped specialist fallback;
- missing path/file -> fail safely.

Supported text extensions:

```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```

## Current branch

```text
feature/text-reader-v1
```

## Current PDF development status
Present in source:
- Core Graphics active-page rendering;
- zoom/navigation;
- bookmarks + resume-last-page;
- bounded thumbnails;
- page-by-page Reflow;
- notes/drawing/highlight/signature;
- bounded document navigator;
- incremental search with max 40 retained results;
- outline;
- Page Manager export flow;
- shared iPad1Files PDF discovery;
- `ipad1pdf://` receiver;
- bounded page-local text highlight with fluorescent palette;
- highlight edit/recolor/delete;
- bounded reading-location Back/Forward history;
- Day/Sepia/Night appearance modes;
- Page Lock;
- edge-tap navigation support.

## Text Reader v1 architecture
`TextReaderViewController` remains separate from `PDFReaderViewController`.

Version 1 behavior:
- `UITextView`;
- UTF-8 only;
- read-only;
- file name in navigation title;
- Info shows full path and file size;
- A- / A+ font size controls;
- Word Wrap on/off;
- Find / Next / Previous;
- no edit/save;
- no syntax highlighting;
- no Markdown rendering;
- no JSON/XML parsing;
- no OCR/AI/ML.

### Text Reader memory rule
Hard full-load limit:

```text
2 MiB
```

Rules:
- inspect file size before reading;
- <=2 MiB valid UTF-8 may be loaded;
- >2 MiB rejected before full read;
- no background indexing/parsing;
- one loaded document only.

## Current highlight rules
Normal searchable PDF target:

```text
select text -> Highlight -> fluorescent color
```

Palette:
- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

For image/scanned pages with no usable text layer, region highlight is the fallback. No on-device OCR.

## Scope rules
### PDFReader owns
- PDF rendering/read UX;
- zoom/page navigation;
- PDF search/reflow;
- bookmarks/outlines;
- annotations/highlights/notes/signature;
- page management/export;
- reading history/appearance/page lock;
- lightweight read-only TextReader;
- narrowly scoped companion handoff.

### PDFReader must not grow
- general filesystem management;
- copy/move/rename/delete/ZIP/search/favorites;
- general file routing registry;
- video/audio decode/playback;
- subtitle engine;
- download/queue/resume/retry/network transfer;
- terminal/system commands;
- VNC/remote desktop.

Existing PDFReader HTTP/FTP/WebDAV code is **maintenance-only** and should be retired after companion handoff is physically proven.

## Memory budgets
PDF:
- one active full page render;
- thumbnail cache max **8**;
- search results max **40**;
- navigator annotation summary max **80**, max **40 per kind**;
- Reflow page-scoped;
- no whole-document bitmap/text/glyph cache.

Text Reader:
- source file max **2 MiB** for full load;
- no parser/index;
- one loaded document only.

Preferred ranges:
- normal reading roughly **30–50 MB**;
- special operations ideally remain well below **70–90 MB**.

## Physical device validation status
Current `feature/text-reader-v1` package has been clean-built, copied to and launched on the physical iPad 1.

Physically PASS:
- build/package;
- install/launch;
- PDF open/render;
- reading-location Back/Forward;
- Page Lock;
- Day appearance;
- Sepia appearance;
- Night appearance;
- Highlight creation;
- Highlight edit;
- Highlight recolor;
- Highlight delete;
- scanned/image-page region-highlight fallback.

Still requiring explicit physical validation before being called complete:
- iPad1Files picker handoff end-to-end;
- PDF opened through picker using the same physical file;
- Text Reader opened through picker;
- paths containing spaces/Turkish characters;
- unsupported-extension fallback;
- Text Reader UTF-8/search/wrap/2 MiB limit regression;
- edge-tap navigation if not separately tested.

## Build
Successful package target:

```text
packages/com.olap.ipad1pdfreader_3.1.0_iphoneos-arm.deb
```

Build:

```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```

Accepted linker warning:

```text
ld: warning: building for iOS 5.1.0 is deprecated
```

## Immediate next action
1. Complete iPad1Files picker implementation/validation under canonical root `/var/mobile/Media/iPad1Files`.
2. Test `PDFReader -> Dosyalar -> iPad1Files picker -> PDF -> PDFReader` using the same physical file.
3. Test a supported `.txt`/`.md` through the same callback into `TextReaderViewController`.
4. Test spaces and Turkish characters in paths.
5. Verify no duplicate file is created during handoff.
6. Run remaining Text Reader physical regressions and edge-tap test.
7. Only after handoff passes, remove/retire legacy PDFReader network UI/code references in a controlled change.
8. Do not expand PDFReader into iPad1Files, iPad1FTPDownloader or iPad1Player responsibilities.

## New-chat starter

```text
https://github.com/SHapeloglu/iPad1PDFReader
Bu projeye kaldığımız yerden devam edelim.
Önce SESSION.md, ARCHITECTURE.md, INTEGRATION.md, TASKS.md, TESTING.md ve AGENTS.md dosyalarını oku.
SESSION.md authoritative handoff belgesidir.
Current branch: feature/text-reader-v1
Immediate next action bölümünden devam et.
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / legacy iPhoneOS 6.1 SDK / non-ARC-MRC sınırlarından sapma.
Her geliştirmede önce suite ownership gate uygula; başka uygulamanın uzmanlığını PDFReader içine kopyalama.
Fiziksel cihazda doğrulanmamış özellikleri PASS kabul etme.
```
