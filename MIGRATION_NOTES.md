# Cross-App Migration Notes

Do not remove legacy PDFReader network classes until replacement companion-app handoff is physically proven on iPad 1.

Migration order:
1. Finish iPad1Files picker callback.
2. Add PDFReader launcher for iPad1Files.
3. Add transfer-specialist launcher.
4. Device-test PDF/text handoff and transfer return path.
5. Remove network UI references.
6. Remove unreferenced legacy network source files from Makefile.
7. Regression-test PDF core features.
