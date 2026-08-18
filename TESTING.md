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

Do not accept simulator `.tbd` warnings from iPhoneOS9.3.sdk; that indicates the wrong SDK/toolchain path.

## Smoke test
- [ ] Application launches.
- [ ] Library screen appears.
- [ ] PDF opens.
- [ ] Previous/next navigation works.
- [ ] Zoom works.
- [ ] Last page is remembered.
- [ ] Bookmark persists after relaunch.

## Memory-focused test
### Reader
- [ ] Open a large PDF and stay in reader for 10 minutes.
- [ ] Repeatedly zoom 1x -> max -> 1x.
- [ ] Change pages rapidly.
- [ ] Rotate portrait/landscape repeatedly.
- [ ] Return to library and open a second PDF.
- [ ] No progressive slowdown or crash.

### Thumbnails
- [ ] Open a 100+ page document.
- [ ] Scroll to the bottom and back.
- [ ] Confirm images continue loading after memory pressure.
- [ ] Cache must remain bounded to 8 thumbnails by architecture.

### Search
- [ ] Search a common term in a 100+ page text PDF.
- [ ] Maximum retained results: 40.
- [ ] Search does not create a persistent full-document text index.
- [ ] Returning to reader releases search result memory when appropriate.

### Reflow
- [ ] Open Reflow on a large PDF.
- [ ] Move through 30+ pages.
- [ ] Font A-/A/A+ works.
- [ ] Only the current page text is displayed/retained.

### Memory warning
If possible, create memory pressure with other apps/processes and verify:
- [ ] thumbnail cache is cleared;
- [ ] search results can be discarded safely;
- [ ] reader stays recoverable;
- [ ] current document/page state is not lost.

## Annotation test
- [ ] Draw annotation.
- [ ] Add highlight.
- [ ] Add note marker.
- [ ] Add simple signature.
- [ ] Export annotated PDF.
- [ ] Reopen exported PDF and verify visible flattened annotations.

## Page manager test
Use disposable test PDFs.
- [ ] Reorder pages.
- [ ] Delete page.
- [ ] Rotate page.
- [ ] Export edited PDF.
- [ ] Original PDF remains intact.

## Network test
- [ ] HTTP download.
- [ ] HTTPS download compatible with iOS 5 TLS limitations/server configuration.
- [ ] FTP download.
- [ ] WebDAV PROPFIND.
- [ ] WebDAV GET.

SMB/SFTP are not considered test failures while optional connector libraries are absent.

## RAM goals
These are engineering targets, not hard guarantees:
- normal reading: roughly 30–50 MB preferred;
- thumbnail/search/reflow operations: keep as far below 70–90 MB as practical;
- any feature showing sustained unbounded memory growth fails testing.
