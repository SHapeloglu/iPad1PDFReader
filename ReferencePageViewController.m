#import "ReferencePageViewController.h"
#import "PDFPageView.h"
#import "AppearanceStore.h"

@implementation ReferencePageViewController

- (id)initWithPDFPath:(NSString *)path pageNumber:(NSUInteger)pageNumber {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _pdfPath=[path copy];
        _pageNumber=pageNumber;
        _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_pdfPath]);
        if(_document && _pageNumber>=1 && _pageNumber<=CGPDFDocumentGetNumberOfPages(_document)) {
            _page=CGPDFDocumentGetPage(_document,_pageNumber);
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor darkGrayColor];

    _titleLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor=[UIColor colorWithWhite:0.95f alpha:1.0f];
    _titleLabel.textColor=[UIColor darkTextColor];
    _titleLabel.textAlignment=UITextAlignmentCenter;
    _titleLabel.font=[UIFont boldSystemFontOfSize:13.0f];
    _titleLabel.text=[NSString stringWithFormat:@"Referans Sayfa — %lu",(unsigned long)_pageNumber];
    [self.view addSubview:_titleLabel];

    _pageView=[[PDFPageView alloc] initWithFrame:CGRectZero];
    _pageView.theme=[AppearanceStore theme];
    [_pageView setPDFPage:_page];
    [self.view addSubview:_pageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b=self.view.bounds;
    CGFloat titleH=32.0f;
    _titleLabel.frame=CGRectMake(0,0,b.size.width,titleH);
    if(!_page || b.size.width<=0 || b.size.height<=titleH) return;

    CGRect box=CGPDFPageGetBoxRect(_page,kCGPDFMediaBox);
    CGFloat w=box.size.width,h=box.size.height;
    int r=CGPDFPageGetRotationAngle(_page);
    if(r==90||r==270){CGFloat t=w;w=h;h=t;}
    CGFloat aw=MAX(1.0f,b.size.width-20.0f);
    CGFloat ah=MAX(1.0f,b.size.height-titleH-20.0f);
    CGFloat s=MIN(aw/w,ah/h);
    CGSize z=CGSizeMake(floor(w*s),floor(h*s));
    _pageView.frame=CGRectMake(floor((b.size.width-z.width)*0.5f),titleH+floor((b.size.height-titleH-z.height)*0.5f),z.width,z.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(!self.view.window) _pageView.pdfPage=NULL;
}

- (void)dealloc {
    _pageView.pdfPage=NULL;
    [_pageView release];
    [_titleLabel release];
    [_pdfPath release];
    if(_document) CGPDFDocumentRelease(_document);
    [super dealloc];
}
@end
