# SESSION.md

## Project
**iPad1PDFReader** — lightweight advanced PDF reader for the original iPad 1, with a small read-only Text Reader for plain-text files handed off by iPad1Files.

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
iPad1PDFReader      -> PDF reading/annotation/page operations + lightweight read-only TextReader
```

Core rule:
```text
Her uygulama kendi uzmanlık alanını yapar.
Başka uygulamanın uzmanlığı gerekiyorsa URL handoff ile onu çağırır.
```

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

PDFReader is not the suite's normal file router. Existing HTTP/FTP/WebDAV code is compatibility-only and must not grow.

## Current PDFReader source status
Implemented in source:
- Core Graphics active-page rendering;
- zoom/navigation + direct page number;
- bookmarks/resume-last-page;
- thumbnails max 8;
- incremental search max 40 results;
- page-local Reflow;
- bounded outline parsing max 80;
- bounded `Gezinti Merkezi`: İçindekiler / Yer İmleri / Notlar / İşaretler;
- notes/drawing/signature;
- page-local semantic highlight + region-highlight fallback;
- highlight recolor/delete;
- Day / Sepia / Night;
- Page Lock;
- reading-location Back/Forward max 20;
- edge-tap navigation;
- Fit Page / Fit Width;
- Page Manager and flattened annotation export;
- shared iPad1Files PDF discovery;
- lightweight read-only TextReader.

### Latest annotation package — implemented but not yet physically proven
New source changes:
- direct tap on current-page **note** -> view/edit/delete;
- direct tap on current-page **highlight** -> recolor/delete;
- direct tap on underline/strikeout -> recolor/delete;
- direct annotation hit-testing capped at **80 current-page annotations**;
- **Underline** using existing active-page text geometry;
- **Strikeout** using existing active-page text geometry;
- Underline/Strikeout share the same small fluorescent color palette;
- Underline/Strikeout require selectable text and do **not** fall back to OCR or region selection;
- flattened export draws Underline/Strikeout;
- `Gezinti Merkezi` lists Highlight/Underline/Strikeout together under **İşaretler**;
- no spatial index, no background annotation index, no whole-document text geometry.

Tool menu now keeps the same overall density by using:
```text
Metin İşaretle -> Highlight / Altını Çiz / Üstünü Çiz
İşaret Düzenle -> current-page text marks
```

## Text Reader v1
Supported extensions:
```text
.txt .md .log .csv .json .xml .sql .py .sh .ini .conf
```
Rules:
- `UITextView`, UTF-8, read-only;
- A-/A+, Word Wrap, Find/Next/Previous;
- file path + size Info;
- max full-load source size **2 MiB**;
- no edit/save, parser, Markdown rendering, syntax highlighting, OCR, AI/ML.

## Memory budgets
- one active full PDF page render;
- thumbnail cache max **8**;
- PDF search max **40** results;
- outline parse max **80**;
- navigator annotation summary max **80**, max **40 per section/kind**;
- direct annotation tap checks max **80 current-page annotations**;
- semantic text selection max **160 extracted active-page rects**, persisted mark max **32 rects**;
- reading history max **20** locations;
- Reflow page-scoped;
- TextReader max **2 MiB** source full-load;
- no whole-document bitmap/text/glyph/spatial index.

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

## iPad1Files external work
`ipad1files://pick?callback=ipad1pdf` belongs to iPad1Files.
Required behavior:
- picker stays under `/var/mobile/Media/iPad1Files`;
- callback survives nested folder navigation;
- selected file returns via `ipad1pdf://open?path=...`;
- same physical file is opened in-place;
- no system-root exposure and no duplicate copy.

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
2. Clean-build using legacy iPhoneOS 6.1 SDK / armv7 / iOS 5.1 target.
3. Fix only real compile/runtime/MRC issues; do not change platform constraints.
4. Install on physical iPad 1.
5. Test Fit Page / Fit Width.
6. Test `Gezinti Merkezi` sections and page jumps.
7. Test edge taps at 1x and verify zoom/double-tap/annotation gestures still behave.
8. Create a Highlight and tap it directly; test recolor/delete.
9. Create a Note and tap its marker directly; test view/edit/delete.
10. On a selectable-text PDF create Underline and Strikeout; page away/back and reopen PDF to verify persistence.
11. Recolor/delete Underline and Strikeout both from direct tap and `İşaret Düzenle`.
12. Export flattened PDF and verify Highlight/Underline/Strikeout appearance.
13. On a scanned/image PDF confirm Underline/Strikeout show selectable-text warning and never start OCR.
14. Complete iPad1Files picker callback separately in iPad1Files, then validate PDF/TextReader handoff with spaces/Turkish characters and no duplicate files.
15. Do not mark any of the new annotation features PASS before physical device testing.

## New-chat starter
```text
https://github.com/SHapeloglu/iPad1PDFReader
Bu projeye kaldığımız yerden devam edelim.
Önce SESSION.md, ARCHITECTURE.md, INTEGRATION.md, TASKS.md, TESTING.md ve AGENTS.md dosyalarını oku.
SESSION.md authoritative handoff belgesidir.
Current branch: feature/text-reader-v1
Immediate next action bölümünden devam et.
iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / Objective-C / Theos / legacy iPhoneOS 6.1 SDK / non-ARC-MRC sınırlarından sapma.
Her geliştirmede önce suite ownership gate uygula.
Fiziksel cihazda doğrulanmamış özellikleri PASS kabul etme.
```
