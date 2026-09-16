#import <UIKit/UIKit.h>
@class MarkdownRichTextView;

@interface MarkdownReaderViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    NSString *_filePath;
    NSString *_sourceText;
    UIScrollView *_scrollView;
    MarkdownRichTextView *_richView;
    UIToolbar *_toolbar;
    NSString *_searchTerm;
    NSRange _lastMatch;
    CGFloat _fontSize;
    unsigned long long _fileSize;
}
- (id)initWithMarkdownPath:(NSString *)path;
@end
