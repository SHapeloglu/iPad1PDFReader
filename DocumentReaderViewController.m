#import "DocumentReaderViewController.h"
#import "DocumentRichTextView.h"
#import "DOCXReader.h"

static const CGFloat IPAD1_DOC_DEFAULT_FONT=17.0f;
static const CGFloat IPAD1_DOC_MIN_FONT=10.0f;
static const CGFloat IPAD1_DOC_MAX_FONT=28.0f;

@implementation DocumentReaderViewController

- (id)initWithDocumentPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _filePath=[path copy];
        _fontSize=IPAD1_DOC_DEFAULT_FONT;
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

    _richView=[[DocumentRichTextView alloc] initWithFrame:CGRectZero];
    _richView.baseFontSize=_fontSize;
    [_scrollView addSubview:_richView];

    _toolbar=[[UIToolbar alloc] initWithFrame:CGRectZero];
    UIBarButtonItem *minus=[[[UIBarButtonItem alloc] initWithTitle:@"A-" style:UIBarButtonItemStylePlain target:self action:@selector(decreaseFont)] autorelease];
    UIBarButtonItem *plus=[[[UIBarButtonItem alloc] initWithTitle:@"A+" style:UIBarButtonItemStylePlain target:self action:@selector(increaseFont)] autorelease];
    UIBarButtonItem *info=[[[UIBarButtonItem alloc] initWithTitle:@"Bilgi" style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)] autorelease];
    UIBarButtonItem *flex=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    _toolbar.items=[NSArray arrayWithObjects:minus,flex,plus,flex,info,nil];
    [self.view addSubview:_toolbar];

    [self loadDocument];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b=self.view.bounds;
    CGFloat toolbarHeight=44.0f;
    _toolbar.frame=CGRectMake(0,b.size.height-toolbarHeight,b.size.width,toolbarHeight);
    _scrollView.frame=CGRectMake(0,0,b.size.width,MAX(0.0f,b.size.height-toolbarHeight));
    [self relayoutPreservingOffset:YES];
}

- (void)showSimpleAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)loadDocument {
    if(!_filePath || ![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        [self showSimpleAlert:@"Dosya açılamadı" message:@"Dosya bulunamadı."];
        return;
    }
    NSDictionary *attrs=[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil];
    _fileSize=[[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    if(_fileSize>[DOCXReader maximumSafeCompressedSize]) {
        [self showSimpleAlert:@"Dosya çok büyük" message:@"DOCX dosyası iPad 1 için 8 MiB güvenli sınırını aşıyor."];
        return;
    }
    DOCXReader *reader=[[[DOCXReader alloc] init] autorelease];
    NSError *error=nil;
    if(![reader loadDOCXAtPath:_filePath error:&error]) {
        [self showSimpleAlert:@"DOCX açılamadı" message:[error localizedDescription]];
        return;
    }
    [_richView setDocumentText:reader.plainText styles:reader.styles];
    [self relayoutPreservingOffset:NO];
}

- (void)relayoutPreservingOffset:(BOOL)preserve {
    if(!_richView || !_scrollView) return;
    CGPoint old=_scrollView.contentOffset;
    CGFloat width=_scrollView.bounds.size.width;
    CGFloat height=[_richView contentHeightForWidth:width];
    CGFloat minimum=_scrollView.bounds.size.height;
    _richView.frame=CGRectMake(0,0,width,MAX(height,minimum));
    _scrollView.contentSize=CGSizeMake(width,MAX(height,minimum));
    if(preserve) {
        CGFloat maxY=MAX(0.0f,_scrollView.contentSize.height-_scrollView.bounds.size.height);
        old.y=MIN(maxY,MAX(0.0f,old.y)); old.x=0.0f;
        _scrollView.contentOffset=old;
    } else _scrollView.contentOffset=CGPointZero;
    [_richView setNeedsDisplay];
}

- (void)increaseFont { _fontSize=MIN(IPAD1_DOC_MAX_FONT,_fontSize+2.0f); _richView.baseFontSize=_fontSize; [self relayoutPreservingOffset:YES]; }
- (void)decreaseFont { _fontSize=MAX(IPAD1_DOC_MIN_FONT,_fontSize-2.0f); _richView.baseFontSize=_fontSize; [self relayoutPreservingOffset:YES]; }

- (void)showInfo {
    NSString *sizeText=(_fileSize>=1048576ULL)?[NSString stringWithFormat:@"%.2f MB",(double)_fileSize/1048576.0]:[NSString stringWithFormat:@"%.1f KB",(double)_fileSize/1024.0];
    NSString *message=[NSString stringWithFormat:@"Dosya: %@\nBoyut: %@\nMod: DOCX salt okunur\nMotor: bounded ZIP + NSXMLParser + CoreText\n\nTam yol:\n%@",[_filePath lastPathComponent],sizeText,_filePath];
    [self showSimpleAlert:@"DOCX Bilgisi" message:message];
}

- (void)showSearchActions {
    if(![_searchTerm length]) { [self promptForSearch]; return; }
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Ara: %@",_searchTerm] delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Yeni Ara",@"Sonraki",@"Önceki",nil] autorelease];
    s.tag=501; [s showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)promptForSearch {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"DOCX İçinde Ara" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Bul",nil] autorelease];
    a.alertViewStyle=UIAlertViewStylePlainTextInput;
    [[a textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [[a textFieldAtIndex:0] setAutocorrectionType:UITextAutocorrectionTypeNo];
    if([_searchTerm length]) [a textFieldAtIndex:0].text=_searchTerm;
    a.tag=500; [a show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag!=501) return;
    if(buttonIndex==0) [self promptForSearch];
    else if(buttonIndex==1) [self findNext];
    else if(buttonIndex==2) [self findPrevious];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag!=500 || buttonIndex!=1) return;
    NSString *term=[[alertView textFieldAtIndex:0] text];
    if(![term length]) return;
    [_searchTerm release]; _searchTerm=[term copy];
    _lastMatch=NSMakeRange(NSNotFound,0);
    [self findNext];
}

- (void)scrollToMatch:(NSRange)range {
    _lastMatch=range;
    CGFloat y=[_richView yOffsetForCharacterIndex:range.location];
    CGFloat maxY=MAX(0.0f,_scrollView.contentSize.height-_scrollView.bounds.size.height);
    [_scrollView setContentOffset:CGPointMake(0,MIN(maxY,MAX(0.0f,y))) animated:YES];
}

- (void)findNext {
    NSString *text=_richView.plainText;
    if(![_searchTerm length] || ![text length]) return;
    NSUInteger start=(_lastMatch.location==NSNotFound)?0:NSMaxRange(_lastMatch);
    if(start>[text length]) start=0;
    NSRange r=[text rangeOfString:_searchTerm options:NSCaseInsensitiveSearch range:NSMakeRange(start,[text length]-start)];
    if(r.location==NSNotFound && start>0) r=[text rangeOfString:_searchTerm options:NSCaseInsensitiveSearch range:NSMakeRange(0,start)];
    if(r.location==NSNotFound) { [self showSimpleAlert:@"Bulunamadı" message:[NSString stringWithFormat:@"“%@” DOCX içinde bulunamadı.",_searchTerm]]; return; }
    [self scrollToMatch:r];
}

- (void)findPrevious {
    NSString *text=_richView.plainText;
    if(![_searchTerm length] || ![text length]) return;
    NSUInteger end=(_lastMatch.location==NSNotFound)?[text length]:_lastMatch.location;
    NSRange r=NSMakeRange(NSNotFound,0);
    if(end>0) r=[text rangeOfString:_searchTerm options:(NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(0,end)];
    if(r.location==NSNotFound && end<[text length]) r=[text rangeOfString:_searchTerm options:(NSCaseInsensitiveSearch|NSBackwardsSearch) range:NSMakeRange(end,[text length]-end)];
    if(r.location==NSNotFound) { [self showSimpleAlert:@"Bulunamadı" message:[NSString stringWithFormat:@"“%@” DOCX içinde bulunamadı.",_searchTerm]]; return; }
    [self scrollToMatch:r];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(!self.view.window) {
        [_richView setDocumentText:nil styles:nil];
        [_searchTerm release]; _searchTerm=nil;
        _lastMatch=NSMakeRange(NSNotFound,0);
    }
}

- (void)dealloc {
    [_filePath release]; [_richView release]; [_scrollView release]; [_toolbar release]; [_searchTerm release];
    [super dealloc];
}
@end
