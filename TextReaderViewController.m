#import "TextReaderViewController.h"

static const unsigned long long IPAD1_TEXT_MAX_BYTES = 2ULL * 1024ULL * 1024ULL;
static const CGFloat IPAD1_TEXT_MIN_FONT = 10.0f;
static const CGFloat IPAD1_TEXT_MAX_FONT = 28.0f;
static const CGFloat IPAD1_TEXT_DEFAULT_FONT = 16.0f;
static const CGFloat IPAD1_TEXT_MAX_NOWRAP_WIDTH = 8192.0f;

@implementation TextReaderViewController

+ (NSArray *)supportedExtensions {
    static NSArray *extensions=nil;
    if(!extensions) {
        extensions=[[NSArray alloc] initWithObjects:@"txt",@"md",@"log",@"csv",@"json",@"xml",@"sql",@"py",@"sh",@"ini",@"conf",nil];
    }
    return extensions;
}

+ (BOOL)isSupportedTextPath:(NSString *)path {
    if(!path) return NO;
    NSString *ext=[[path pathExtension] lowercaseString];
    return [[self supportedExtensions] containsObject:ext];
}

+ (unsigned long long)maximumSafeFileSize { return IPAD1_TEXT_MAX_BYTES; }

- (id)initWithTextPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _filePath=[path copy];
        _fontSize=IPAD1_TEXT_DEFAULT_FONT;
        _wrapEnabled=YES;
        _isMarkdown=[[[path pathExtension] lowercaseString] isEqualToString:@"md"];
        _markdownReadingMode=_isMarkdown;
        _lastMatch=NSMakeRange(NSNotFound,0);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=[_filePath lastPathComponent];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Ara" style:UIBarButtonItemStylePlain target:self action:@selector(showSearchActions)] autorelease];

    _horizontalScrollView=[[UIScrollView alloc] initWithFrame:CGRectZero];
    _horizontalScrollView.backgroundColor=[UIColor whiteColor];
    _horizontalScrollView.alwaysBounceHorizontal=NO;
    _horizontalScrollView.alwaysBounceVertical=NO;
    _horizontalScrollView.directionalLockEnabled=YES;
    [self.view addSubview:_horizontalScrollView];

    _textView=[[UITextView alloc] initWithFrame:CGRectZero];
    _textView.editable=NO;
    _textView.backgroundColor=[UIColor whiteColor];
    _textView.font=[UIFont systemFontOfSize:_fontSize];
    _textView.autocorrectionType=UITextAutocorrectionTypeNo;
    _textView.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [_horizontalScrollView addSubview:_textView];

    _toolbar=[[UIToolbar alloc] initWithFrame:CGRectZero];
    UIBarButtonItem *minus=[[[UIBarButtonItem alloc] initWithTitle:@"A-" style:UIBarButtonItemStylePlain target:self action:@selector(decreaseFont)] autorelease];
    UIBarButtonItem *plus=[[[UIBarButtonItem alloc] initWithTitle:@"A+" style:UIBarButtonItemStylePlain target:self action:@selector(increaseFont)] autorelease];
    UIBarButtonItem *wrap=[[[UIBarButtonItem alloc] initWithTitle:@"Wrap" style:UIBarButtonItemStylePlain target:self action:@selector(toggleWrap)] autorelease];
    UIBarButtonItem *info=[[[UIBarButtonItem alloc] initWithTitle:@"Bilgi" style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)] autorelease];
    UIBarButtonItem *flex=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

    if(_isMarkdown) {
        _markdownButton=[[UIBarButtonItem alloc] initWithTitle:@"Kaynak" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMarkdownMode)];
        _toolbar.items=[NSArray arrayWithObjects:minus,flex,plus,flex,wrap,flex,_markdownButton,flex,info,nil];
    } else {
        _toolbar.items=[NSArray arrayWithObjects:minus,flex,plus,flex,wrap,flex,info,nil];
    }
    [self.view addSubview:_toolbar];

    [self loadTextFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b=self.view.bounds;
    CGFloat toolbarHeight=44.0f;
    _toolbar.frame=CGRectMake(0,b.size.height-toolbarHeight,b.size.width,toolbarHeight);
    _horizontalScrollView.frame=CGRectMake(0,0,b.size.width,MAX(0.0f,b.size.height-toolbarHeight));
    [self layoutTextViewPreservingOffset:YES];
}

- (CGFloat)noWrapWidthForText:(NSString *)text minimum:(CGFloat)minimumWidth {
    if(!text||[text length]==0) return minimumWidth;
    NSUInteger length=[text length];
    NSUInteger currentLine=0;
    NSUInteger longestLine=0;
    for(NSUInteger i=0;i<length;i++) {
        unichar ch=[text characterAtIndex:i];
        if(ch=='\n'||ch=='\r') {
            if(currentLine>longestLine) longestLine=currentLine;
            currentLine=0;
        } else {
            currentLine++;
        }
    }
    if(currentLine>longestLine) longestLine=currentLine;
    CGFloat estimated=(CGFloat)longestLine*_fontSize*0.65f+32.0f;
    return MIN(IPAD1_TEXT_MAX_NOWRAP_WIDTH,MAX(minimumWidth,estimated));
}

- (void)layoutTextViewPreservingOffset:(BOOL)preserve {
    if(!_textView||!_horizontalScrollView) return;
    CGPoint horizontalOffset=_horizontalScrollView.contentOffset;
    CGRect bounds=_horizontalScrollView.bounds;
    CGFloat width=bounds.size.width;
    if(!_wrapEnabled) width=[self noWrapWidthForText:_textView.text minimum:bounds.size.width];
    _textView.frame=CGRectMake(0,0,width,bounds.size.height);
    _horizontalScrollView.contentSize=CGSizeMake(width,bounds.size.height);
    _horizontalScrollView.scrollEnabled=!_wrapEnabled;
    _horizontalScrollView.alwaysBounceHorizontal=!_wrapEnabled;
    if(_wrapEnabled) {
        _horizontalScrollView.contentOffset=CGPointZero;
    } else if(preserve) {
        CGFloat maxX=MAX(0.0f,width-bounds.size.width);
        horizontalOffset.x=MIN(maxX,MAX(0.0f,horizontalOffset.x));
        horizontalOffset.y=0.0f;
        _horizontalScrollView.contentOffset=horizontalOffset;
    }
}

- (NSString *)markdownInlineReadingText:(NSString *)line {
    if(!line) return @"";
    NSMutableString *out=[NSMutableString stringWithCapacity:[line length]];
    NSUInteger length=[line length];
    NSUInteger i=0;
    while(i<length) {
        unichar c=[line characterAtIndex:i];

        if(c=='[') {
            NSRange close=[line rangeOfString:@"]" options:0 range:NSMakeRange(i+1,length-i-1)];
            if(close.location!=NSNotFound && NSMaxRange(close)<length && [line characterAtIndex:NSMaxRange(close)]=='(') {
                NSUInteger urlStart=NSMaxRange(close)+1;
                NSRange end=[line rangeOfString:@")" options:0 range:NSMakeRange(urlStart,length-urlStart)];
                if(end.location!=NSNotFound) {
                    NSString *label=[line substringWithRange:NSMakeRange(i+1,close.location-i-1)];
                    NSString *url=[line substringWithRange:NSMakeRange(urlStart,end.location-urlStart)];
                    [out appendString:label];
                    if([url length]>0) [out appendFormat:@" <%@>",url];
                    i=NSMaxRange(end);
                    continue;
                }
            }
        }

        if(c=='!' && i+1<length && [line characterAtIndex:i+1]=='[') {
            NSRange close=[line rangeOfString:@"]" options:0 range:NSMakeRange(i+2,length-i-2)];
            if(close.location!=NSNotFound) {
                NSString *alt=[line substringWithRange:NSMakeRange(i+2,close.location-i-2)];
                [out appendFormat:@"[Görsel%@%@]",[alt length]?@": ":@"",alt];
                NSUInteger next=NSMaxRange(close);
                if(next<length && [line characterAtIndex:next]=='(') {
                    NSRange end=[line rangeOfString:@")" options:0 range:NSMakeRange(next+1,length-next-1)];
                    if(end.location!=NSNotFound) next=NSMaxRange(end);
                }
                i=next;
                continue;
            }
        }

        if(c=='*'||c=='_'||c=='`') {
            i++;
            continue;
        }

        if(c=='\\' && i+1<length) {
            [out appendFormat:@"%C",[line characterAtIndex:i+1]];
            i+=2;
            continue;
        }

        [out appendFormat:@"%C",c];
        i++;
    }
    return out;
}

- (BOOL)isMarkdownRuleLine:(NSString *)trimmed {
    if([trimmed length]<3) return NO;
    unichar first=[trimmed characterAtIndex:0];
    if(first!='-'&&first!='*'&&first!='_') return NO;
    for(NSUInteger i=1;i<[trimmed length];i++) {
        unichar c=[trimmed characterAtIndex:i];
        if(c!=first && c!=' ' && c!='\t') return NO;
    }
    return YES;
}

- (NSString *)markdownReadingTextFromSource:(NSString *)source {
    if(!source) return @"";
    NSArray *lines=[source componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableString *out=[NSMutableString stringWithCapacity:MIN((NSUInteger)262144,[source length])];
    BOOL inCode=NO;

    for(NSUInteger n=0;n<[lines count];n++) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        NSString *line=[lines objectAtIndex:n];
        NSString *trim=[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if([trim hasPrefix:@"```"]||[trim hasPrefix:@"~~~"]) {
            inCode=!inCode;
            if([out length]>0 && ![out hasSuffix:@"\n"]) [out appendString:@"\n"];
            [out appendString:inCode?@"Kod:\n":@"\n"];
            [pool drain];
            continue;
        }

        if(inCode) {
            [out appendFormat:@"    %@\n",line];
            [pool drain];
            continue;
        }

        if([self isMarkdownRuleLine:trim]) {
            [out appendString:@"────────────────────────\n"];
            [pool drain];
            continue;
        }

        NSString *working=line;
        NSUInteger hashCount=0;
        while(hashCount<[working length] && [working characterAtIndex:hashCount]=='#') hashCount++;
        if(hashCount>0 && hashCount<=6 && hashCount<[working length] && [working characterAtIndex:hashCount]==' ') {
            working=[working substringFromIndex:hashCount+1];
            working=[self markdownInlineReadingText:working];
            if([out length]>0 && ![out hasSuffix:@"\n\n"]) [out appendString:@"\n"];
            [out appendFormat:@"%@%@\n\n",hashCount<=2?@"◆ ":@"▸ ",working];
            [pool drain];
            continue;
        }

        NSString *left=[working stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([left hasPrefix:@"> "]||[left isEqualToString:@">"]) {
            NSString *body=[left length]>1?[left substringFromIndex:1]:@"";
            body=[body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [out appendFormat:@"│ %@\n",[self markdownInlineReadingText:body]];
            [pool drain];
            continue;
        }

        if([left hasPrefix:@"- "]||[left hasPrefix:@"* "]||[left hasPrefix:@"+ "]) {
            NSString *body=[left substringFromIndex:2];
            [out appendFormat:@"• %@\n",[self markdownInlineReadingText:body]];
            [pool drain];
            continue;
        }

        [out appendString:[self markdownInlineReadingText:working]];
        if(n+1<[lines count]) [out appendString:@"\n"];
        [pool drain];
    }
    return out;
}

- (void)applyCurrentTextModePreservingOffset:(BOOL)preserve {
    if(_isMarkdown && _markdownReadingMode) _textView.text=[self markdownReadingTextFromSource:_sourceText];
    else _textView.text=_sourceText?_sourceText:@"";
    _lastMatch=NSMakeRange(NSNotFound,0);
    [self layoutTextViewPreservingOffset:preserve];
    if(_markdownButton) _markdownButton.title=_markdownReadingMode?@"Kaynak":@"MD Oku";
}

- (void)toggleMarkdownMode {
    if(!_isMarkdown) return;
    _markdownReadingMode=!_markdownReadingMode;
    [self applyCurrentTextModePreservingOffset:NO];
    [self showSimpleAlert:@"Markdown" message:_markdownReadingMode?@"Okuma görünümü açık.":@"Kaynak görünümü açık."];
}

- (void)loadTextFile {
    if(!_filePath||![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [self showSimpleAlert:@"Dosya açılamadı" message:@"Dosya bulunamadı."];
        return;
    }
    NSDictionary *attributes=[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
    _fileSize=[[attributes objectForKey:NSFileSize] unsignedLongLongValue];
    if(_fileSize>IPAD1_TEXT_MAX_BYTES) {
        NSString *message=[NSString stringWithFormat:@"Dosya %.2f MB. iPad 1 bellek güvenliği için Text Reader tam yükleme sınırı %.0f MB. Dosya belleğe yüklenmedi.",(double)_fileSize/1048576.0,(double)IPAD1_TEXT_MAX_BYTES/1048576.0];
        _textView.text=@"";
        [self showSimpleAlert:@"Dosya çok büyük" message:message];
        return;
    }

    NSData *data=[[NSData alloc] initWithContentsOfFile:_filePath];
    if(!data) {
        [self showSimpleAlert:@"Dosya açılamadı" message:@"Dosya okunamadı."];
        return;
    }
    NSString *text=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [data release];
    if(!text) {
        [self showSimpleAlert:@"Kodlama desteklenmiyor" message:@"Bu sürüm yalnızca UTF-8 metin dosyalarını görüntüler."];
        return;
    }
    if([text length]>0&&[text characterAtIndex:0]==0xFEFF) {
        NSString *withoutBOM=[[text substringFromIndex:1] copy];
        [text release];
        text=withoutBOM;
    }
    [_sourceText release];
    _sourceText=[text copy];
    [text release];
    [self applyCurrentTextModePreservingOffset:NO];
}

- (void)showSimpleAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)increaseFont {
    _fontSize=MIN(IPAD1_TEXT_MAX_FONT,_fontSize+2.0f);
    _textView.font=[UIFont systemFontOfSize:_fontSize];
    [self layoutTextViewPreservingOffset:YES];
}

- (void)decreaseFont {
    _fontSize=MAX(IPAD1_TEXT_MIN_FONT,_fontSize-2.0f);
    _textView.font=[UIFont systemFontOfSize:_fontSize];
    [self layoutTextViewPreservingOffset:YES];
}

- (void)toggleWrap {
    _wrapEnabled=!_wrapEnabled;
    [self layoutTextViewPreservingOffset:NO];
    [self showSimpleAlert:@"Word Wrap" message:_wrapEnabled?@"Açık":@"Kapalı"];
}

- (void)showInfo {
    NSString *sizeText=(_fileSize>=1048576ULL)?[NSString stringWithFormat:@"%.2f MB",(double)_fileSize/1048576.0]:[NSString stringWithFormat:@"%.1f KB",(double)_fileSize/1024.0];
    NSString *mode=_isMarkdown?(_markdownReadingMode?@"Markdown okuma":@"Markdown kaynak"):@"Düz metin";
    NSString *message=[NSString stringWithFormat:@"Dosya: %@\nBoyut: %@\nKodlama: UTF-8\nMod: %@ / Salt okunur\nWrap: %@\n\nTam yol:\n%@",[_filePath lastPathComponent],sizeText,mode,_wrapEnabled?@"Açık":@"Kapalı",_filePath];
    [self showSimpleAlert:@"Text Reader Bilgisi" message:message];
}

- (void)showSearchActions {
    if(![_searchTerm length]) {
        [self promptForSearch];
        return;
    }
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Ara: %@",_searchTerm] delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Yeni Ara",@"Sonraki",@"Önceki",nil] autorelease];
    s.tag=301;
    [s showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)promptForSearch {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Metinde Ara" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Bul",nil] autorelease];
    a.alertViewStyle=UIAlertViewStylePlainTextInput;
    [[a textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[a textFieldAtIndex:0] setAutocorrectionType:UITextAutocorrectionTypeNo];
    if([_searchTerm length]) [a textFieldAtIndex:0].text=_searchTerm;
    a.tag=300;
    [a show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag!=301) return;
    if(buttonIndex==0) [self promptForSearch];
    else if(buttonIndex==1) [self findNext];
    else if(buttonIndex==2) [self findPrevious];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag!=300||buttonIndex!=1) return;
    NSString *term=[[alertView textFieldAtIndex:0] text];
    if(![term length]) return;
    [_searchTerm release];
    _searchTerm=[term copy];
    _lastMatch=NSMakeRange(NSNotFound,0);
    [self findNext];
}

- (void)showMatch:(NSRange)range {
    _lastMatch=range;
    _textView.selectedRange=range;
    [_textView scrollRangeToVisible:range];
}

- (void)findNext {
    NSString *text=_textView.text;
    if(![_searchTerm length]||![text length]) return;
    NSUInteger start=(_lastMatch.location==NSNotFound)?0:NSMaxRange(_lastMatch);
    if(start>[text length]) start=0;
    NSRange r=[text rangeOfString:_searchTerm options:NSCaseInsensitiveSearch range:NSMakeRange(start,[text length]-start)];
    if(r.location==NSNotFound&&start>0) r=[text rangeOfString:_searchTerm options:NSCaseInsensitiveSearch range:NSMakeRange(0,start)];
    if(r.location==NSNotFound) {
        [self showSimpleAlert:@"Bulunamadı" message:[NSString stringWithFormat:@"“%@” metin içinde bulunamadı.",_searchTerm]];
        return;
    }
    [self showMatch:r];
}

- (void)findPrevious {
    NSString *text=_textView.text;
    if(![_searchTerm length]||![text length]) return;
    NSUInteger end=(_lastMatch.location==NSNotFound)?[text length]:_lastMatch.location;
    NSRange r=NSMakeRange(NSNotFound,0);
    if(end>0) r=[text rangeOfString:_searchTerm options:(NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(0,end)];
    if(r.location==NSNotFound&&end<[text length]) r=[text rangeOfString:_searchTerm options:(NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(end,[text length]-end)];
    if(r.location==NSNotFound) {
        [self showSimpleAlert:@"Bulunamadı" message:[NSString stringWithFormat:@"“%@” metin içinde bulunamadı.",_searchTerm]];
        return;
    }
    [self showMatch:r];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(!self.view.window) {
        _textView.text=@"";
        [_sourceText release]; _sourceText=nil;
        [_searchTerm release]; _searchTerm=nil;
        _lastMatch=NSMakeRange(NSNotFound,0);
    }
}

- (void)dealloc {
    [_filePath release];
    [_sourceText release];
    [_textView release];
    [_horizontalScrollView release];
    [_toolbar release];
    [_markdownButton release];
    [_searchTerm release];
    [super dealloc];
}

@end
