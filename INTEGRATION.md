# INTEGRATION.md

## Related legacy iPad applications
This project is intended to coexist with the user's other iPad 1 tools:
- `SHapeloglu/iPad1Files`
- `SHapeloglu/iPad1FTPDownloader`
- `SHapeloglu/ipad1vnc`

Do not duplicate functionality if a lightweight handoff between apps is cheaper in RAM and code size.

## File handoff
Preferred mechanisms:
1. shared user-visible Documents/File Sharing workflow;
2. iOS `Open In...` / document handoff;
3. URL scheme only if necessary and kept simple.

Future goal: PDFs downloaded by `iPad1FTPDownloader` or browsed in `iPad1Files` should be openable directly in `iPad1PDFReader`.

## Networking strategy
`iPad1PDFReader` already has lightweight HTTP/FTP/WebDAV foundations.

For SMB/SFTP:
- first consider whether `iPad1Files` / `iPad1FTPDownloader` can perform transfer and hand the file to PDF Reader;
- only embed `libsmb2` or `libssh2` if integration is insufficient;
- measure binary size and RAM before merging.

## OCR integration
OCR must be external:
- PC/VPS performs OCR;
- searchable PDF is transferred to the iPad;
- iPad reader only renders/searches the prepared PDF.

## Repository compatibility contract
Any integration change must preserve:
- iOS 5.1.1;
- armv7;
- non-ARC;
- Theos build;
- low-memory behavior;
- no required modern Apple frameworks unavailable on iOS 5.
