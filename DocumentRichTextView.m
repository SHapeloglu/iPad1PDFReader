#import "DocumentRichTextView.h"

@interface MarkdownRichTextView (IP1DocumentPrivate)
- (void)rebuildFramesetter;
- (void)applyFontNamed:(CFStringRef)name size:(CGFloat)size to:(CFMutableAttributedStringRef)attr range:(CFRange)range;
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

- (void)rebuildFramesetter {
    if(_framesetter) { CFRelease(_framesetter); _framesetter=NULL; }
    if(!_plainText) { [self setNeedsDisplay]; return; }

    CFMutableAttributedStringRef attr=CFAttributedStringCreateMutable(kCFAllocatorDefault,0);
    CFAttributedStringReplaceString(attr,CFRangeMake(0,0),(CFStringRef)_plainText);
    CFRange all=CFRangeMake(0,[_plainText length]);
    [self applyFontNamed:CFSTR("Helvetica") size:_baseFontSize to:attr range:all];

    /* DOCX belgelerinde paragrafları Markdown'dan biraz daha ferah göster. */
    CGFloat lineSpacing=3.0f;
    CGFloat paragraphSpacing=7.0f;
    CTParagraphStyleSetting settings[2]={
        { kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpacing },
        { kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paragraphSpacing }
    };
    CTParagraphStyleRef paragraph=CTParagraphStyleCreate(settings,2);
    if(paragraph) {
        CFAttributedStringSetAttribute(attr,all,kCTParagraphStyleAttributeName,paragraph);
        CFRelease(paragraph);
    }

    for(NSDictionary *style in _styles) {
        NSUInteger location=[[style objectForKey:@"location"] unsignedIntegerValue];
        NSUInteger length=[[style objectForKey:@"length"] unsignedIntegerValue];
        if(location>[_plainText length] || length>[_plainText length]-location) continue;
        CFRange r=CFRangeMake(location,length);
        NSString *type=[style objectForKey:@"type"];
        if([type isEqualToString:@"bold"]) {
            [self applyFontNamed:CFSTR("Helvetica-Bold") size:_baseFontSize to:attr range:r];
        } else if([type isEqualToString:@"italic"]) {
            [self applyFontNamed:CFSTR("Helvetica-Oblique") size:_baseFontSize to:attr range:r];
        } else if([type isEqualToString:@"heading"]) {
            NSUInteger level=[[style objectForKey:@"level"] unsignedIntegerValue];
            CGFloat extra=(level<=1)?8.0f:(level==2)?6.0f:(level==3)?4.0f:2.0f;
            [self applyFontNamed:CFSTR("Helvetica-Bold") size:MIN(32.0f,_baseFontSize+extra) to:attr range:r];
        }
    }

    _framesetter=CTFramesetterCreateWithAttributedString(attr);
    CFRelease(attr);
    [self setNeedsDisplay];
}

@end
