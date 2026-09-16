# TESTING.md

## Source of truth
Physical **iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1** is the source of truth. Simulator-only success is insufficient.

## Build validation
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```
Required:
- armv7;
- minimum iOS 5.1;
- legacy iPhoneOS 6.1 SDK;
- non-ARC / MRC.

`building for iOS 5.1.0 is deprecated` warning is acceptable.

## Text Reader v1
### Basic opening
- [ ] Small `.txt` opens in Text Reader.
- [ ] UTF-8 Turkish characters render correctly: `ç ğ ı İ ö ş ü Ç Ğ Ö Ş Ü`.
- [ ] `.log`, `.csv`, `.json`, `.xml`, `.sql`, `.py`, `.sh`, `.ini`, `.conf` open as plain text.
- [ ] Text remains read-only; no editing/save UI exists.
- [ ] File name appears in navigation title.
- [ ] Info shows full path and file size.

### Memory / file size
- [ ] File at or below 2 MiB loads when valid UTF-8.
- [ ] File above 2 MiB is rejected before `UITextView` load.
- [ ] Invalid/non-UTF-8 text fails gracefully.
- [ ] Repeated open/close does not cause progressive memory growth.

### Search / UI
- [ ] Find / Next / Previous work and wrap safely.
- [ ] Missing term shows `Bulunamadı` without crash.
- [ ] A+ / A- obey hard limits.
- [ ] Word Wrap on/off works.
- [ ] Rotation/relayout does not crash.

## Markdown Reader v2
Use `.md` files below the same 2 MiB Text Reader limit.

### Reading mode
- [ ] `.md` opens in Markdown reading mode by default.
- [ ] `Kaynak` switches to original Markdown source.
- [ ] `MD Oku` returns to reading mode.
- [ ] headings `#`..`######` become readable heading markers.
- [ ] `**bold**`, `*italic*`, `_italic_` and inline backticks remain readable with syntax markers removed.
- [ ] `-`, `*`, `+` bullet items display as `•` items.
- [ ] numbered-list text remains readable.
- [ ] blockquotes display with the lightweight quote marker.
- [ ] fenced code blocks remain visible as indented code text.
- [ ] horizontal rules display as a lightweight text rule.
- [ ] links display as readable `label <URL>` text.
- [ ] Markdown image syntax does not decode/render an image; a readable text placeholder appears instead.
- [ ] plain Markdown source is never modified on disk.

### Markdown regressions
- [ ] Find / Next / Previous work in reading mode.
- [ ] Find / Next / Previous work after switching to source mode.
- [ ] A+ / A- work in both modes.
- [ ] Word Wrap works in both modes.
- [ ] Turkish UTF-8 survives mode switching.
- [ ] repeat `Kaynak` / `MD Oku` 30 times without crash or progressive slowdown.
- [ ] open/close several Markdown files repeatedly without progressive memory growth.
- [ ] no JavaScript, browser engine or remote asset fetch starts.

## iPad1Files handoff
- [ ] `ipad1files://pick?callback=ipad1pdf` opens picker under `/var/mobile/Media/iPad1Files`.
- [ ] Callback survives nested folders.
- [ ] PDF returns through `ipad1pdf://open?path=...`.
- [ ] Supported text/Markdown returns to Text Reader.
- [ ] Same physical file is used; no duplicate copy.
- [ ] Percent-encoded spaces and Turkish characters decode correctly.
- [ ] Unsupported extension fails visibly and safely.
- [ ] Nonexistent path fails safely.

## Core PDF smoke test
- [ ] App launches and library opens.
- [ ] Local/shared PDF opens in `PDFReaderViewController`.
- [ ] Previous/next works.
- [ ] Pinch zoom stays centered.
- [ ] Zoom survives page change.
- [ ] Double-tap zoom works.
- [ ] Direct page-number navigation validates range.
- [ ] Last page and bookmark persist.
- [ ] Search, notes, highlights and page manager still work.

## Reading UX
- [ ] Day / Sepia / Night work.
- [ ] Page Lock blocks unintended navigation/zoom.
- [ ] Fit Page returns to full-page view.
- [ ] Fit Width fills usable width and starts near page top.
- [ ] Konum Geri / Konum İleri work.
- [ ] Empty reading history shows a safe message.
- [ ] Edge tap left/right changes page at 1x.
- [ ] Edge tap does not fire while zoomed above ~1x.
- [ ] Edge tap does not interfere with drawing/text-mark selection.

## Gezinti Merkezi / Outline
- [ ] İçindekiler section lists bounded outline items.
- [ ] Yer İmleri section lists bookmarks.
- [ ] Notlar section lists notes.
- [ ] İşaretler section lists Highlight / Altı Çizili / Üstü Çizili.
- [ ] Selecting any row jumps to correct page.
- [ ] Outline parsing never retains more than 80 entries.
- [ ] Annotation summary remains max 80 total and max 40 per section/kind.
- [ ] Repeated open/close on 200+ page PDF does not progressively grow memory.

## Highlight
### Selectable text PDF
- [ ] `Metin İşaretle -> Highlight` opens color palette.
- [ ] Yellow / green / pink / orange / cyan render correctly.
- [ ] Text remains readable through highlight.
- [ ] Page change clears temporary selection geometry.
- [ ] Returning to page redraws saved highlight.

### Scanned/image PDF
- [ ] Highlight falls back to rectangular region selection.
- [ ] No OCR starts on-device.

### Direct interaction
- [ ] Tap existing highlight directly.
- [ ] Recolor from direct tap.
- [ ] Delete from direct tap.
- [ ] `İşaret Düzenle` still recolors/deletes as fallback UI.

## Underline
- [ ] `Metin İşaretle -> Altını Çiz` works on selectable-text PDF.
- [ ] Only active-page text geometry is used.
- [ ] Mark follows intersected text rects; no freehand/whole-document geometry.
- [ ] Page away/back redraws underline.
- [ ] Reopen PDF redraws underline.
- [ ] Tap underline directly -> recolor/delete.
- [ ] `İşaret Düzenle` can recolor/delete underline.
- [ ] Scanned/image-only page shows selectable-text warning.
- [ ] No OCR or region fallback starts for underline.

## Strikeout
- [ ] `Metin İşaretle -> Üstünü Çiz` works on selectable-text PDF.
- [ ] Only active-page text geometry is used.
- [ ] Page away/back redraws strikeout.
- [ ] Reopen PDF redraws strikeout.
- [ ] Tap strikeout directly -> recolor/delete.
- [ ] `İşaret Düzenle` can recolor/delete strikeout.
- [ ] Scanned/image-only page shows selectable-text warning.
- [ ] No OCR or region fallback starts for strikeout.

## Direct Note interaction
- [ ] Add note.
- [ ] Tap note marker directly.
- [ ] View note.
- [ ] Edit note.
- [ ] Delete note.
- [ ] Note remains page-specific.
- [ ] Tapping note near page edge opens note instead of changing page.

## Flattened annotation export
- [ ] Highlight color preserved.
- [ ] Underline rendered in exported PDF.
- [ ] Strikeout rendered in exported PDF.
- [ ] Original PDF remains unchanged.
- [ ] Output is a new PDF.

## PDF Search
- [ ] 100+ page search progresses incrementally.
- [ ] Cancel stops safely.
- [ ] Results remain capped at 40.
- [ ] No persistent full-document text index.
- [ ] Repeat search/cancel 10 times without progressive slowdown/crash.

## Page Manager
Use disposable PDFs.
- [ ] Reorder pages.
- [ ] Delete page.
- [ ] Rotate page.
- [ ] Leaving without save produces no output.
- [ ] `Kaydet` creates a new edited PDF.
- [ ] Original remains intact.

## Memory / stability
- [ ] 100+ page thumbnail scrolling; cache remains max 8.
- [ ] Reflow remains page-local.
- [ ] Direct annotation hit-test never scans more than 80 current-page annotations.
- [ ] Text-mark selection uses max 160 temporary page rects and persists max 32 rects per mark.
- [ ] Memory warning clears temporary text-mark selection geometry.
- [ ] Text/Markdown source remains capped at 2 MiB.
- [ ] Open/close several large PDFs sequentially.
- [ ] Zoom/page-change for 10 minutes.
- [ ] Rotate while zoomed repeatedly.
- [ ] Test 50+, 200+ page PDFs.
- [ ] No progressive slowdown or crash.

## Companion-app boundary regression
- [ ] No general file-manager functionality added to PDFReader.
- [ ] No transfer queue/resume/download engine added to PDFReader.
- [ ] No media decode/playback added to PDFReader.
- [ ] Shared file management remains iPad1Files responsibility.
- [ ] Network transfer remains iPad1FTPDownloader/iPad1Downloader responsibility.
- [ ] Media playback remains iPad1Player responsibility.

## RAM engineering targets
- normal PDF reading: roughly **30–50 MB preferred**;
- special operations: ideally well below **70–90 MB**;
- Text/Markdown source full-load max **2 MiB**;
- no unbounded arrays, document-wide PDF text retention, spatial annotation index or multi-page full-resolution bitmap cache;
- sustained unbounded memory growth is a failure.
