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
    _toolbar.items=[NSArray arrayWithObjects:minus,flex,plus,flex,wrap,flex,info,nil];
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
    NSUInteger start=0;
    CGFloat maxWidth=minimumWidth;
    UIFont *font=[UIFont systemFontOfSize:_fontSize];
    while(start<length) {
        NSRange lineEnd=[text rangeOfString:@"\n" options:0 range:NSMakeRange(start,length-start)];
        NSUInteger end=(lineEnd.location==NSNotFound)?length:lineEnd.location;
        NSRange lineRange=NSMakeRange(start,end-start);
        if(lineRange.length>0) {
            NSString *line=[text substringWithRange:lineRange];
            CGSize s=[line sizeWithFont:font];
            maxWidth=MAX(maxWidth,s.width+32.0f);
            if(maxWidth>=IPAD1_TEXT_MAX_NOWRAP_WIDTH) return IPAD1_TEXT_MAX_NOWRAP_WIDTH;
        }
        if(lineEnd.location==NSNotFound) break;
        start=lineEnd.location+1;
    }
    return MIN(IPAD1_TEXT_MAX_NOWRAP_WIDTH,maxWidth);
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

- (void)loadTextFile {
    if(!_filePath||![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [self showSimpleAlert:@"Dosya açılamadı" message:@"Dosya bulunamadı."];
        return;
    }
    NSDictionary *attributes=[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
    _fileSize=[[attributes objectForKey:NSFileSize] unsignedLongLongValue];
    if(_fileSize>IPAD1_TEXT_MAX_BYTES) {
        NSString *message=[NSString stringWithFormat:@"Dosya %.2f MB. iPad 1 bellek güvenliği için Text Reader ilk sürümünde tam yükleme sınırı %.0f MB. Dosya belleğe yüklenmedi.",(double)_fileSize/1048576.0,(double)IPAD1_TEXT_MAX_BYTES/1048576.0];
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
    _textView.text=text;
    [text release];
    [self layoutTextViewPreservingOffset:NO];
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
    NSString *message=[NSString stringWithFormat:@"Dosya: %@\nBoyut: %@\nKodlama: UTF-8\nMod: Salt okunur\nWrap: %@\n\nTam yol:\n%@",[_filePath lastPathComponent],sizeText,_wrapEnabled?@"Açık":@"Kapalı",_filePath];
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
        [_searchTerm release]; _searchTerm=nil;
        _lastMatch=NSMakeRange(NSNotFound,0);
    }
}

- (void)dealloc {
    [_filePath release];
    [_textView release];
    [_horizontalScrollView release];
    [_toolbar release];
    [_searchTerm release];
    [super dealloc];
}

@end
