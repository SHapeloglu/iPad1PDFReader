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
- [x] Clean-build with legacy Theos/iPhoneOS6.1 SDK.
- [x] Install latest combined branch on physical iPad 1.
- [ ] Run remaining Text Reader tests in `TESTING.md`.
- [ ] Complete iPad1Files picker callback validation.

First version deliberately excludes:
- [x] no editing/save;
- [x] no syntax highlighting;
- [x] no Markdown renderer;
- [x] no JSON/XML parser;
- [x] no background/full-document index;
- [x] no OCR/AI/ML.

## Priority 1 — current PDF reader UX, iPad 1 safe
Already implemented on current branch:
- [x] bounded reading-location back/forward, cap 20;
- [x] Day / Sepia / Night themes;
- [x] Page Lock;
- [x] highlight recolor/delete;
- [x] scanned/image PDF region-highlight fallback without OCR;
- [x] low-memory Fit Page control;
- [x] low-memory Fit Width control;
- [x] rename ambiguous `Geri/İleri` to `Konum Geri/Konum İleri`;
- [x] rename `Belge Gezgini` menu entry to `Gezinti Merkezi`.

Physical iPad 1 PASS already observed:
- [x] PDF open/render;
- [x] reading-location back/forward;
- [x] Day / Sepia / Night;
- [x] Page Lock;
- [x] highlight create/edit/recolor/delete;
- [x] region-highlight fallback.

Needs physical validation after latest build:
- [ ] Fit Page;
- [ ] Fit Width;
- [ ] no-history alerts for Konum Geri / Konum İleri;
- [ ] edge-tap previous/next page behavior and gesture conflicts.

## Priority 2 — annotation/document UX after current build is stable
- [ ] Tap existing highlight -> change color / delete, only if touch hit-testing remains lightweight and does not interfere with scroll/zoom.
- [ ] Tap note marker -> open/edit/delete directly, only if gesture conflicts are clean on physical iPad 1.
- [ ] Keep Outline / Bookmark / Notes / Highlights under a unified bounded `Gezinti Merkezi` experience.
- [ ] Add selected-text Copy only if it can reuse page-local selection state without a whole-document text index.

## Priority 3 — candidate PDF-only improvements requiring profiling
- [ ] Manual margin crop / visible-area crop. Do not implement automatic whole-document crop analysis.
- [ ] Consider page-view polish only if it does not require multi-page full-resolution caching.
- [ ] PDF forms only after a separate feasibility review; no heavy replacement PDF engine.

## Priority 4 — memory/stability validation
- [ ] 100+ page thumbnail scrolling; cache remains max 8.
- [ ] PDF search results remain max 40.
- [ ] Search/cancel repeatedly; no progressive growth.
- [ ] Reflow remains page-local.
- [ ] Gezinti Merkezi remains bounded to 80 annotation-summary items, max 40 per kind.
- [ ] Open/close several large PDFs sequentially.
- [ ] Zoom/page-change for 10 minutes.
- [ ] Rotate while zoomed repeatedly.
- [ ] Trigger memory pressure and verify temporary selection data is dropped.
- [ ] Test 50+, 200+ page PDFs.
- [ ] Repeatedly open/close supported text files under 2 MiB without progressive growth.
- [ ] Verify >2 MiB text files are rejected before `UITextView` load.

## Companion-app boundary — mandatory ownership gate
### Leave to iPad1Files
- [x] Do not implement general copy/move/rename/delete browser features in PDFReader.
- [x] Do not duplicate favorites/file organization/Open With registry.
- [x] Normal suite file-type routing belongs in iPad1Files.

### Leave to iPad1FTPDownloader / iPad1Downloader
- [x] Do not expand HTTP/HTTPS/FTP/WebDAV browse/download/upload/queue/resume in PDFReader.
- [x] Existing PDFReader network code remains compatibility-only pending handoff retirement.

### Leave to iPad1Player
- [x] Do not decode/play video or audio inside PDFReader.
- [ ] A PDF link that resolves to an already-local media file may later hand off to `ipad1player://open?path=...`; no media engine belongs here.

## Explicitly out of scope on-device
- [x] No OCR engine.
- [x] No AI/ML inference.
- [x] No whole-document high-resolution bitmap cache.
- [x] No persistent full-document PDF text index.
- [x] No large background indexing service.
- [x] No modern cloud-provider SDKs.
- [x] No SMB/SFTP library merely for competitor parity.
- [x] No heavy replacement PDF engine without measured physical-device proof.
- [x] No general file manager.
- [x] No download manager.
- [x] No media player.

## Definition of done
A feature is complete only when:
- it builds with `armv7 / iOS 5.1` legacy target;
- it runs on physical iPad 1;
- memory use is bounded;
- relevant `TESTING.md` checks pass;
- docs are updated.
