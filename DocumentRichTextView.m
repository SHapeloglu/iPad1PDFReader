#import "DocumentRichTextView.h"

@interface MarkdownRichTextView (IP1DocumentPrivate)
- (void)rebuildFramesetter;
@end

@implementation DocumentRichTextView
- (void)setDocumentText:(NSString *)text styles:(NSArray *)styles {
    [_source release];
    _source=nil;
    [_plainText release];
    _plainText=[text copy];
    [_styles release];
    _styles=[styles copy];
    [self rebuildFramesetter];
}
@end
