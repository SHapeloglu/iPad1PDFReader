#import "MarkdownRichTextView.h"

static const NSUInteger IPAD1_MD_MAX_STYLE_RANGES = 2048;
static const CGFloat IPAD1_MD_MARGIN = 14.0f;

static void IP1AddStyle(NSMutableArray *styles, NSString *type, NSUInteger location, NSUInteger length, NSUInteger level) {
    if(!type || length==0 || [styles count]>=IPAD1_MD_MAX_STYLE_RANGES) return;
    [styles addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       type,@"type",
                       [NSNumber numberWithUnsignedInteger:location],@"location",
                       [NSNumber numberWithUnsignedInteger:length],@"length",
                       [NSNumber numberWithUnsignedInteger:level],@"level",nil]];
}

@implementation MarkdownRichTextView
@synthesize plainText=_plainText;

- (id)initWithFrame:(CGRect)frame {
    if((self=[super initWithFrame:frame])) {
        self.backgroundColor=[UIColor whiteColor];
        self.opaque=YES;
        _baseFontSize=16.0f;
    }
    return self;
}

- (CGFloat)baseFontSize { return _baseFontSize; }

- (void)setBaseFontSize:(CGFloat)size {
    if(size<10.0f) size=10.0f;
    if(size>28.0f) size=28.0f;
    if(fabs(_baseFontSize-size)<0.01f) return;
    _baseFontSize=size;
    [self rebuildFramesetter];
}

- (BOOL)isRuleLine:(NSString *)trimmed {
    if([trimmed length]<3) return NO;
    unichar first=[trimmed characterAtIndex:0];
    if(first!='-' && first!='*' && first!='_') return NO;
    for(NSUInteger i=1;i<[trimmed length];i++) {
        unichar c=[trimmed characterAtIndex:i];
        if(c!=first && c!=' ' && c!='\t') return NO;
    }
    return YES;
}

- (void)appendInline:(NSString *)line to:(NSMutableString *)out styles:(NSMutableArray *)styles {
    if(!line) return;
    NSUInteger i=0;
    NSUInteger length=[line length];
    while(i<length) {
        if(i+1<length && [line characterAtIndex:i]=='!' && [line characterAtIndex:i+1]=='[') {
            NSRange close=[line rangeOfString:@"]" options:0 range:NSMakeRange(i+2,length-i-2)];
            if(close.location!=NSNotFound) {
                NSString *alt=[line substringWithRange:NSMakeRange(i+2,close.location-i-2)];
                [out appendString:@"[Görsel"];
                if([alt length]) [out appendFormat:@": %@",alt];
                [out appendString:@"]"];
                NSUInteger next=NSMaxRange(close);
                if(next<length && [line characterAtIndex:next]=='(') {
                    NSRange end=[line rangeOfString:@")" options:0 range:NSMakeRange(next+1,length-next-1)];
                    if(end.location!=NSNotFound) next=NSMaxRange(end);
                }
                i=next;
                continue;
            }
        }

        if([line characterAtIndex:i]=='[') {
            NSRange close=[line rangeOfString:@"]" options:0 range:NSMakeRange(i+1,length-i-1)];
            if(close.location!=NSNotFound && NSMaxRange(close)<length && [line characterAtIndex:NSMaxRange(close)]=='(') {
                NSUInteger urlStart=NSMaxRange(close)+1;
                NSRange end=[line rangeOfString:@")" options:0 range:NSMakeRange(urlStart,length-urlStart)];
                if(end.location!=NSNotFound) {
                    NSString *label=[line substringWithRange:NSMakeRange(i+1,close.location-i-1)];
                    NSString *url=[line substringWithRange:NSMakeRange(urlStart,end.location-urlStart)];
                    NSUInteger start=[out length];
                    [out appendString:label];
                    if([url length]) [out appendFormat:@"  <%@>",url];
                    IP1AddStyle(styles,@"link",start,[out length]-start,0);
                    i=NSMaxRange(end);
                    continue;
                }
            }
        }

        if(i+1<length && (([line characterAtIndex:i]=='*' && [line characterAtIndex:i+1]=='*') ||
                          ([line characterAtIndex:i]=='_' && [line characterAtIndex:i+1]=='_'))) {
            unichar marker=[line characterAtIndex:i];
            NSString *token=[NSString stringWithFormat:@"%C%C",marker,marker];
            NSRange end=[line rangeOfString:token options:0 range:NSMakeRange(i+2,length-i-2)];
            if(end.location!=NSNotFound) {
                NSString *body=[line substringWithRange:NSMakeRange(i+2,end.location-i-2)];
                NSUInteger start=[out length];
                [out appendString:body];
                IP1AddStyle(styles,@"bold",start,[body length],0);
                i=NSMaxRange(end);
                continue;
            }
        }

        unichar c=[line characterAtIndex:i];
        if(c=='*' || c=='_') {
            NSString *token=[NSString stringWithFormat:@"%C",c];
            NSRange end=[line rangeOfString:token options:0 range:NSMakeRange(i+1,length-i-1)];
            if(end.location!=NSNotFound && end.location>i+1) {
                NSString *body=[line substringWithRange:NSMakeRange(i+1,end.location-i-1)];
                NSUInteger start=[out length];
                [out appendString:body];
                IP1AddStyle(styles,@"italic",start,[body length],0);
                i=NSMaxRange(end);
                continue;
            }
        }

        if(c=='`') {
            NSRange end=[line rangeOfString:@"`" options:0 range:NSMakeRange(i+1,length-i-1)];
            if(end.location!=NSNotFound) {
                NSString *body=[line substringWithRange:NSMakeRange(i+1,end.location-i-1)];
                NSUInteger start=[out length];
                [out appendString:body];
                IP1AddStyle(styles,@"code",start,[body length],0);
                i=NSMaxRange(end);
                continue;
            }
        }

        if(c=='\\' && i+1<length) {
            [out appendFormat:@"%C",[line characterAtIndex:i+1]];
            i+=2;
            continue;
        }

        [out appendFormat:@"%C",c];
        i++;
    }
}

- (void)parseSource {
    NSMutableString *out=[NSMutableString stringWithCapacity:MIN((NSUInteger)262144,[_source length])];
    NSMutableArray *styles=[NSMutableArray array];
    NSArray *lines=[_source componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    BOOL inCode=NO;

    for(NSUInteger n=0;n<[lines count];n++) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        NSString *line=[lines objectAtIndex:n];
        NSString *trim=[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if([trim hasPrefix:@"```"] || [trim hasPrefix:@"~~~"]) {
            inCode=!inCode;
            if(inCode) {
                NSUInteger start=[out length];
                [out appendString:@"Kod\n"];
                IP1AddStyle(styles,@"code",start,3,0);
            } else {
                [out appendString:@"\n"];
            }
            [pool drain];
            continue;
        }

        if(inCode) {
            NSUInteger start=[out length];
            [out appendFormat:@"    %@",line];
            IP1AddStyle(styles,@"code",start,[out length]-start,0);
            if(n+1<[lines count]) [out appendString:@"\n"];
            [pool drain];
            continue;
        }

        if([self isRuleLine:trim]) {
            NSUInteger start=[out length];
            [out appendString:@"────────────────────────"];
            IP1AddStyle(styles,@"rule",start,[out length]-start,0);
            if(n+1<[lines count]) [out appendString:@"\n"];
            [pool drain];
            continue;
        }

        NSUInteger hashCount=0;
        while(hashCount<[line length] && [line characterAtIndex:hashCount]=='#') hashCount++;
        if(hashCount>0 && hashCount<=6 && hashCount<[line length] && [line characterAtIndex:hashCount]==' ') {
            NSUInteger start=[out length];
            [self appendInline:[line substringFromIndex:hashCount+1] to:out styles:styles];
            IP1AddStyle(styles,@"heading",start,[out length]-start,hashCount);
            [out appendString:@"\n"];
            if(n+1<[lines count]) [out appendString:@"\n"];
            [pool drain];
            continue;
        }

        NSString *left=[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([left hasPrefix:@"> "] || [left isEqualToString:@">"]) {
            NSUInteger start=[out length];
            [out appendString:@"│ "];
            NSString *body=[left length]>1?[[left substringFromIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]:@"";
            [self appendInline:body to:out styles:styles];
            IP1AddStyle(styles,@"quote",start,[out length]-start,0);
            if(n+1<[lines count]) [out appendString:@"\n"];
            [pool drain];
            continue;
        }

        if([left hasPrefix:@"- "] || [left hasPrefix:@"* "] || [left hasPrefix:@"+ "]) {
            [out appendString:@"• "];
            [self appendInline:[left substringFromIndex:2] to:out styles:styles];
            if(n+1<[lines count]) [out appendString:@"\n"];
            [pool drain];
            continue;
        }

        NSUInteger digitCount=0;
        while(digitCount<[left length] && [left characterAtIndex:digitCount]>='0' && [left characterAtIndex:digitCount]<='9') digitCount++;
        if(digitCount>0 && digitCount+1<[left length] && [left characterAtIndex:digitCount]=='.' && [left characterAtIndex:digitCount+1]==' ') {
            [out appendString:[left substringToIndex:digitCount+2]];
            [self appendInline:[left substringFromIndex:digitCount+2] to:out styles:styles];
            if(n+1<[lines count]) [out appendString:@"\n"];
            [pool drain];
            continue;
        }

        [self appendInline:line to:out styles:styles];
        if(n+1<[lines count]) [out appendString:@"\n"];
        [pool drain];
    }

    [_plainText release];
    _plainText=[out copy];
    [_styles release];
    _styles=[styles copy];
}

- (void)applyFontNamed:(CFStringRef)name size:(CGFloat)size to:(CFMutableAttributedStringRef)attr range:(CFRange)range {
    if(range.length<=0) return;
    CTFontRef font=CTFontCreateWithName(name,size,NULL);
    if(font) {
        CFAttributedStringSetAttribute(attr,range,kCTFontAttributeName,font);
        CFRelease(font);
    }
}

- (void)rebuildFramesetter {
    if(_framesetter) { CFRelease(_framesetter); _framesetter=NULL; }
    if(!_plainText) { [self setNeedsDisplay]; return; }

    CFMutableAttributedStringRef attr=CFAttributedStringCreateMutable(kCFAllocatorDefault,0);
    CFAttributedStringReplaceString(attr,CFRangeMake(0,0),(CFStringRef)_plainText);
    CFRange all=CFRangeMake(0,[_plainText length]);
    [self applyFontNamed:CFSTR("Helvetica") size:_baseFontSize to:attr range:all];

    CGFloat lineSpacing=3.0f;
    CGFloat paragraphSpacing=4.0f;
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
        } else if([type isEqualToString:@"code"]) {
            [self applyFontNamed:CFSTR("Courier") size:MAX(10.0f,_baseFontSize-1.0f) to:attr range:r];
        } else if([type isEqualToString:@"heading"]) {
            NSUInteger level=[[style objectForKey:@"level"] unsignedIntegerValue];
            CGFloat extra=(level==1)?10.0f:(level==2)?7.0f:(level==3)?4.0f:2.0f;
            [self applyFontNamed:CFSTR("Helvetica-Bold") size:MIN(34.0f,_baseFontSize+extra) to:attr range:r];
        } else if([type isEqualToString:@"link"]) {
            CGColorRef blue=[[UIColor colorWithRed:0.10f green:0.28f blue:0.60f alpha:1.0f] CGColor];
            CFAttributedStringSetAttribute(attr,r,kCTForegroundColorAttributeName,blue);
        } else if([type isEqualToString:@"quote"]) {
            CGColorRef gray=[[UIColor darkGrayColor] CGColor];
            CFAttributedStringSetAttribute(attr,r,kCTForegroundColorAttributeName,gray);
        } else if([type isEqualToString:@"rule"]) {
            CGColorRef gray=[[UIColor grayColor] CGColor];
            CFAttributedStringSetAttribute(attr,r,kCTForegroundColorAttributeName,gray);
        }
    }

    _framesetter=CTFramesetterCreateWithAttributedString(attr);
    CFRelease(attr);
    [self setNeedsDisplay];
}

- (void)setMarkdownSource:(NSString *)source {
    if(_source==source || [_source isEqualToString:source]) return;
    [_source release];
    _source=[source copy];
    [self parseSource];
    [self rebuildFramesetter];
}

- (CGFloat)contentHeightForWidth:(CGFloat)width {
    if(!_framesetter) return 1.0f;
    CGFloat textWidth=MAX(1.0f,width-(IPAD1_MD_MARGIN*2.0f));
    CGSize suggested=CTFramesetterSuggestFrameSizeWithConstraints(_framesetter,CFRangeMake(0,0),NULL,CGSizeMake(textWidth,CGFLOAT_MAX),NULL);
    return ceil(suggested.height)+(IPAD1_MD_MARGIN*2.0f)+8.0f;
}

- (CTFrameRef)newFrameForCurrentBounds {
    if(!_framesetter) return NULL;
    CGRect rect=CGRectInset(self.bounds,IPAD1_MD_MARGIN,IPAD1_MD_MARGIN);
    if(rect.size.width<1.0f || rect.size.height<1.0f) return NULL;
    CGPathRef path=CGPathCreateWithRect(rect,NULL);
    CTFrameRef frame=CTFramesetterCreateFrame(_framesetter,CFRangeMake(0,0),path,NULL);
    CGPathRelease(path);
    return frame;
}

- (CGFloat)yOffsetForCharacterIndex:(NSUInteger)index {
    CTFrameRef frame=[self newFrameForCurrentBounds];
    if(!frame) return 0.0f;
    CFArrayRef lines=CTFrameGetLines(frame);
    CFIndex count=CFArrayGetCount(lines);
    CGPoint *origins=NULL;
    if(count>0) origins=(CGPoint *)calloc((size_t)count,sizeof(CGPoint));
    if(origins) CTFrameGetLineOrigins(frame,CFRangeMake(0,count),origins);
    CGFloat y=0.0f;
    for(CFIndex i=0;i<count;i++) {
        CTLineRef line=(CTLineRef)CFArrayGetValueAtIndex(lines,i);
        CFRange r=CTLineGetStringRange(line);
        if(index>=(NSUInteger)r.location && index<=(NSUInteger)(r.location+r.length)) {
            y=MAX(0.0f,self.bounds.size.height-origins[i].y-(_baseFontSize*2.0f));
            break;
        }
    }
    if(origins) free(origins);
    CFRelease(frame);
    return y;
}

- (void)drawRect:(CGRect)rect {
    (void)rect;
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    if(!ctx || !_framesetter) return;
    CGContextSaveGState(ctx);
    CGContextSetTextMatrix(ctx,CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx,0,self.bounds.size.height);
    CGContextScaleCTM(ctx,1.0f,-1.0f);
    CTFrameRef frame=[self newFrameForCurrentBounds];
    if(frame) {
        CTFrameDraw(frame,ctx);
        CFRelease(frame);
    }
    CGContextRestoreGState(ctx);
}

- (void)dealloc {
    if(_framesetter) CFRelease(_framesetter);
    [_source release];
    [_plainText release];
    [_styles release];
    [super dealloc];
}
@end
