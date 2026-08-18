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
Current development head: **v3.2 low-memory UX/integration pass** on top of `v3.1.0-memorysafe`.

### Reader UX already present
- zoom centering fix;
- zoom scale preserved across page changes;
- approximate normalized reading position preserved;
- double-tap zoom;
- direct page-number navigation;
- bookmark list;
- text page notes with add/view/edit/delete.

### Added in v3.2 development head
- `Belge Gezgini`: bounded document-wide bookmark/note/highlight summary;
- summary limits: max 80 annotation-summary items, max 40 per kind;
- serial page-by-page search with visible progress and Cancel;
- search remains capped at 40 results and does not build a persistent document index;
- lightweight outline destination resolution for direct `/Dest` and `/A /GoTo` array targets;
- one-shot drag rectangle highlight; scroll is disabled only during selection and restored immediately after;
- Page Manager now exports only on explicit `Kaydet` and always writes a new PDF;
- iPad1Files shared storage integration:
  - `/var/mobile/Media/iPad1Files/PDFs`
  - `/var/mobile/Media/iPad1Files/Downloads`
- registered receiver URL scheme:
  `ipad1pdf://open?path=<percent-encoded-absolute-path>`;
- shared iPad1Files PDFs open in-place without duplicate copies;
- ordinary external `Open In` file URLs are still copied into the app Documents area when needed.

## Ecosystem responsibility split
Do not duplicate companion-app responsibilities.

- **iPad1Files**: filesystem browser, copy/move/rename/delete, shared storage, Open With.
- **iPad1FTPDownloader**: FTP browse/download/upload/queue/resume.
- **iPad1PDFReader**: PDF rendering, navigation, search, reflow, bookmark, annotation, page management.

Built-in PDFReader FTP/WebDAV code is maintenance-only. Do not expand it merely for feature parity.

## Memory policy
- one active full PDF page render at a time;
- thumbnail cache max **8**;
- search result cap **40**;
- search is serial page-by-page;
- document navigator annotation-summary cap **80**, max **40 per kind**;
- Reflow remains page-scoped;
- no device-side OCR;
- no AI/ML;
- no background full-document text index;
- no high-resolution multi-page bitmap cache;
- clear disposable state on memory warning;
- no heavy SMB/SFTP/cloud SDK merely for parity.

## Known limitations
- v3.2 development head has **not yet been clean-built and physically validated after this latest batch**. Treat source as development head, not a proven release.
- Text extraction/search may remain incomplete for complex font encodings / ToUnicode maps.
- Outline improvement resolves lightweight direct array destinations; named destinations can still remain unresolved.
- Drag highlight is rectangular region highlighting, not semantic PDF text selection.
- Flattened annotations are visual output, not editable Acrobat `/Annots` objects.
- Built-in legacy HTTP/FTP/WebDAV paths remain for compatibility but companion apps are preferred for transfer/file management.

## Build environment
Use WSL Ubuntu + Theos with legacy iPhoneOS6.1 SDK.

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Do not switch to iPhoneOS9.3 SDK.

## Immediate next action
1. Download/pull the latest repository source.
2. Run:
   ```bash
   make clean
   rm -rf .theos
   make package FINALPACKAGE=1
   ```
3. Fix only real legacy compile problems; do **not** raise deployment target or relax memory constraints.
4. Install on physical iPad 1.
5. Run the new v3.2 checks in `TESTING.md`, especially:
   - Belge Gezgini;
   - search progress/cancel;
   - drag highlight;
   - outline page jump;
   - iPad1Files shared PDFs and URL handoff;
   - explicit Page Manager save;
   - repeated memory/stability tests.
6. Do not add heavier functionality until these pass real-device validation.
