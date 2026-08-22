# SESSION.md

## Purpose
This is the single authoritative handoff and development context for **iPad1PDFReader**.

For a new ChatGPT/Claude/Codex session, reading this file plus the current source code is sufficient. If any older note, chat, commit message or README text conflicts with this file, **SESSION.md wins**.

Repository: `SHapeloglu/iPad1PDFReader`

Current development branch:

```text
feature/page-local-text-highlight
```

Current branch is development work on top of `main` / the v3.2 development head and is **not yet a device-proven release**.

---

## 1. Immutable platform contract

Never change these to simplify development:

- Device: **original iPad 1**
- CPU: **Apple A4**
- RAM: **256 MB physical RAM**
- OS: **iOS 5.1.1**
- Architecture: **armv7**
- Objective-C: **non-ARC / MRC**
- Build system: **Theos**
- SDK: **legacy iPhoneOS 6.1 SDK**

Required Makefile target:

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Required style:

- legacy Objective-C compatible with iOS 5;
- explicit retain/release ownership;
- UIKit/Foundation/CoreGraphics first;
- no ARC-only syntax;
- no weak references;
- no dictionary/array subscripting assumptions if legacy compiler rejects them;
- no modern API merely for convenience;
- no uncontrolled concurrency;
- fail gracefully on unsupported PDF constructs.

Do not switch to iPhoneOS9.3 SDK. It previously caused simulator `.tbd` warnings and armv7 `liblaunch.dylib` link problems.

---

## 2. Product goal

Build the most capable PDF reader practical on the original iPad 1 **without trading stability for feature count**.

Engineering priorities, in order:

1. physical-device stability;
2. bounded memory;
3. correct ownership under MRC;
4. responsive reading UX;
5. features.

A feature is not complete merely because code exists. It is complete only after:

- legacy clean build succeeds;
- physical iPad 1 test succeeds;
- memory remains bounded;
- relevant checks in this file pass.

---

## 3. Three-app ecosystem boundary

The applications deliberately divide responsibilities:

```text
iPad1Files
  -> shared filesystem backbone
  -> browse/copy/move/rename/delete/search/favorites/Open With

iPad1FTPDownloader
  -> FTP/network transfer specialist
  -> browse/download/upload/progress/queue/resume/remote operations

iPad1PDFReader
  -> PDF specialist
  -> render/read/search/reflow/bookmark/outline/annotation/page management/export
```

### iPad1PDFReader must NOT grow into

- a general file manager;
- an advanced copy/move/rename/delete browser;
- an FTP transfer queue/resume engine;
- a general network file browser.

Existing lightweight HTTP/FTP/WebDAV code in PDFReader is **maintenance-only**. Do not grow it for competitor parity.

---

## 4. Shared filesystem and single-file principle

Canonical shared root:

```text
/var/mobile/Media/iPad1Files
```

Important directories:

```text
/var/mobile/Media/iPad1Files/PDFs
/var/mobile/Media/iPad1Files/Downloads
```

iPad1FTPDownloader should normally download to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Use the **single-file principle**:

```text
one logical file = one physical file
```

Example desired flow:

```text
FTP server
  -> iPad1FTPDownloader
  -> /var/mobile/Media/iPad1Files/Downloads/book.pdf
  -> iPad1Files sees the same file
  -> iPad1PDFReader opens the same file in-place
```

Do not create unnecessary copies such as:

```text
iPad1FTPDownloads/book.pdf
+ iPad1Files/Downloads/book.pdf
+ PDFReader/Documents/book.pdf
```

Ordinary iOS `Open In` files from non-stable external locations may still be copied into app Documents when persistence requires it. Shared iPad1Files paths must not be copied solely for handoff.

---

## 5. Authoritative PDF handoff contract

Supported URL scheme:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Example logical target:

```text
ipad1pdf://open?path=/var/mobile/Media/iPad1Files/Downloads/Raporlar/rapor.pdf
```

Receiver rules:

- scheme must be `ipad1pdf`;
- host/action must be `open`;
- `path` query parameter must exist;
- path must be percent-decoded with iOS-5-compatible API;
- path must be absolute;
- extension must be `.pdf` case-insensitively;
- file must exist;
- missing file shows an understandable error such as `PDF bulunamadı.`;
- shared path opens directly in-place;
- no duplicate copy is created for FTPDownloader/iPad1Files handoff.

### Cold start
When PDFReader is fully closed and opened through the URL:

1. app launches;
2. `UIApplicationLaunchOptionsURLKey` is read in `didFinishLaunchingWithOptions:`;
3. URL is forwarded to the library controller;
4. requested PDF opens directly.

### Warm start
When PDFReader is already open:

- classic iOS 5 `application:handleOpenURL:` is used;
- if an old PDFReader exists anywhere in the navigation stack, it is explicitly prepared for external handoff before a new PDF reader is created;
- temporary highlight geometry is cleared;
- active page reference is cleared;
- old `CGPDFDocument` is released under MRC;
- then the new document is opened.

Current implementation uses:

```text
PDFReaderViewController+Handoff.h
PDFReaderViewController+Handoff.m
prepareForExternalPDFHandoff
```

This also covers cases where Search/Reflow/Outline/etc. is currently on top of the old reader.

No callback to iPad1FTPDownloader is required in the current phase. A future `iPad1FTPDownloader'a Dön` action may be considered later.

---

## 6. Main architecture

### Rendering
`PDFPageView` uses Core Graphics / `CGPDFDocument`.

Rules:

- one active full page render;
- never pre-render the whole document;
- never retain multiple full-resolution page bitmaps;
- release disposable page/render state under memory pressure.

### Thumbnails
`ThumbnailViewController` is lazy and bounded.

Hard cap:

```text
8 thumbnails
```

### Search
`PDFTextExtractor` / `SearchViewController` use serial page-by-page extraction.

Rules:

- incremental page processing;
- visible progress;
- cancel support;
- no persistent document-wide text index;
- retained search results max **40**.

### Reflow
Reflow is page-local. Never concatenate the entire document into one large resident string.

### Document navigator
Annotation/bookmark summary must remain bounded:

- max **80 total**;
- max **40 per kind**.

### Page Manager
Page reorder/delete/rotate operations must:

- work on explicit user action;
- export a **new PDF**;
- never silently mutate original source;
- create output only after explicit save.

### Annotation storage
`AnnotationStore` persists lightweight dictionaries. `AnnotationOverlayView` draws them.

Supported families include:

- drawing;
- page note;
- simple signature;
- region highlight;
- page-local semantic text highlight.

`PDFAnnotationExporter` produces a flattened new PDF rather than introducing a heavy editable `/Annots` engine.

---

## 7. Current implemented feature state

The current development branch contains, among other existing features:

- Core Graphics active-page rendering;
- zoom centering improvement;
- zoom scale retained between page changes;
- approximate viewport-position retention;
- double-tap zoom;
- direct page-number navigation;
- bookmarks and resume-last-page;
- bounded thumbnails;
- page-by-page Reflow;
- page notes add/view/edit/delete;
- drawing and signature annotations;
- bounded Belge Gezgini;
- incremental search with max 40 retained results;
- lightweight outline destination handling;
- explicit Page Manager export;
- shared iPad1Files PDF/Downloads discovery;
- `ipad1pdf://` URL registration and cold/warm handoff;
- direct shared-path opening without duplicate copy;
- explicit old-reader cleanup for warm external handoff.

These source-level features are **not automatically considered physically validated**.

---

## 8. Current highlight implementation

Current branch implements the low-memory first version of real-text-aware highlighting.

### Behavior

- highlight is generated only for the active page;
- text geometry is generated when highlight mode starts, not document-wide;
- temporary text rects are attached only to the active overlay;
- temporary geometry is cleared on page change;
- temporary geometry is cleared on memory warning;
- temporary geometry is cleared on external handoff/deallocation;
- saved annotations contain only compact normalized rect(s) + color;
- old single-rectangle highlight format remains readable;
- region/rectangle highlight remains fallback for scanned/image-only pages;
- no OCR starts on-device.

### Hard temporary caps

```text
active-page text rects: max 160
rects persisted in one semantic highlight: max 32
```

### Fluorescent palette

- yellow;
- green;
- pink;
- orange;
- cyan/light blue.

The last-used color is persisted as one lightweight `NSUserDefaults` value.

### Export
Flattened PDF export supports:

- old single `rect` highlights;
- new multi-`rects` highlights;
- chosen highlight color.

### Important limitation
`PDFTextExtractor` currently derives approximate text-run geometry from PDF text operators. This is deliberately lightweight for A4/256 MB hardware and must be considered **experimental until physical PDFs are tested**. Do not describe it as fully robust glyph-level selection before device validation.

---

## 9. Memory policy

Feature classification:

- **Green**: low-memory/incremental, generally safe.
- **Yellow**: useful but requires hard caps, page-local work and device profiling.
- **Red**: reject on-device.

Hard rules:

- one active full PDF page render;
- thumbnail cache max **8**;
- search results max **40**;
- semantic highlight temporary rects max **160** active-page only;
- one saved semantic highlight max **32 rects**;
- Belge Gezgini max **80 total**, max **40 per kind**;
- Reflow page-scoped;
- no parallel heavy processing;
- clear disposable state on memory warning;
- MRC ownership correctness is mandatory.

Preferred engineering ranges:

- normal reading roughly **30–50 MB**;
- special operations ideally well below **70–90 MB**;
- sustained/unbounded growth is a failure.

### Explicitly out of scope / Red

- on-device OCR;
- AI/ML inference;
- whole-document bitmap cache;
- persistent whole-document text/glyph index;
- high-resolution multi-page prerender;
- large background indexing service;
- modern cloud SDKs;
- heavy SMB/SFTP libraries merely for parity;
- heavy replacement PDF engine without measured physical-device proof.

If OCR is ever needed, preferred architecture is:

```text
PC/VPS -> OCR -> searchable PDF -> shared storage -> iPad1PDFReader
```

---

## 10. Build procedure

Expected environment: WSL Ubuntu + Theos + legacy `iPhoneOS6.1.sdk`.

From the project folder:

```bash
git fetch origin
git checkout feature/page-local-text-highlight
git pull origin feature/page-local-text-highlight

make clean
rm -rf .theos
make package FINALPACKAGE=1
```

`building for iOS 5.1.0 is deprecated` is an acceptable warning.

Do not claim build success unless the command actually finishes successfully.

---

## 11. Physical-device validation checklist

Physical **iPad 1 / iOS 5.1.1** is the source of truth. Simulator success is insufficient.

### Core smoke

- [ ] App launches.
- [ ] Library opens.
- [ ] Local PDF opens.
- [ ] Previous/next works.
- [ ] Pinch zoom stays centered and does not lean left.
- [ ] Zoom scale survives page change.
- [ ] Approximate viewport position survives page change while zoomed.
- [ ] Double-tap zoom works and returns to 1x.
- [ ] Direct page-number navigation validates range.
- [ ] Last page persists.
- [ ] Bookmark persists.

### iPad1Files / FTP integration

- [ ] PDFs in `/var/mobile/Media/iPad1Files/PDFs` appear.
- [ ] PDFs in `/var/mobile/Media/iPad1Files/Downloads` appear.
- [ ] Shared PDF opens in-place.
- [ ] No duplicate appears in PDFReader Documents.
- [ ] Cold-start `ipad1pdf://open?path=...` opens requested PDF.
- [ ] Warm-start URL while another PDF is open releases old document and opens new PDF.
- [ ] Warm-start URL also works when Search/Reflow/Outline/etc. is above the old reader.
- [ ] Invalid host/action fails safely.
- [ ] Missing path fails safely.
- [ ] Non-PDF path fails safely.
- [ ] Missing file shows `PDF bulunamadı.` or equivalent clear error.

### Highlight — current priority

Selectable-text PDF:

- [ ] Highlight mode generates active-page geometry only.
- [ ] Drag across text produces semantic highlight rectangles.
- [ ] Yellow renders correctly.
- [ ] Green renders correctly.
- [ ] Pink renders correctly.
- [ ] Orange renders correctly.
- [ ] Cyan/light-blue renders correctly.
- [ ] Text remains readable through transparency.
- [ ] Last-used color is remembered.
- [ ] Page change clears temporary geometry.
- [ ] Memory warning clears temporary geometry.
- [ ] Returning to the page redraws saved highlight.
- [ ] Flattened export preserves multi-rect highlight and color.

Scanned/image-only PDF:

- [ ] No OCR starts.
- [ ] Lack of text geometry fails gracefully.
- [ ] Rectangle/area highlight fallback remains usable.

### Search

- [ ] 100+ page search progresses incrementally.
- [ ] UI remains responsive between pages.
- [ ] Cancel works safely.
- [ ] Results remain capped at 40.
- [ ] Repeat search/cancel 10 times without progressive growth/crash.

### Thumbnails / navigation / memory

- [ ] 100+ page thumbnail scrolling retains max 8 thumbnails.
- [ ] Belge Gezgini remains max 80 total / 40 per kind.
- [ ] Reflow stays page-local through 30+ pages.
- [ ] Multiple large PDFs can be opened sequentially without progressive memory growth.
- [ ] Zoom/page-change/rotation stress for 10+ minutes does not progressively slow or crash.

### Page Manager

Use disposable PDFs:

- [ ] reorder;
- [ ] delete;
- [ ] rotate;
- [ ] leaving without save creates no output;
- [ ] explicit save creates a new edited PDF;
- [ ] original remains intact.

---

## 12. Immediate next action

Do **not** start another feature yet.

1. Pull `feature/page-local-text-highlight`.
2. Run a clean legacy build:

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

3. Fix only genuine iOS 5.1.1 / armv7 / MRC compile errors. Do not modernize the target.
4. Locate the generated `.deb`.
5. Install on the physical iPad 1.
6. Test URL handoff first:
   - cold start;
   - warm start with another PDF open;
   - warm start while a child reader screen is open;
   - missing file;
   - verify no duplicate physical PDF is created.
7. Test highlight:
   - normal selectable-text PDF;
   - all 5 fluorescent colors;
   - page change cleanup;
   - scanned/image PDF rectangle fallback;
   - flattened export.
8. Run memory/stability checks above.
9. Only after physical validation should this branch be considered for merge to `main` and version/tag update.

---

## 13. Next low-memory candidates after current phase is proven

Do not begin these before the Immediate next action is complete:

- tap existing highlight -> change color/delete;
- tap note marker -> open/edit directly;
- unify Outline/Contents into document navigator if cheap;
- bounded reading history/back-forward with a hard small cap (for example 10–20 locations);
- optional left/right edge page taps if gesture conflicts are acceptable;
- text copy only if it safely reuses page-local text geometry.

---

## 14. New-chat starter

Use only this in a new conversation:

```text
We are continuing https://github.com/SHapeloglu/iPad1PDFReader.
Read SESSION.md and the current source code first.
SESSION.md is the single authoritative handoff document.
Continue exactly from SESSION.md -> Immediate next action.
Preserve iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1 / armv7 / non-ARC / Theos / legacy iPhoneOS6.1 SDK constraints.
Do not consider any feature device-proven unless it was tested on the physical iPad 1.
```

That prompt plus `SESSION.md` is intentionally sufficient; no other handoff MD is required.
