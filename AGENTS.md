# AGENTS.md

## Instructions for coding agents
Before editing this repository, read in this order:
1. `SESSION.md`
2. `ARCHITECTURE.md`
3. `TASKS.md`
4. `TESTING.md`
5. `INTEGRATION.md`
6. `README.md`

## Non-negotiable constraints
- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- non-ARC Objective-C
- Theos
- legacy iPhoneOS 6.1 SDK target

Never "modernize" the project by raising deployment target or adding APIs/frameworks unavailable on iOS 5.1.1.

## Change policy
Before adding a feature, classify it:
- Green = low-memory and incremental.
- Yellow = requires hard memory bounds and real-device profiling.
- Red = do not implement on-device.

Red examples include OCR, AI, whole-document image caches, and large cloud SDKs.

## Memory policy
- render only the active full PDF page;
- thumbnail cache max 8;
- search results max 40;
- search page-by-page;
- reflow page-by-page;
- clear caches on memory warning;
- avoid parallel heavy work;
- preserve manual retain/release correctness.

## Build policy
Use:
```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

Do not switch to iPhoneOS9.3.sdk; it previously caused invalid simulator `.tbd` linking and armv7 `liblaunch.dylib` failure.

## Definition of done
A feature is not done until:
- project builds with legacy target;
- it runs on physical iPad 1;
- it passes relevant `TESTING.md` checks;
- memory use is bounded;
- documentation is updated.
