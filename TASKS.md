# TASKS.md

## Priority 0 — prove current v3.1 development head on real hardware
- [ ] Clean-build with Theos + iPhoneOS6.1 legacy SDK.
- [ ] Fix compile errors without changing `armv7`, iOS 5.1.1, or non-ARC constraints.
- [ ] Install on iPad 1.
- [ ] Verify launch and local PDF open.
- [ ] Verify pinch zoom no longer visually jumps/leans left after zooming.
- [ ] Verify page changes preserve the current zoom scale.
- [ ] Verify page changes preserve the same approximate relative reading position while zoomed.
- [ ] Verify double-tap zoom works and returns to 1x.
- [ ] Verify direct page-number navigation.
- [ ] Verify bookmark list navigation.
- [ ] Verify page note add/view/edit/delete.
- [ ] Verify no crash on 50+ page PDF.
- [ ] Verify no crash on 200+ page PDF.
- [ ] Verify memory warning path does not corrupt reader state.

## Priority 1 — memory/stability validation
- [ ] Thumbnail: scroll through 100+ pages and confirm bounded cache behavior.
- [ ] Search: test large PDF; results must remain capped.
- [ ] Reflow: confirm only current page text is retained.
- [ ] Rotate device repeatedly while PDF is open and confirm zoom remains usable.
- [ ] Zoom in/out repeatedly for 5+ minutes.
- [ ] Change pages repeatedly while zoomed for 5+ minutes.
- [ ] Open/close multiple PDFs sequentially and watch for retained memory growth.
- [ ] Export annotated PDF and verify resulting file can be reopened.
- [ ] Page manager reorder/delete/rotate on a copy of a test PDF.

## Priority 2 — functional fixes only
- [ ] Improve outline destination-to-page resolution if a light solution is possible.
- [ ] Improve search handling for common encoded PDFs without adding a heavy engine.
- [ ] Add progress UI for long searches while keeping processing serial/page-based.
- [ ] Add cancel button for long search/network operations.
- [ ] Improve highlight placement/selection only if touch handling stays stable with scroll/zoom.
- [ ] Consider document-wide note/bookmark browser after real-device profiling; keep lists bounded.
- [ ] Validate HTTP/HTTPS/FTP imports on iOS 5.1.1.
- [ ] Validate WebDAV PROPFIND/GET against a real server.

## Priority 3 — optional integrations
Only after profiling:
- [ ] Evaluate lightweight `libsmb2` cross-build for armv7/iOS 5.1.1.
- [ ] Measure static size + runtime RAM before enabling SMB.
- [ ] Evaluate `libssh2` only if SFTP is genuinely needed.
- [ ] Prefer integration with `iPad1FTPDownloader` / `iPad1Files` instead of duplicating heavy networking stacks.

## Explicitly out of scope on-device
- [ ] Do **not** add OCR engine.
- [ ] Do **not** add AI/ML inference.
- [ ] Do **not** add full-document high-resolution page cache.
- [ ] Do **not** add modern cloud-provider SDKs.
- [ ] Do **not** replace Core Graphics with a heavy PDF engine unless measured and proven safe on 256 MB RAM.
