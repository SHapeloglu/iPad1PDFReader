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

## Core smoke test
- [ ] App launches.
- [ ] Library opens.
- [ ] Local PDF opens.
- [ ] Previous/next works.
- [ ] Pinch zoom does not jump/lean left.
- [ ] Zoom scale survives page change.
- [ ] Approximate reading position survives page change while zoomed.
- [ ] Double-tap zoom works and returns to 1x.
- [ ] Direct page-number navigation validates range.
- [ ] Last page persists.
- [ ] Bookmark persists.

## iPad1Files integration
- [ ] PDFs in `/var/mobile/Media/iPad1Files/PDFs` appear.
- [ ] PDFs in `/var/mobile/Media/iPad1Files/Downloads` appear.
- [ ] Shared PDF opens in-place.
- [ ] Opening shared PDF does not silently create a duplicate in app Documents.
- [ ] `ipad1pdf://open?path=...` opens the requested existing PDF.
- [ ] Invalid/nonexistent path fails safely.

## Search
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

## Highlight — current priority
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
- [ ] No progressive slowdown or crash.

## Memory warning
Under pressure verify:
- [ ] thumbnail cache clears;
- [ ] search disposable results/state can clear safely;
- [ ] temporary highlight/text-selection geometry clears;
- [ ] Belge Gezgini temporary summary can clear;
- [ ] current PDF/page remains recoverable.

## Companion-app boundary regression
PDFReader is not being expanded as a file manager or FTP client.

- [ ] Existing legacy HTTP/FTP/WebDAV compatibility does not regress.
- [ ] No new transfer queue/resume subsystem is added here.
- [ ] Shared file management remains delegated to iPad1Files.
- [ ] FTP transfer work remains delegated to iPad1FTPDownloader.

## RAM engineering targets
- normal reading: roughly **30–50 MB preferred**;
- special operations: ideally well below **70–90 MB**;
- no feature may introduce unbounded arrays, whole-document text retention or multi-page full-resolution bitmap caching;
- sustained unbounded memory growth is a test failure.
