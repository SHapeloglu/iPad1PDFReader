# TESTING.md

## Test target
Physical **iPad 1 / iOS 5.1.1 / 256 MB RAM** is the source of truth. Simulator-only success is insufficient.

## Build validation
```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Expected target:
- `armv7`
- minimum iOS `5.1`
- legacy iPhoneOS `6.1` SDK
- non-ARC

`ld: warning: building for iOS 5.1.0 is deprecated` is acceptable.
Do not accept simulator `.tbd` warnings from iPhoneOS9.3.sdk.

## Smoke test
- [ ] Application launches.
- [ ] Library screen appears.
- [ ] PDFs from app Documents appear.
- [ ] PDFs from `/var/mobile/Media/iPad1Files/PDFs` appear.
- [ ] PDFs from `/var/mobile/Media/iPad1Files/Downloads` appear.
- [ ] Shared PDFs open in-place without making duplicate copies.
- [ ] `ipad1pdf://open?path=...` opens a shared PDF from iPad1Files.
- [ ] Previous/next navigation works.
- [ ] Pinch zoom works without the page jumping left.
- [ ] Double-tap zoom works; double tap again returns to 1x.
- [ ] Current zoom and approximate reading position survive page navigation.
- [ ] `Sayfaya Git` validates range.
- [ ] Last page and bookmarks persist.

## Search
- [ ] Search a common term in a 100+ page text PDF.
- [ ] Progress advances page-by-page instead of freezing for the whole document.
- [ ] Tap `İptal`; search stops and UI remains responsive.
- [ ] Maximum retained results remains 40.
- [ ] No persistent full-document text index is created.
- [ ] Repeat search/cancel 10 times; no progressive slowdown/crash.

## Belge Gezgini
- [ ] Bookmark section lists document bookmarks.
- [ ] Note section lists page notes.
- [ ] Highlight section lists highlights.
- [ ] Tapping an item jumps to the correct page.
- [ ] Summary stays bounded to 80 annotation-summary items and 40 per kind.
- [ ] Open/close repeatedly on a 200+ page PDF without progressive memory growth.

## Outline
- [ ] Open a PDF with direct `/Dest` outline targets.
- [ ] Resolved outline rows show page number and navigate correctly.
- [ ] Unresolved/named destinations remain non-crashing and show as unresolved.

## Annotation
- [ ] Drawing still works.
- [ ] `Highlight Seç` disables normal scroll only during the one-shot selection.
- [ ] Drag a rectangle; highlight appears at the selected position.
- [ ] After selection, normal scroll/zoom automatically returns.
- [ ] Cancel/interrupted highlight does not leave scroll disabled.
- [ ] Add/view/edit/delete a page note.
- [ ] Add simple signature.
- [ ] Export flattened annotated PDF and reopen it.

## Page Manager
Use disposable PDFs.
- [ ] Reorder pages in Edit mode.
- [ ] Delete page.
- [ ] Tap a page to rotate in 90° increments.
- [ ] Leaving without `Kaydet` does not export a new PDF.
- [ ] `Kaydet` creates `*-edited.pdf` and preserves the original.
- [ ] Zero-page export is rejected safely.

## Memory-focused reader test
- [ ] Open a large PDF and stay in reader for 10 minutes.
- [ ] Repeatedly zoom 1x -> max -> 1x.
- [ ] Change pages rapidly while zoomed at 2x or higher.
- [ ] Rotate portrait/landscape repeatedly while zoomed.
- [ ] Return to library and open a second PDF.
- [ ] No progressive slowdown or crash.

## Thumbnails
- [ ] Open a 100+ page document.
- [ ] Scroll to bottom and back.
- [ ] Cache remains bounded to 8 thumbnails.
- [ ] Images continue loading after memory pressure.

## Reflow
- [ ] Move through 30+ pages.
- [ ] Font A-/A/A+ works.
- [ ] Only page-level text is retained.

## Memory warning
If possible create pressure and verify:
- [ ] thumbnail cache clears;
- [ ] temporary bookmark/note arrays clear;
- [ ] active highlight selection is cancelled safely;
- [ ] off-screen navigator summary can be discarded safely;
- [ ] search results can be discarded safely;
- [ ] current document/page remains recoverable.

## Legacy network maintenance test
Built-in network code is no longer a feature-growth priority because FTP/file management belong to companion apps.
- [ ] Existing HTTP import still works.
- [ ] Existing FTP import does not regress.
- [ ] Existing WebDAV PROPFIND/GET does not regress.

SMB/SFTP are not required.

## RAM goals
Engineering targets, not guarantees:
- normal reading: roughly 30–50 MB preferred;
- thumbnail/search/reflow/navigator operations: keep as far below 70–90 MB as practical;
- no new feature may introduce full-page multi-cache, whole-document text retention, or unbounded lists;
- any sustained unbounded memory growth fails testing.
