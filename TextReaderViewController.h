#import <UIKit/UIKit.h>

@interface TextReaderViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    NSString *_filePath;
    UITextView *_textView;
    UIScrollView *_horizontalScrollView;
    UIToolbar *_toolbar;
    NSString *_searchTerm;
    NSRange _lastMatch;
    CGFloat _fontSize;
    BOOL _wrapEnabled;
    unsigned long long _fileSize;
}

+ (BOOL)isSupportedTextPath:(NSString *)path;
+ (unsigned long long)maximumSafeFileSize;
- (id)initWithTextPath:(NSString *)path;

@end
