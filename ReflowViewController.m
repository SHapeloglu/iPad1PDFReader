#import "ReflowViewController.h"
#import "PDFTextExtractor.h"

@implementation ReflowViewController

- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _pdfPath=[path copy];
        _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        _pageCount=_document?CGPDFDocumentGetNumberOfPages(_document):0;
        _currentPage=1;
        self.title=@"Reflow";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];

    _fontControl=[[UISegmentedControl alloc] initWithItems:
        [NSArray arrayWithObjects:@"A-",@"A",@"A+",nil]];
    _fontControl.selectedSegmentIndex=1;
    [_fontControl addTarget:self action:@selector(fontChanged)
           forControlEvents:UIControlEventValueChanged];

    self.navigationItem.rightBarButtonItem=
        [[[UIBarButtonItem alloc] initWithCustomView:_fontControl] autorelease];

    _textView=[[UITextView alloc] initWithFrame:CGRectZero];
    _textView.editable=NO;
    _textView.font=[UIFont systemFontOfSize:19.0f];
    [self.view addSubview:_textView];

    UIToolbar *bar=[[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
    bar.tag=321;
    UIBarButtonItem *prev=[[[UIBarButtonItem alloc] initWithTitle:@"Önceki"
        style:UIBarButtonItemStylePlain target:self action:@selector(previousPage)] autorelease];
    UIBarButtonItem *next=[[[UIBarButtonItem alloc] initWithTitle:@"Sonraki"
        style:UIBarButtonItemStylePlain target:self action:@selector(nextPage)] autorelease];
    _pageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,100,30)];
    _pageLabel.textAlignment=NSTextAlignmentCenter;
    _pageLabel.backgroundColor=[UIColor clearColor];
    UIBarButtonItem *label=[[[UIBarButtonItem alloc] initWithCustomView:_pageLabel] autorelease];
    UIBarButtonItem *flex=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    bar.items=[NSArray arrayWithObjects:prev,flex,label,flex,next,nil];
    [self.view addSubview:bar];

    [self loadCurrentPage];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIToolbar *bar=(UIToolbar *)[self.view viewWithTag:321];
    CGFloat h=44.0f;
    CGRect b=self.view.bounds;
    bar.frame=CGRectMake(0,b.size.height-h,b.size.width,h);
    _textView.frame=CGRectMake(0,0,b.size.width,b.size.height-h);
}

- (void)loadCurrentPage {
    if(!_document || _currentPage<1 || _currentPage>_pageCount) return;

    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    NSString *txt=[PDFTextExtractor textForPage:CGPDFDocumentGetPage(_document,_currentPage)];
    _textView.text=txt;
    _pageLabel.text=[NSString stringWithFormat:@"%lu / %lu",
                     (unsigned long)_currentPage,
                     (unsigned long)_pageCount];
    [_textView setContentOffset:CGPointZero animated:NO];
    [pool drain];
}

- (void)previousPage {
    if(_currentPage>1) {
        _currentPage--;
        [self loadCurrentPage];
    }
}

- (void)nextPage {
    if(_currentPage<_pageCount) {
        _currentPage++;
        [self loadCurrentPage];
    }
}

- (void)fontChanged {
    CGFloat sizes[]={15.0f,19.0f,25.0f};
    NSInteger idx=_fontControl.selectedSegmentIndex;
    if(idx<0||idx>2) idx=1;
    _textView.font=[UIFont systemFontOfSize:sizes[idx]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(!self.view.window) {
        _textView.text=nil;
    }
}

- (void)dealloc {
    [_pdfPath release];
    [_textView release];
    [_fontControl release];
    [_pageLabel release];
    if(_document) CGPDFDocumentRelease(_document);
    [super dealloc];
}
@end
