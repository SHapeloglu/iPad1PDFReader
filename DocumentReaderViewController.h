#import <UIKit/UIKit.h>
@class DocumentRichTextView;

@interface DocumentReaderViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    NSString *_filePath;
    DocumentRichTextView *_richView;
    UIScrollView *_scrollView;
    UIToolbar *_toolbar;
    NSString *_searchTerm;
    NSRange _lastMatch;
    CGFloat _fontSize;
    unsigned long long _fileSize;
}
- (id)initWithDocumentPath:(NSString *)path;
@end
