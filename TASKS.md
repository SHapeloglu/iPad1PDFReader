# TASKS.md

## Priority 0 — prove current v3.2 development head on real hardware
- [ ] Clean-build with Theos + iPhoneOS6.1 legacy SDK.
- [ ] Fix compile errors without changing `armv7`, iOS 5.1.1, or non-ARC constraints.
- [ ] Install on iPad 1.
- [ ] Verify launch and local PDF open.
- [ ] Verify pinch zoom no longer visually jumps/leans left after zooming.
- [ ] Verify page changes preserve the current zoom scale and approximate reading position.
- [ ] Verify double-tap zoom.
- [ ] Verify direct page-number navigation.
- [ ] Verify `Belge Gezgini` bookmark/note/highlight lists and page jump.
- [ ] Verify drag-to-select highlight and automatic return to normal scrolling.
- [ ] Verify page note add/view/edit/delete.
- [ ] Verify outline rows with direct destinations jump to the correct page.
- [ ] Verify search progress and cancel on 100+ page PDFs; results remain capped at 40.
- [ ] Verify iPad1Files PDFs/Downloads appear without duplicate copies.
- [ ] Verify `ipad1pdf://open?path=...` handoff from iPad1Files.
- [ ] Verify Page Manager only exports on explicit `Kaydet`.
- [ ] Verify no crash on 50+ and 200+ page PDFs.
- [ ] Verify memory warning path does not corrupt reader state.

## Priority 1 — memory/stability validation
- [ ] Thumbnail: scroll through 100+ pages and confirm cache remains capped at 8.
- [ ] Reflow: confirm only page-level text is retained.
- [ ] Rotate device repeatedly while PDF is open and confirm zoom remains usable.
- [ ] Zoom/change pages repeatedly for 5+ minutes.
- [ ] Open/close multiple PDFs sequentially and watch for retained memory growth.
- [ ] Open `Belge Gezgini` repeatedly on 200+ page PDF and confirm no progressive growth.
- [ ] Cancel repeated searches at different pages and confirm reader remains responsive.
- [ ] Export annotated PDF and reopen it.
- [ ] Page manager reorder/delete/rotate on a disposable test PDF.

## Implemented but still pending physical-device proof
- [x] Bounded document-wide bookmark/note/highlight navigator (max 80 annotation-summary items).
- [x] Serial page-by-page search progress with cancel; max 40 results.
- [x] Direct outline destination resolution for lightweight `/Dest` and `/A /GoTo` array targets.
- [x] One-shot drag rectangle highlight without bitmap/text index cache.
- [x] Explicit Page Manager save/export workflow.
- [x] iPad1Files shared root scanning (`PDFs`, `Downloads`).
- [x] `ipad1pdf` URL scheme receiver.

## Functional follow-ups after v3.2 is stable
- [ ] Improve search extraction for common encoded PDFs without adding a heavy PDF engine.
- [ ] Extend outline resolution only for formats that can be handled cheaply (named destinations remain optional).
- [ ] Add annotation delete/edit affordances for highlight only if touch UX remains reliable.
- [ ] Keep built-in network code in maintenance mode; prefer iPad1FTPDownloader/iPad1Files integration instead of duplicating features.

## Explicitly out of scope on-device
- [ ] Do **not** add OCR engine.
- [ ] Do **not** add AI/ML inference.
- [ ] Do **not** add full-document high-resolution page cache.
- [ ] Do **not** add background full-document text indexing.
- [ ] Do **not** add modern cloud-provider SDKs.
- [ ] Do **not** add `libsmb2`/`libssh2` merely for parity; only revisit with a concrete need and physical RAM profiling.
- [ ] Do **not** replace Core Graphics with a heavy PDF engine unless measured and proven safe on 256 MB RAM.
