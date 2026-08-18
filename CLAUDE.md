# CLAUDE.md

This repository targets legacy hardware. Read `AGENTS.md` and `SESSION.md` before making changes.

## Core rule
**Never trade iPad 1 stability for feature count.**

Target is permanently:
- iPad 1
- iOS 5.1.1
- 256 MB RAM
- armv7
- non-ARC

## Coding style
- Objective-C compatible with legacy SDK/toolchain.
- Manual memory management.
- Prefer Foundation/UIKit/CoreGraphics APIs present on iOS 5.
- Avoid blocks/concurrency patterns that create uncontrolled simultaneous work.
- Favor simple controllers and explicit ownership.
- Keep temporary images/text short-lived.

## Performance
If a feature requires loading an entire large PDF, an entire book's text, or multiple full page bitmaps at once, redesign it before implementation.

## New chat continuation
Start from `SESSION.md -> Immediate next action`.
