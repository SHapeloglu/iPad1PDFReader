#import "PDFReaderViewController.h"
#import "PDFPageView.h"
#import "BookmarkStore.h"
#import "AppearanceStore.h"
#import "AnnotationOverlayView.h"
#import "AnnotationStore.h"
#import "ReflowViewController.h"
#import "PageManagerViewController.h"
#import "PDFAnnotationExporter.h"
#import "OutlineViewController.h"
#import "PDFOutlineParser.h"
@implementation PDFReaderViewController
- (id)initWithPDFPath:(NSString *)path { if((self=[super initWithNibName:nil bundle:nil]))_pdfPath=[path copy]; return self; }
- (void)viewDidLoad {
    [super viewDidLoad]; self.title=[[_pdfPath lastPathComponent] stringByDeletingPathExtension]; self.view.backgroundColor=[UIColor darkGrayColor];
    _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_pdfPath]); if(!_document){UIAlertView *e=[[[UIAlertView alloc] initWithTitle:@"PDF açılamadı" message:nil delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[e show];return;}
    _pageCount=CGPDFDocumentGetNumberOfPages(_document); _currentPage=[BookmarkStore lastPageForPath:_pdfPath]; if(_currentPage<1||_currentPage>_pageCount)_currentPage=1;
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectZero]; _scrollView.delegate=self; _scrollView.minimumZoomScale=1; _scrollView.maximumZoomScale=5; [_scrollView setBackgroundColor:[UIColor darkGrayColor]]; [self.view addSubview:_scrollView];
    _pageView=[[PDFPageView alloc] initWithFrame:CGRectZero]; _pageView.theme=[AppearanceStore theme]; [_scrollView addSubview:_pageView];
    _overlay=[[AnnotationOverlayView alloc] initWithFrame:CGRectZero]; _overlay.pdfPath=_pdfPath; [_pageView addSubview:_overlay];
    _toolbar=[[UIToolbar alloc] initWithFrame:CGRectZero];
    _previousButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previousPage)];
    _nextButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextPage)];
    _bookmarkButton=[[UIBarButtonItem alloc] initWithTitle:@"☆" style:UIBarButtonItemStylePlain target:self action:@selector(toggleBookmark)];
    UIBarButtonItem *thumb=[[[UIBarButtonItem alloc] initWithTitle:@"Sayfalar" style:UIBarButtonItemStylePlain target:self action:@selector(showThumbs)] autorelease];
    UIBarButtonItem *tools=[[[UIBarButtonItem alloc] initWithTitle:@"Araçlar" style:UIBarButtonItemStylePlain target:self action:@selector(showTools)] autorelease];
    _pageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,95,30)]; _pageLabel.textAlignment=NSTextAlignmentCenter; _pageLabel.backgroundColor=[UIColor clearColor];
    UIBarButtonItem *pi=[[[UIBarButtonItem alloc] initWithCustomView:_pageLabel] autorelease];
    _toolbar.items=[NSArray arrayWithObjects:_previousButton,pi,_nextButton,_bookmarkButton,thumb,tools,nil]; [self.view addSubview:_toolbar];
    [self displayCurrentPage];
}
- (void)viewDidLayoutSubviews { [super viewDidLayoutSubviews]; CGFloat h=44; CGRect b=self.view.bounds; _toolbar.frame=CGRectMake(0,b.size.height-h,b.size.width,h); _scrollView.frame=CGRectMake(0,0,b.size.width,b.size.height-h); [self layoutPage:NO]; }
- (void)layoutPage:(BOOL)reset { if(!_document||!_pageCount)return; CGPDFPageRef p=CGPDFDocumentGetPage(_document,_currentPage); CGRect box=CGPDFPageGetBoxRect(p,kCGPDFMediaBox); CGFloat w=box.size.width,h=box.size.height; int r=CGPDFPageGetRotationAngle(p); if(r==90||r==270){CGFloat q=w;w=h;h=q;} CGFloat aw=_scrollView.bounds.size.width-20,ah=_scrollView.bounds.size.height-20,s=MIN(aw/w,ah/h); CGSize z=CGSizeMake(floor(w*s),floor(h*s)); _pageView.frame=CGRectMake(MAX(10,(_scrollView.bounds.size.width-z.width)/2),MAX(10,(_scrollView.bounds.size.height-z.height)/2),z.width,z.height); _overlay.frame=_pageView.bounds; if(reset)_scrollView.zoomScale=1; }
- (void)displayCurrentPage { [_pageView setPDFPage:CGPDFDocumentGetPage(_document,_currentPage)]; [BookmarkStore setLastPage:_currentPage forPath:_pdfPath]; _overlay.page=_currentPage; [_overlay reloadAnnotations]; _pageLabel.text=[NSString stringWithFormat:@"%lu/%lu",(unsigned long)_currentPage,(unsigned long)_pageCount]; _bookmarkButton.title=[BookmarkStore isBookmarkedPage:_currentPage forPath:_pdfPath]?@"★":@"☆"; [self layoutPage:YES]; }
- (void)previousPage { if(_currentPage>1){_currentPage--;[self displayCurrentPage];} }
- (void)nextPage { if(_currentPage<_pageCount){_currentPage++;[self displayCurrentPage];} }
- (void)toggleBookmark { [BookmarkStore toggleBookmarkForPage:_currentPage forPath:_pdfPath]; [self displayCurrentPage]; }
- (void)showThumbs { ThumbnailViewController *v=[[[ThumbnailViewController alloc] initWithPDFPath:_pdfPath] autorelease]; v.delegate=self; [self.navigationController pushViewController:v animated:YES]; }
- (void)thumbnailControllerSelectedPage:(NSUInteger)p { _currentPage=p; [self displayCurrentPage]; }
- (void)searchControllerSelectedPage:(NSUInteger)p { _currentPage=p; [self displayCurrentPage]; }
- (void)showTools {
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Araçlar" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Ara",@"Reflow",@"İçindekiler",@"Çizim Aç/Kapat",@"Highlight",@"Not",@"İmza",@"Sayfa Yöneticisi",@"Annotation'lı PDF Dışa Aktar",nil] autorelease]; [s showFromToolbar:_toolbar];
}
- (void)actionSheet:(UIActionSheet *)s clickedButtonAtIndex:(NSInteger)b {
    if(b==0){SearchViewController *v=[[[SearchViewController alloc] initWithPDFPath:_pdfPath] autorelease];v.delegate=self;[self.navigationController pushViewController:v animated:YES];}
    else if(b==1)[self.navigationController pushViewController:[[[ReflowViewController alloc] initWithPDFPath:_pdfPath] autorelease] animated:YES];
    else if(b==2)[self.navigationController pushViewController:[[[OutlineViewController alloc] initWithItems:[PDFOutlineParser outlineForDocument:_document]] autorelease] animated:YES];
    else if(b==3)_overlay.drawingEnabled=!_overlay.drawingEnabled;
    else if(b==4){NSDictionary *a=[NSDictionary dictionaryWithObjectsAndKeys:@"highlight",@"type",NSStringFromCGRect(CGRectMake(.15,.35,.70,.10)),@"rect",nil];[AnnotationStore addAnnotation:a path:_pdfPath page:_currentPage];[_overlay reloadAnnotations];}
    else if(b==5){NSDictionary *a=[NSDictionary dictionaryWithObjectsAndKeys:@"note",@"type",NSStringFromCGRect(CGRectMake(.05,.05,.04,.04)),@"rect",nil];[AnnotationStore addAnnotation:a path:_pdfPath page:_currentPage];[_overlay reloadAnnotations];}
    else if(b==6){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"İmza" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=30;[a show];}
    else if(b==7)[self.navigationController pushViewController:[[[PageManagerViewController alloc] initWithPDFPath:_pdfPath] autorelease] animated:YES];
    else if(b==8){NSString *out=[[_pdfPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-annotated.pdf",[[_pdfPath lastPathComponent] stringByDeletingPathExtension]]];BOOL ok=[PDFAnnotationExporter exportFlattenedPDFAtPath:_pdfPath toPath:out];UIAlertView *a=[[[UIAlertView alloc] initWithTitle:ok?@"Hazır":@"Hata" message:ok?@"Yeni PDF oluşturuldu.":@"Dışa aktarılamadı." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];}
}
- (void)alertView:(UIAlertView *)a clickedButtonAtIndex:(NSInteger)b { if(a.tag==30&&b==1){NSString *txt=[[a textFieldAtIndex:0] text];NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:@"signature",@"type",txt?txt:@"",@"text",NSStringFromCGRect(CGRectMake(.55,.80,.35,.10)),@"rect",nil];[AnnotationStore addAnnotation:d path:_pdfPath page:_currentPage];[_overlay reloadAnnotations];} }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // iPad 1: hiçbir bitmap/page cache tutulmuyor.
    // Görünmeyen controller'lar sistem tarafından boşaltılabilsin.
    if(!self.view.window) {
        _pageView.pdfPage=NULL;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)s { return _pageView; }
- (void)dealloc { _scrollView.delegate=nil; [_pdfPath release]; [_scrollView release]; [_pageView release]; [_overlay release]; [_toolbar release]; [_pageLabel release]; [_previousButton release]; [_nextButton release]; [_bookmarkButton release]; if(_document)CGPDFDocumentRelease(_document); [super dealloc]; }
@end
