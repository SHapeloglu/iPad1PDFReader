# TASKS.md

## Priority 0 — Text Reader v1 current branch
Current branch: `feature/text-reader-v1`.

Implementation target:
- [x] Keep `PDFReaderViewController` separate from text viewing.
- [x] Add `TextReaderViewController` using legacy `UITextView`.
- [x] Support `.txt`, `.md`, `.log`, `.csv`, `.json`, `.xml`, `.sql`, `.py`, `.sh`, `.ini`, `.conf` as plain text.
- [x] UTF-8 read-only viewing.
- [x] A- / A+ font controls.
- [x] Word Wrap toggle.
- [x] Find / Next / Previous search.
- [x] Show file name and full path in Info.
- [x] Check file size before loading.
- [x] Hard full-load limit of 2 MiB for iPad 1 safety.
- [x] Keep `ipad1pdf://open?path=...` and route by extension.
- [x] Open iPad1Files paths in-place with no duplicate copy.
- [x] Unsupported extension alert.
- [ ] Clean-build with legacy Theos/iPhoneOS6.1 SDK.
- [ ] Fix only actual legacy compile issues without changing platform constraints.
- [ ] Install on physical iPad 1.
- [ ] Run Text Reader tests in `TESTING.md`.
- [ ] Run PDF regression tests after Text Reader validation.

First version deliberately excludes:
- [ ] no editing/save;
- [ ] no syntax highlighting;
- [ ] no Markdown renderer;
- [ ] no JSON/XML parser;
- [ ] no background/full-document index;
- [ ] no OCR/AI/ML.

## Priority 1 — finish and prove current PDF development head
- [x] Legacy clean-build of page-local highlight branch completed before Text Reader branch creation.
- [ ] Install latest combined branch on physical iPad 1.
- [ ] Verify shared PDFs from iPad1Files open without duplicate copies.
- [ ] Verify `ipad1pdf://open?path=...` PDF handoff.
- [ ] Verify zoom centering, zoom persistence, double-tap and page-number navigation.
- [ ] Verify Belge Gezgini, search progress/cancel, outline page jumps and explicit Page Manager save.

## Priority 2 — real text highlight + fluorescent palette physical validation
Current code contains bounded page-local text-geometry/highlight work, but it is not fully device-proven.

- [ ] Verify text-selection highlight only for the active page.
- [ ] Verify no whole-document text/glyph index.
- [ ] Verify temporary selection geometry clears on page change.
- [ ] Verify temporary selection state clears on memory warning.
- [ ] Verify fluorescent colors:
  - [ ] yellow
  - [ ] green
  - [ ] pink
  - [ ] orange
  - [ ] cyan/light blue
- [ ] Verify last-used highlight color persistence.
- [ ] Verify compact highlight annotation data: page + rect(s) + color.
- [ ] Verify rectangular region highlight fallback for scanned/image PDFs.
- [ ] Verify no OCR starts when selectable text is unavailable.
- [ ] Verify flattened export preserves chosen highlight colors.

## Priority 3 — annotation/document UX after current phases are stable
- [ ] Tap existing highlight -> change color / delete.
- [ ] Tap note marker -> open note directly.
- [ ] Include Outline/Contents in unified document navigation if low-cost.
- [ ] Add bounded reading history/back-forward, hard small cap (for example 10–20 locations).
- [ ] Consider left/right edge page taps only if they do not conflict with zoom/annotation gestures.
- [ ] Add text copy only if it can safely reuse page-local selection state.

## Priority 4 — memory/stability validation
- [ ] 100+ page thumbnail scrolling; cache remains max 8.
- [ ] PDF search results remain max 40.
- [ ] Search/cancel repeatedly; no progressive growth.
- [ ] Reflow remains page-local.
- [ ] Belge Gezgini remains bounded to 80 annotation-summary items, max 40 per kind.
- [ ] Open/close several large PDFs sequentially.
- [ ] Zoom/page-change for 10 minutes.
- [ ] Rotate while zoomed repeatedly.
- [ ] Trigger memory pressure and verify temporary selection data is dropped.
- [ ] Test 50+, 200+ page PDFs.
- [ ] Repeatedly open/close supported text files under 2 MiB without progressive growth.
- [ ] Verify >2 MiB text files are rejected before `UITextView` load.

## Companion-app boundary — do not duplicate
### Leave to iPad1Files
- [ ] Do not implement general copy/move/rename/delete browser features in PDFReader.
- [ ] Do not duplicate favorites/file organization/Open With registry.

### Leave to iPad1FTPDownloader
- [ ] Do not expand FTP browsing/downloading/upload/queue/resume in PDFReader.
- [ ] Existing PDFReader FTP/WebDAV code is maintenance-only.

## Explicitly out of scope on-device
- [ ] No OCR engine.
- [ ] No AI/ML inference.
- [ ] No whole-document high-resolution bitmap cache.
- [ ] No persistent full-document PDF text index.
- [ ] No large background indexing service.
- [ ] No modern cloud-provider SDKs.
- [ ] No SMB/SFTP library merely for competitor parity.
- [ ] No heavy replacement PDF engine without measured physical-device proof.

## Definition of done
A feature is complete only when:
- it builds with the legacy target;
- it runs on physical iPad 1;
- memory use is bounded;
- relevant `TESTING.md` checks pass;
- docs are updated.
