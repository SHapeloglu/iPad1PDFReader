#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface MarkdownRichTextView : UIView {
    NSString *_source;
    NSString *_plainText;
    NSArray *_styles;
    CGFloat _baseFontSize;
    CTFramesetterRef _framesetter;
}
@property(nonatomic,readonly) NSString *plainText;
@property(nonatomic,assign) CGFloat baseFontSize;
- (void)setMarkdownSource:(NSString *)source;
- (void)setPlainText:(NSString *)text styles:(NSArray *)styles;
- (CGFloat)contentHeightForWidth:(CGFloat)width;
- (CGFloat)yOffsetForCharacterIndex:(NSUInteger)index;
@end
