#import <UIKit/UIKit.h>

@interface TextReaderViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    NSString *_filePath;
    NSString *_sourceText;
    UITextView *_textView;
    UIScrollView *_horizontalScrollView;
    UIToolbar *_toolbar;
    UIBarButtonItem *_markdownButton;
    NSString *_searchTerm;
    NSRange _lastMatch;
    CGFloat _fontSize;
    BOOL _wrapEnabled;
    BOOL _isMarkdown;
    BOOL _markdownReadingMode;
    unsigned long long _fileSize;
}

+ (BOOL)isSupportedTextPath:(NSString *)path;
+ (unsigned long long)maximumSafeFileSize;
- (id)initWithTextPath:(NSString *)path;

@end
