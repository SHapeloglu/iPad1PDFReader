# TESTING.md

## Source of truth
Physical **iPad 1 / Apple A4 / 256 MB RAM / iOS 5.1.1** is the source of truth. Simulator-only success is insufficient.

## Build validation

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Required:
- armv7;
- minimum iOS 5.1;
- legacy iPhoneOS 6.1 SDK;
- non-ARC / MRC.

`building for iOS 5.1.0 is deprecated` warning is acceptable.
Do not accept simulator `.tbd`/armv7 linker symptoms from iPhoneOS9.3.sdk.

## Text Reader v1 — current feature validation
Use files from iPad1Files where possible so in-place handoff is tested.

### Basic opening
- [ ] Small `.txt` opens in Text Reader.
- [ ] UTF-8 Turkish characters render correctly: `ç ğ ı İ ö ş ü Ç Ğ Ö Ş Ü`.
- [ ] `.md` opens as plain text; Markdown is not rendered.
- [ ] `.log` opens as plain text.
- [ ] `.csv` opens as plain text.
- [ ] `.json` opens as plain text; JSON is not parsed.
- [ ] `.xml` opens as plain text; XML is not parsed.
- [ ] `.sql` opens as plain text.
- [ ] `.py` opens as plain text.
- [ ] `.sh` opens as plain text.
- [ ] `.ini` opens as plain text.
- [ ] `.conf` opens as plain text.
- [ ] Text is read-only; no editing/save UI exists.
- [ ] File name appears in navigation title.
- [ ] Info shows full path and file size.

### Memory / file size
- [ ] File at or below 2 MiB loads successfully when valid UTF-8.
- [ ] File above 2 MiB shows a large-file warning.
- [ ] File above 2 MiB is not assigned to `UITextView`.
- [ ] Repeatedly opening/closing text files does not cause progressive memory growth.
- [ ] Invalid/non-UTF-8 text fails gracefully with encoding warning.

### Search
- [ ] `Ara -> Bul` finds an existing term.
- [ ] Found term scrolls into view.
- [ ] `Sonraki` moves to the next occurrence.
- [ ] Search wraps safely when reaching the end.
- [ ] `Önceki` moves to the previous occurrence.
- [ ] Search wraps safely when reaching the beginning.
- [ ] Missing term shows `Bulunamadı` without crash.
- [ ] Search does not create a background index.

### Text UI
- [ ] `A+` increases font size.
- [ ] Font size stops at the upper hard limit.
- [ ] `A-` decreases font size.
- [ ] Font size stops at the lower hard limit.
- [ ] Word Wrap starts enabled.
- [ ] Wrap can be disabled.
- [ ] Wrap-off allows horizontal movement for ordinary long lines.
- [ ] Wrap can be enabled again without losing the loaded file.
- [ ] Rotation/relayout does not crash.

### iPad1Files / URL handoff
- [ ] Text file opened from `/var/mobile/Media/iPad1Files/...` uses the same physical file.
- [ ] No duplicate file is created solely for iPad1Files handoff.
- [ ] `ipad1pdf://open?path=/var/mobile/Media/iPad1Files/Documents/test.txt` opens Text Reader.
- [ ] Percent-encoded spaces in a text path decode correctly.
- [ ] Supported text extension routes to Text Reader.
- [ ] `.pdf` still routes to PDF Reader.
- [ ] Unsupported extension shows `Bu dosya türü desteklenmiyor`.
- [ ] Nonexistent path fails safely.

## Core PDF smoke test — mandatory regression after Text Reader changes
- [ ] App launches.
- [ ] Library opens.
- [ ] Local PDF opens in `PDFReaderViewController`, not Text Reader.
- [ ] Previous/next works.
- [ ] Pinch zoom does not jump/lean left.
- [ ] Zoom scale survives page change.
- [ ] Approximate reading position survives page change while zoomed.
- [ ] Double-tap zoom works and returns to 1x.
- [ ] Direct page-number navigation validates range.
- [ ] Last page persists.
- [ ] Bookmark persists.
- [ ] Existing PDF search still works.
- [ ] Existing PDF highlight path still opens and draws annotations.
- [ ] Existing PDF notes still add/view/edit/delete.
- [ ] Existing PDF bookmarks still add/remove/persist.

## iPad1Files PDF integration
- [ ] PDFs in `/var/mobile/Media/iPad1Files/PDFs` appear.
- [ ] PDFs in `/var/mobile/Media/iPad1Files/Downloads` appear.
- [ ] Shared PDF opens in-place.
- [ ] Opening shared PDF does not silently create a duplicate in app Documents.
- [ ] `ipad1pdf://open?path=...` opens the requested existing PDF.
- [ ] Invalid/nonexistent path fails safely.

## PDF Search
- [ ] 100+ page text PDF search progresses incrementally.
- [ ] UI remains responsive between pages.
- [ ] Cancel stops search safely.
- [ ] Results remain capped at 40.
- [ ] No persistent full-document text index appears.
- [ ] Repeat search/cancel 10 times without progressive slowdown/crash.

## Belge Gezgini
- [ ] Bookmarks list correctly.
- [ ] Notes list correctly.
- [ ] Highlights list correctly.
- [ ] Selecting an item jumps to correct page.
- [ ] Annotation summary remains max 80 total and max 40 per kind.
- [ ] Repeated open/close on a 200+ page PDF does not grow memory progressively.

## Outline
- [ ] Direct `/Dest` outline target navigates correctly.
- [ ] Direct `/A /GoTo` array target navigates correctly.
- [ ] Unsupported/named destination fails gracefully without crash.

## Highlight — current PDF validation
### Selectable text PDF
- [ ] Text selection uses only active-page temporary geometry.
- [ ] Selected text can be highlighted.
- [ ] Yellow fluorescent color renders correctly.
- [ ] Green fluorescent color renders correctly.
- [ ] Pink fluorescent color renders correctly.
- [ ] Orange fluorescent color renders correctly.
- [ ] Cyan/light-blue fluorescent color renders correctly.
- [ ] Text remains readable through highlight transparency.
- [ ] Last-used color is remembered if implemented.
- [ ] Page change clears temporary selection state.
- [ ] Memory warning clears temporary selection state.
- [ ] Returning to the page redraws saved highlight from compact annotation data.

### Image/scanned PDF without text layer
- [ ] Real text selection fails gracefully.
- [ ] No OCR starts on-device.
- [ ] Optional region/rectangle highlight remains usable as fallback.

### Highlight maintenance
When implemented:
- [ ] Tap/select existing highlight.
- [ ] Change color.
- [ ] Delete highlight.
- [ ] Flattened export preserves color.

## Notes
- [ ] Add note.
- [ ] View note.
- [ ] Edit note.
- [ ] Delete note.
- [ ] Note remains page-specific.
- [ ] Tap marker to open when that feature is implemented.

## Page Manager
Use disposable PDFs.
- [ ] Reorder pages.
- [ ] Delete page.
- [ ] Rotate page.
- [ ] Leaving without explicit save does not generate output.
- [ ] `Kaydet` creates a new edited PDF.
- [ ] Original remains intact.

## Thumbnail memory test
- [ ] Open 100+ page PDF.
- [ ] Scroll bottom/back repeatedly.
- [ ] Cache remains max 8 thumbnails.
- [ ] Cache can recover after memory pressure.

## Reflow memory test
- [ ] Move through 30+ pages.
- [ ] Only current/page-scoped text is retained.
- [ ] Font size controls remain responsive.

## Long reader stability
- [ ] Keep large PDF open 10+ minutes.
- [ ] Zoom 1x -> max -> 1x repeatedly.
- [ ] Change pages rapidly at 1x.
- [ ] Change pages rapidly while zoomed.
- [ ] Rotate portrait/landscape repeatedly.
- [ ] Open/close multiple PDFs sequentially.
- [ ] Alternate opening PDFs and supported text files repeatedly.
- [ ] No progressive slowdown or crash.

## Memory warning
Under pressure verify:
- [ ] thumbnail cache clears;
- [ ] PDF search disposable results/state can clear safely;
- [ ] temporary highlight/text-selection geometry clears;
- [ ] Belge Gezgini temporary summary can clear;
- [ ] off-screen Text Reader releases loaded text on memory warning;
- [ ] current PDF/page remains recoverable.

## Companion-app boundary regression
PDFReader is not being expanded as a file manager or FTP client.

- [ ] Existing legacy HTTP/FTP/WebDAV compatibility does not regress.
- [ ] No new transfer queue/resume subsystem is added here.
- [ ] Shared file management remains delegated to iPad1Files.
- [ ] FTP transfer work remains delegated to iPad1FTPDownloader.
- [ ] Text Reader remains viewer-only and does not add rename/delete/copy/save workflows.

## RAM engineering targets
- normal PDF reading: roughly **30–50 MB preferred**;
- special PDF operations: ideally well below **70–90 MB**;
- Text Reader full-load hard limit: **2 MiB source file**;
- no feature may introduce unbounded arrays, whole-document PDF text retention or multi-page full-resolution bitmap caching;
- sustained unbounded memory growth is a test failure.
