# TASKS.md

## Priority 0 — current physical validation
Current branch: `feature/text-reader-v1`.

Current source already contains PDF/Text Reader work that still needs physical iPad 1 validation before being called complete.

Validate:
- [ ] Fit Page;
- [ ] Fit Width;
- [ ] `Konum Geri / Konum İleri` no-history alerts;
- [ ] edge-tap navigation and gesture conflicts;
- [ ] `Gezinti Merkezi` sections;
- [ ] direct Highlight tap -> recolor/delete;
- [ ] direct Note tap -> view/edit/delete;
- [ ] Underline create/redraw/recolor/delete;
- [ ] Strikeout create/redraw/recolor/delete;
- [ ] Underline / Strikeout persistence after page change/reopen;
- [ ] flattened export of Highlight / Underline / Strikeout;
- [ ] scanned/image PDF safely rejects Underline / Strikeout without OCR;
- [ ] remaining Text Reader tests from `TESTING.md`;
- [ ] iPad1Files picker callback validation.

## Priority 1 — Markdown Reader v2
Goal: keep `.md` readable on iPad 1 even when formatting cannot be rendered.

Base behavior:
- [x] `.md` currently opens as UTF-8 plain text in `TextReaderViewController`;
- [x] read-only;
- [x] A-/A+;
- [x] Word Wrap;
- [x] Find / Next / Previous;
- [x] 2 MiB hard source-file limit.

Planned formatted reading mode:
- [ ] add optional `Markdown Görünümü` toggle;
- [ ] headings `#`..`######`;
- [ ] bold;
- [ ] italic;
- [ ] bullet lists;
- [ ] numbered lists;
- [ ] blockquote;
- [ ] inline code;
- [ ] fenced code blocks;
- [ ] horizontal rule;
- [ ] basic links as readable text/URL;
- [ ] retain plain-text fallback;
- [ ] no JavaScript;
- [ ] no remote asset loading;
- [ ] no full CommonMark/GFM requirement;
- [ ] no background/document-wide index;
- [ ] physical test with small/medium Markdown files;
- [ ] verify memory remains bounded after repeated mode switching.

Deferred until profiling:
- [ ] Markdown tables;
- [ ] embedded HTML;
- [ ] local/remote image rendering.

## Priority 2 — DOCX Reader v1
Goal: readable Word document content, not desktop Word fidelity.

Architecture:
- [ ] add separate `DocumentReaderViewController`;
- [ ] add DOCX-specific read-only package/XML parser (`DOCXReader` or equivalent);
- [ ] keep `.docx` routing under existing `ipad1pdf://open?path=...` receiver;
- [ ] open shared iPad1Files `.docx` in-place with no duplicate copy;
- [ ] add `.docx` to iPad1Files normal extension routing toward iPad1PDFReader when that app-side registry work is available.

V1 content support:
- [ ] extract `word/document.xml`;
- [ ] paragraphs;
- [ ] line breaks;
- [ ] basic bold/italic runs;
- [ ] headings where safely derivable;
- [ ] simple bullets/numbering;
- [ ] simple tables as lightweight rows/text;
- [ ] Find / Next / Previous;
- [ ] A- / A+;
- [ ] file name/path/size Info;
- [ ] read-only only;
- [ ] graceful error for malformed/unsupported packages.

DOCX safety limits to implement and profile:
- [ ] target compressed DOCX max **8 MiB** initially;
- [ ] target primary XML/text working set max **4 MiB** initially;
- [ ] parse only required DOCX parts;
- [ ] do not persistently extract whole package;
- [ ] one embedded image decoded at a time if images are later enabled;
- [ ] oversized embedded media is skipped/rejected safely;
- [ ] clear disposable XML/image state on memory warning;
- [ ] no macros;
- [ ] no remote relationships/network fetch;
- [ ] no Office SDK;
- [ ] no LibreOffice engine;
- [ ] no full desktop pagination/layout engine;
- [ ] no OCR/AI/ML.

Embedded images:
- [ ] deferred until text-first DOCX reading passes physical device testing;
- [ ] if enabled later, impose strict pixel/dimension/downscale limits.

## Priority 3 — legacy `.doc` feasibility
Classic binary `.doc` is not the same format as `.docx`.

- [ ] research/implement only a compact text-extraction feasibility spike;
- [ ] measure dependency size and RAM on physical iPad 1;
- [ ] reject any approach requiring a heavy office suite/engine;
- [ ] if safe extraction is not practical, keep `.doc` unsupported rather than compromising stability.

Do not claim `.doc` support until it builds, runs and is physically validated.

## Priority 4 — next PDF-only improvements after current build is stable
- [ ] Named PDF bookmarks with short optional title, bounded/backward-compatible persistence;
- [ ] Simple line / rectangle / ellipse shapes only if physical gesture testing remains clean;
- [ ] Selected-text Copy only if it safely reuses page-local selection state.

## Priority 5 — memory/stability validation
- [ ] 100+ page thumbnail scrolling; cache remains max 8;
- [ ] PDF search results remain max 40;
- [ ] repeated PDF search/cancel shows no progressive growth;
- [ ] Reflow remains page-local;
- [ ] Gezinti Merkezi annotation summary remains bounded to 80 items, max 40 per kind;
- [ ] outline parsing remains bounded to 80 entries;
- [ ] open/close several large PDFs sequentially;
- [ ] rotate/zoom/page-change stress test;
- [ ] repeated open/close text and Markdown files under 2 MiB;
- [ ] repeated Markdown mode toggle when implemented;
- [ ] repeated DOCX open/close when implemented;
- [ ] DOCX malformed package failure path;
- [ ] DOCX large-file rejection before expensive parse;
- [ ] memory warning clears disposable DOCX parser/image state.

## Companion-app boundary — mandatory ownership gate
### Leave to iPad1Files
- [x] general copy/move/rename/delete browser features;
- [x] file favorites/file organization/Open With registry;
- [x] normal suite file-type routing;
- [x] general ZIP browsing/extracting/creating;
- [ ] picker receiver for `ipad1files://pick?callback=ipad1pdf`;
- [ ] eventually route `.docx` to iPad1PDFReader after DOCX reader is physically proven.

Important distinction: DOCX is ZIP-based, but read-only decompression used internally and only to parse a DOCX package is allowed in iPad1PDFReader. It must not become a general archive feature.

### Leave to iPad1FTPDownloader / iPad1Downloader
- [x] HTTP/HTTPS/FTP/WebDAV browse/download/upload/queue/resume;
- [x] do not expand legacy PDFReader transfer code.

### Leave to iPad1Player
- [x] video/audio/subtitle playback;
- [ ] local media handoff only when a PDF-specific interaction resolves to a media file.

## Explicitly out of scope on-device
- [x] OCR engine;
- [x] AI/ML inference;
- [x] whole-document high-resolution bitmap cache;
- [x] persistent full-document PDF text index;
- [x] large background indexing service;
- [x] modern cloud SDKs;
- [x] heavy replacement PDF engine;
- [x] embedded Microsoft Office/LibreOffice engine;
- [x] full Word-compatible editing/save;
- [x] full desktop Word pagination fidelity;
- [x] general file manager;
- [x] download manager;
- [x] media player.

## Definition of done
A feature is complete only when:
- it builds with `armv7 / iOS 5.1` legacy target;
- it runs on physical iPad 1;
- memory use is bounded;
- relevant `TESTING.md` checks pass;
- docs are updated;
- no feature owned by another suite app has been duplicated as a general-purpose subsystem.
