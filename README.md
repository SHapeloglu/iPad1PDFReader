# iPad1PDFReader

A lightweight PDF/document reader built specifically for the **original iPad 1 (256 MB RAM, iOS 5.1.1, armv7)**.

The project deliberately prioritizes **stability and bounded memory usage over feature count**.

## Current development version
**v3.1.0-memorysafe**

> v3.1 is the latest source head and still needs a clean build + physical-device validation after the memory-safety refactor. See `SESSION.md`.

## Main features
- Core Graphics PDF rendering (`CGPDFDocument`)
- one active full page rendered at a time
- zoom and page navigation
- bookmarks and resume-last-page
- lazy thumbnails with bounded cache
- PDF text extraction/search via `CGPDFScanner`
- page-at-a-time Reflow mode
- outline support
- drawing / highlight / note / simple signature overlay
- flattened annotation PDF export
- page reorder/delete/rotate/export
- PDF merge API
- HTTP/HTTPS/FTP import
- WebDAV foundation
- iTunes File Sharing / Open In

## Memory-safe design
Current hard policy:
- thumbnail cache: max **8** small images;
- search results: max **40**;
- search: page-by-page;
- Reflow: one page at a time;
- no whole-document bitmap cache;
- no on-device OCR;
- no AI/ML;
- caches clear on memory warning.

## Build
Expected environment:
- Theos at `~/theos`
- legacy `iPhoneOS6.1.sdk`

```bash
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Core target:
```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Expected package name:
```text
com.olap.ipad1pdfreader_3.1.0_iphoneos-arm.deb
```

## Install on iPad 1
Example device IP used during development: `192.168.1.2`.

```bash
scp -o HostKeyAlgorithms=+ssh-rsa packages/com.olap.ipad1pdfreader_3.1.0_iphoneos-arm.deb root@192.168.1.2:/var/mobile/
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

On iPad:
```bash
dpkg -i /var/mobile/com.olap.ipad1pdfreader_3.1.0_iphoneos-arm.deb
killall SpringBoard
```

## Documentation
For continuing development, read:
- `SESSION.md` — exact handoff/current state
- `ARCHITECTURE.md` — design and memory rules
- `TASKS.md` — prioritized work
- `TESTING.md` — real-device validation
- `INTEGRATION.md` — sibling app integration
- `AGENTS.md` / `CLAUDE.md` — coding-agent constraints
- `CHANGELOG.md` — version history

## Golden rule
**If a feature risks stability on 256 MB RAM / iOS 5.1.1, it is redesigned, moved off-device, or not added.**
