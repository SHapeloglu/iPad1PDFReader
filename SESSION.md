# SESSION.md

## Project
**iPad1PDFReader** — lightweight advanced PDF reader for the original iPad 1.

Repository: `SHapeloglu/iPad1PDFReader`

## Immutable target
- Device: **iPad 1**
- RAM: **256 MB total physical RAM**
- CPU: Apple A4
- OS: **iOS 5.1.1**
- Architecture: **armv7**
- Memory management: **non-ARC / manual retain-release**
- Build system: Theos
- SDK: **iPhoneOS 6.1 legacy SDK**
- Target line: `TARGET = iphone:clang:6.1:5.1`

These constraints are architectural requirements, not optional preferences.

## Current source state
Base snapshot: **v3.1.0-memorysafe**.

Current development head adds a low-memory reader UX pass on top of v3.1:
- pinch zoom centering behavior revised so zoom should no longer visually jump/lean left;
- zoom scale is preserved across previous/next page navigation;
- approximate normalized reading position is preserved across page changes while zoomed;
- double-tap zoom added;
- direct page-number navigation added;
- bookmark list navigation added;
- page notes now contain text and support add/view/edit/delete from the Tools UI;
- temporary bookmark/note selection arrays are purged on memory warning.

These UX changes are **development head only until clean-built and tested on the physical iPad 1**.

v3.1 memory policy remains unchanged:
- one active PDF page render at a time;
- bounded thumbnail cache (`8` small thumbnails);
- search capped at `40` results and scanned page-by-page;
- Reflow is **one page at a time**;
- cache cleanup on memory warning;
- no device-side OCR;
- no high-resolution multi-page bitmap cache;
- explicit `MemoryBudget` policy class.

## Implemented feature areas
- local PDF library;
- iTunes File Sharing / Open In support;
- Core Graphics PDF rendering;
- zoom and page navigation;
- zoom persistence during page navigation (development head, pending device validation);
- direct page-number navigation;
- bookmarks, bookmark list, and resume-last-page;
- thumbnails;
- basic outline handling;
- content-stream text extraction/search via `CGPDFScanner`;
- memory-safe Reflow mode;
- annotation overlay: drawing / highlight / text note / simple signature;
- page note add/view/edit/delete;
- annotation flatten export to a new PDF;
- page manager: delete/reorder/rotate/export;
- PDF merge API;
- HTTP/HTTPS/FTP URL import;
- WebDAV client foundation;
- SMB/SFTP shown as optional connectors only; external libraries are intentionally not bundled.

## Known limitations
- Current development head has **not yet been confirmed by a clean build on the user's WSL environment** after the latest reader UX changes. Treat it as development source, not a proven release.
- Highlight placement is still basic/fixed; free selection must not be added until touch interaction with zoom/pan is proven safe.
- Bookmark menu displays a bounded set of up to 24 entries at once.
- Page note menu displays a bounded set of up to 20 notes at once.
- Text extraction/search may fail or be incomplete for PDFs using complex font encodings / ToUnicode maps.
- Outline destination-to-page resolution is partial.
- Flattened annotations are visually permanent but are not editable Acrobat `/Annots` objects.
- SMB needs a lightweight `libsmb2` build; SFTP needs `libssh2`. Do not add them until RAM footprint is measured.
- OCR must remain off-device (PC/VPS creates searchable PDFs).

## Previously proven build environment
User environment:
- WSL Ubuntu
- Theos: `~/theos`
- Legacy SDK symlink:
  `~/theos/sdks/iPhoneOS6.1.sdk -> ~/legacy-ios-sdks/iPhoneOS6.1-extracted/iPhoneOS6.1.sdk`

A previous v1 build succeeded using:
```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Modern iPhoneOS9.3 SDK must not be used for this project because it previously caused simulator `.tbd` link warnings and `liblaunch.dylib` armv7 link failure.

## Device deployment
Known iPad SSH address used during development: `192.168.1.2` (may change with network).

Modern OpenSSH requires legacy RSA host-key opt-in:
```bash
scp -o HostKeyAlgorithms=+ssh-rsa <package.deb> root@192.168.1.2:/var/mobile/
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

Then on the iPad:
```bash
dpkg -i /var/mobile/<package.deb>
killall SpringBoard
```

## Immediate next action
1. Pull the latest repository on WSL.
2. Run:
   ```bash
   make clean
   rm -rf .theos
   make package FINALPACKAGE=1
   ```
3. Fix only actual iOS 5.1.1 / legacy SDK compile issues without relaxing `armv7`, iOS 5.1.1, non-ARC, Core Graphics, or memory-budget constraints.
4. Install the resulting package on the physical iPad 1.
5. First validate zoom centering, zoom persistence, double-tap zoom, page-number navigation, bookmarks, and page-note add/view/edit/delete.
6. Then run the complete memory/stability checklist in `TESTING.md`.
7. Do not add heavier features until this development head passes real-device testing.
