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
- SDK used successfully by sibling legacy projects: **iPhoneOS 6.1 legacy SDK**
- Target line: `TARGET = iphone:clang:6.1:5.1`

These constraints are architectural requirements, not optional preferences.

## Current source state
Latest source snapshot: **v3.1.0-memorysafe**.

v3.1 is a memory-safety pass over v3.0. Main changes:
- one active PDF page render at a time;
- bounded thumbnail cache (`8` small thumbnails);
- search capped at `40` results and scanned page-by-page;
- Reflow changed from whole-document text aggregation to **one page at a time**;
- cache cleanup on memory warning;
- no device-side OCR;
- no high-resolution multi-page bitmap cache;
- explicit `MemoryBudget` policy class.

## Implemented feature areas
- local PDF library;
- iTunes File Sharing / Open In support;
- Core Graphics PDF rendering;
- zoom and page navigation;
- bookmarks and resume-last-page;
- thumbnails;
- basic outline handling;
- content-stream text extraction/search via `CGPDFScanner`;
- memory-safe Reflow mode;
- annotation overlay: drawing / highlight / note / simple signature;
- annotation flatten export to a new PDF;
- page manager: delete/reorder/rotate/export;
- PDF merge API;
- HTTP/HTTPS/FTP URL import;
- WebDAV client foundation;
- SMB/SFTP shown as optional connectors only; external libraries are intentionally not bundled.

## Known limitations
- v3.1.0 has **not yet been confirmed by a clean build on the user's WSL environment** after the memory-safe refactor. Treat the source as latest development head, not a proven release.
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
1. Clone/pull this repository on WSL.
2. Run:
   ```bash
   make clean
   rm -rf .theos
   make package FINALPACKAGE=1
   ```
3. Fix only actual iOS 5.1.1 / legacy SDK compile issues without relaxing the target constraints.
4. Install the resulting package on the iPad 1.
5. Run the memory/stability checklist in `TESTING.md` before adding any new feature.
6. Only after v3.1 passes real-device testing should new functionality be considered.
