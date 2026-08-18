# TASKS.md

## Priority 0 — finish and prove current development head
- [ ] Pull current `main` and clean-build with legacy Theos/iPhoneOS6.1 SDK.
- [ ] Keep `ARCHS = armv7` and `TARGET = iphone:clang:6.1:5.1` unchanged.
- [ ] Fix only actual iOS 5.1.1 / MRC compile issues.
- [ ] Install on physical iPad 1.
- [ ] Verify shared PDFs from iPad1Files open without duplicate copies.
- [ ] Verify `ipad1pdf://open?path=...` handoff.
- [ ] Verify zoom centering, zoom persistence, double-tap and page-number navigation.
- [ ] Verify Belge Gezgini, search progress/cancel, outline page jumps and explicit Page Manager save.

## Priority 1 — real text highlight + fluorescent palette
Primary current feature phase.

- [ ] Implement text-selection highlight only for the active page.
- [ ] Do not build a whole-document text/glyph index.
- [ ] Keep temporary selection geometry bounded and clear it on page change.
- [ ] Clear temporary selection state on memory warning.
- [ ] Add fluorescent colors:
  - [ ] yellow
  - [ ] green
  - [ ] pink
  - [ ] orange
  - [ ] cyan/light blue
- [ ] Remember last-used highlight color with lightweight persistence.
- [ ] Persist only compact highlight annotation data: page + rect(s) + color.
- [ ] Keep rectangular region highlight as fallback for scanned/image PDFs.
- [ ] If there is no selectable text layer, fail gracefully; never start OCR on-device.
- [ ] Ensure flattened export preserves chosen highlight colors.

## Priority 2 — annotation/document UX after highlight is stable
- [ ] Tap existing highlight -> change color / delete.
- [ ] Tap note marker -> open note directly.
- [ ] Include Outline/Contents in unified document navigation if low-cost.
- [ ] Add bounded reading history/back-forward, hard small cap (for example 10–20 locations).
- [ ] Consider left/right edge page taps only if they do not conflict with zoom/annotation gestures.
- [ ] Add text copy only if it can safely reuse page-local selection state.

## Priority 3 — memory/stability validation
- [ ] 100+ page thumbnail scrolling; cache remains max 8.
- [ ] Search results remain max 40.
- [ ] Search/cancel repeatedly; no progressive growth.
- [ ] Reflow remains page-local.
- [ ] Belge Gezgini remains bounded to 80 annotation-summary items, max 40 per kind.
- [ ] Open/close several large PDFs sequentially.
- [ ] Zoom/page-change for 10 minutes.
- [ ] Rotate while zoomed repeatedly.
- [ ] Trigger memory pressure and verify temporary selection data is dropped.
- [ ] Test 50+, 200+ page PDFs.

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
- [ ] No persistent full-document text index.
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
