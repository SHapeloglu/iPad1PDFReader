#import "MarkdownReaderViewController.h"
#import "MarkdownRichTextView.h"
#import "TextReaderViewController.h"

static const unsigned long long IPAD1_MD_MAX_BYTES = 2ULL * 1024ULL * 1024ULL;
static const CGFloat IPAD1_MD_MIN_FONT = 10.0f;
static const CGFloat IPAD1_MD_MAX_FONT = 28.0f;
static const CGFloat IPAD1_MD_DEFAULT_FONT = 18.0f;

@implementation MarkdownReaderViewController

- (id)initWithMarkdownPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _filePath=[path copy];
        _fontSize=IPAD1_MD_DEFAULT_FONT;
        _lastMatch=NSMakeRange(NSNotFound,0);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=[_filePath lastPathComponent];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Ara" style:UIBarButtonItemStylePlain target:self action:@selector(showSearchActions)] autorelease];

    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.backgroundColor=[UIColor whiteColor];
    _scrollView.alwaysBounceVertical=YES;
    _scrollView.alwaysBounceHorizontal=NO;
    [self.view addSubview:_scrollView];

    _richView=[[MarkdownRichTextView alloc] initWithFrame:CGRectZero];
    _richView.baseFontSize=_fontSize;
    [_scrollView addSubview:_richView];

    _toolbar=[[UIToolbar alloc] initWithFrame:CGRectZero];
    UIBarButtonItem *minus=[[[UIBarButtonItem alloc] initWithTitle:@"A-" style:UIBarButtonItemStylePlain target:self action:@selector(decreaseFont)] autorelease];
    UIBarButtonItem *plus=[[[UIBarButtonItem alloc] initWithTitle:@"A+" style:UIBarButtonItemStylePlain target:self action:@selector(increaseFont)] autorelease];
    UIBarButtonItem *source=[[[UIBarButtonItem alloc] initWithTitle:@"Kaynak" style:UIBarButtonItemStylePlain target:self action:@selector(showSource)] autorelease];
    UIBarButtonItem *info=[[[UIBarButtonItem alloc] initWithTitle:@"Bilgi" style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)] autorelease];
    UIBarButtonItem *flex=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    _toolbar.items=[NSArray arrayWithObjects:minus,flex,plus,flex,source,flex,info,nil];
    [self.view addSubview:_toolbar];

    [self loadMarkdownFile];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b=self.view.bounds;
    CGFloat toolbarHeight=44.0f;
    _toolbar.frame=CGRectMake(0,b.size.height-toolbarHeight,b.size.width,toolbarHeight);
    _scrollView.frame=CGRectMake(0,0,b.size.width,MAX(0.0f,b.size.height-toolbarHeight));
    [self relayoutRichViewPreservingOffset:YES];
}

- (void)showSimpleAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)loadMarkdownFile {
    if(!_filePath || ![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [self showSimpleAlert:@"Dosya açılamadı" message:@"Dosya bulunamadı."];
        return;
    }
    NSDictionary *attrs=[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
    _fileSize=[[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    if(_fileSize>IPAD1_MD_MAX_BYTES) {
        [self showSimpleAlert:@"Dosya çok büyük" message:@"Markdown dosyası iPad 1 bellek güvenliği için 2 MiB sınırını aşıyor."];
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
        [self showSimpleAlert:@"Kodlama desteklenmiyor" message:@"Bu sürüm yalnızca UTF-8 Markdown dosyalarını görüntüler."];
        return;
    }
    if([text length]>0 && [text characterAtIndex:0]==0xFEFF) {
        NSString *withoutBOM=[[text substringFromIndex:1] copy];
        [text release];
        text=withoutBOM;
    }
    [_sourceText release];
    _sourceText=[text copy];
    [text release];
    [_richView setMarkdownSource:_sourceText];
    [self relayoutRichViewPreservingOffset:NO];
}

- (void)relayoutRichViewPreservingOffset:(BOOL)preserve {
    if(!_richView || !_scrollView) return;
    CGPoint oldOffset=_scrollView.contentOffset;
    CGFloat width=_scrollView.bounds.size.width;
    CGFloat height=[_richView contentHeightForWidth:width];
    CGFloat minimumHeight=_scrollView.bounds.size.height;
    _richView.frame=CGRectMake(0,0,width,MAX(height,minimumHeight));
    _scrollView.contentSize=CGSizeMake(width,MAX(height,minimumHeight));
    if(preserve) {
        CGFloat maxY=MAX(0.0f,_scrollView.contentSize.height-_scrollView.bounds.size.height);
        oldOffset.y=MIN(maxY,MAX(0.0f,oldOffset.y));
        oldOffset.x=0.0f;
        _scrollView.contentOffset=oldOffset;
    } else {
        _scrollView.contentOffset=CGPointZero;
    }
    [_richView setNeedsDisplay];
}

- (void)increaseFont {
    _fontSize=MIN(IPAD1_MD_MAX_FONT,_fontSize+2.0f);
    _richView.baseFontSize=_fontSize;
    [self relayoutRichViewPreservingOffset:YES];
}

- (void)decreaseFont {
    _fontSize=MAX(IPAD1_MD_MIN_FONT,_fontSize-2.0f);
    _richView.baseFontSize=_fontSize;
    [self relayoutRichViewPreservingOffset:YES];
}

- (void)showSource {
    if(!_filePath) return;
    TextReaderViewController *v=[[[TextReaderViewController alloc] initWithTextPath:_filePath] autorelease];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)showInfo {
    NSString *sizeText=(_fileSize>=1048576ULL)?[NSString stringWithFormat:@"%.2f MB",(double)_fileSize/1048576.0]:[NSString stringWithFormat:@"%.1f KB",(double)_fileSize/1024.0];
    NSString *message=[NSString stringWithFormat:@"Dosya: %@\nBoyut: %@\nKodlama: UTF-8\nMod: Markdown okuma / Salt okunur\nMotor: CoreText\n\nTam yol:\n%@",[_filePath lastPathComponent],sizeText,_filePath];
    [self showSimpleAlert:@"Markdown Bilgisi" message:message];
}

- (void)showSearchActions {
    if(![_searchTerm length]) {
        [self promptForSearch];
        return;
    }
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Ara: %@",_searchTerm] delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Yeni Ara",@"Sonraki",@"Önceki",nil] autorelease];
    s.tag=401;
    [s showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)promptForSearch {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Markdown İçinde Ara" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Bul",nil] autorelease];
    a.alertViewStyle=UIAlertViewStylePlainTextInput;
    [[a textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[a textFieldAtIndex:0] setAutocorrectionType:UITextAutocorrectionTypeNo];
    if([_searchTerm length]) [a textFieldAtIndex:0].text=_searchTerm;
    a.tag=400;
    [a show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag!=401) return;
    if(buttonIndex==0) [self promptForSearch];
    else if(buttonIndex==1) [self findNext];
    else if(buttonIndex==2) [self findPrevious];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag!=400 || buttonIndex!=1) return;
    NSString *term=[[alertView textFieldAtIndex:0] text];
    if(![term length]) return;
    [_searchTerm release];
    _searchTerm=[term copy];
    _lastMatch=NSMakeRange(NSNotFound,0);
    [self findNext];
}

- (void)scrollToMatch:(NSRange)range {
    _lastMatch=range;
    CGFloat y=[_richView yOffsetForCharacterIndex:range.location];
    CGFloat maxY=MAX(0.0f,_scrollView.contentSize.height-_scrollView.bounds.size.height);
    y=MIN(maxY,MAX(0.0f,y));
    [_scrollView setContentOffset:CGPointMake(0,y) animated:YES];
}

- (void)findNext {
    NSString *text=_richView.plainText;
    if(![_searchTerm length] || ![text length]) return;
    NSUInteger start=(_lastMatch.location==NSNotFound)?0:NSMaxRange(_lastMatch);
    if(start>[text length]) start=0;
    NSRange r=[text rangeOfString:_searchTerm options:NSCaseInsensitiveSearch range:NSMakeRange(start,[text length]-start)];
    if(r.location==NSNotFound && start>0) r=[text rangeOfString:_searchTerm options:NSCaseInsensitiveSearch range:NSMakeRange(0,start)];
    if(r.location==NSNotFound) {
        [self showSimpleAlert:@"Bulunamadı" message:[NSString stringWithFormat:@"“%@” Markdown içinde bulunamadı.",_searchTerm]];
        return;
    }
    [self scrollToMatch:r];
}

- (void)findPrevious {
    NSString *text=_richView.plainText;
    if(![_searchTerm length] || ![text length]) return;
    NSUInteger end=(_lastMatch.location==NSNotFound)?[text length]:_lastMatch.location;
    NSRange r=NSMakeRange(NSNotFound,0);
    if(end>0) r=[text rangeOfString:_searchTerm options:(NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(0,end)];
    if(r.location==NSNotFound && end<[text length]) r=[text rangeOfString:_searchTerm options:(NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(end,[text length]-end)];
    if(r.location==NSNotFound) {
        [self showSimpleAlert:@"Bulunamadı" message:[NSString stringWithFormat:@"“%@” Markdown içinde bulunamadı.",_searchTerm]];
        return;
    }
    [self scrollToMatch:r];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(!self.view.window) {
        [_sourceText release]; _sourceText=nil;
        [_richView setMarkdownSource:nil];
        [_searchTerm release]; _searchTerm=nil;
        _lastMatch=NSMakeRange(NSNotFound,0);
    }
}

- (void)dealloc {
    [_filePath release];
    [_sourceText release];
    [_scrollView release];
    [_richView release];
    [_toolbar release];
    [_searchTerm release];
    [super dealloc];
}
@end
