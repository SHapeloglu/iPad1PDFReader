#import "PDFReaderViewController.h"
#import "PDFPageView.h"
#import "BookmarkStore.h"
#import "AppearanceStore.h"
#import "AnnotationOverlayView.h"
#import "AnnotationStore.h"
#import "PDFTextExtractor.h"
#import "ReflowViewController.h"
#import "PageManagerViewController.h"
#import "PDFAnnotationExporter.h"
#import "PDFOutlineParser.h"

static NSString * const LastHighlightColorKey=@"LastHighlightColor";

@implementation PDFReaderViewController

- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _pdfPath=[path copy];
        _sessionZoomScale=1.0f;
        _editingAnnotationIndex=NSNotFound;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=[[_pdfPath lastPathComponent] stringByDeletingPathExtension];
    self.view.backgroundColor=[UIColor darkGrayColor];

    _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_pdfPath]);
    if(!_document){
        UIAlertView *e=[[[UIAlertView alloc] initWithTitle:@"PDF açılamadı" message:nil delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
        [e show];
        return;
    }

    _pageCount=CGPDFDocumentGetNumberOfPages(_document);
    _currentPage=[BookmarkStore lastPageForPath:_pdfPath];
    if(_currentPage<1||_currentPage>_pageCount)_currentPage=1;

    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.delegate=self;
    _scrollView.minimumZoomScale=1.0f;
    _scrollView.maximumZoomScale=5.0f;
    _scrollView.backgroundColor=[UIColor darkGrayColor];
    [self.view addSubview:_scrollView];

    _pageView=[[PDFPageView alloc] initWithFrame:CGRectZero];
    _pageView.theme=[AppearanceStore theme];
    [_scrollView addSubview:_pageView];

    _overlay=[[AnnotationOverlayView alloc] initWithFrame:CGRectZero];
    _overlay.pdfPath=_pdfPath;
    NSString *savedColor=[[NSUserDefaults standardUserDefaults] stringForKey:LastHighlightColorKey];
    if([savedColor length]>0)_overlay.highlightColorName=savedColor;
    [_pageView addSubview:_overlay];

    _doubleTapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    _doubleTapRecognizer.numberOfTapsRequired=2;
    [_scrollView addGestureRecognizer:_doubleTapRecognizer];

    _toolbar=[[UIToolbar alloc] initWithFrame:CGRectZero];
    _previousButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previousPage)];
    _nextButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextPage)];
    _bookmarkButton=[[UIBarButtonItem alloc] initWithTitle:@"☆" style:UIBarButtonItemStylePlain target:self action:@selector(toggleBookmark)];
    UIBarButtonItem *thumb=[[[UIBarButtonItem alloc] initWithTitle:@"Sayfalar" style:UIBarButtonItemStylePlain target:self action:@selector(showThumbs)] autorelease];
    UIBarButtonItem *tools=[[[UIBarButtonItem alloc] initWithTitle:@"Araçlar" style:UIBarButtonItemStylePlain target:self action:@selector(showTools)] autorelease];
    _pageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,95,30)];
    _pageLabel.textAlignment=UITextAlignmentCenter;
    _pageLabel.backgroundColor=[UIColor clearColor];
    UIBarButtonItem *pi=[[[UIBarButtonItem alloc] initWithCustomView:_pageLabel] autorelease];
    _toolbar.items=[NSArray arrayWithObjects:_previousButton,pi,_nextButton,_bookmarkButton,thumb,tools,nil];
    [self.view addSubview:_toolbar];

    [self displayCurrentPage];
}

- (CGPoint)normalizedViewportCenter {
    CGSize content=_scrollView.contentSize;
    if(content.width<=0||content.height<=0)return CGPointMake(.5f,.5f);
    CGPoint c=CGPointMake(_scrollView.contentOffset.x+_scrollView.bounds.size.width*.5f,
                          _scrollView.contentOffset.y+_scrollView.bounds.size.height*.5f);
    return CGPointMake(MIN(1.0f,MAX(0.0f,c.x/content.width)),MIN(1.0f,MAX(0.0f,c.y/content.height)));
}

- (void)centerZoomedPage {
    CGSize bounds=_scrollView.bounds.size;
    CGSize content=_scrollView.contentSize;
    CGFloat offsetX=(bounds.width>content.width)?(bounds.width-content.width)*.5f:0.0f;
    CGFloat offsetY=(bounds.height>content.height)?(bounds.height-content.height)*.5f:0.0f;
    _pageView.center=CGPointMake(content.width*.5f+offsetX,content.height*.5f+offsetY);
}

- (void)restoreNormalizedViewportCenter:(CGPoint)relative {
    CGSize content=_scrollView.contentSize;
    CGSize bounds=_scrollView.bounds.size;
    CGFloat x=content.width*relative.x-bounds.width*.5f;
    CGFloat y=content.height*relative.y-bounds.height*.5f;
    CGFloat maxX=MAX(0.0f,content.width-bounds.width);
    CGFloat maxY=MAX(0.0f,content.height-bounds.height);
    x=MIN(maxX,MAX(0.0f,x));
    y=MIN(maxY,MAX(0.0f,y));
    _scrollView.contentOffset=CGPointMake(x,y);
}

- (void)layoutPageBase {
    if(!_document||!_pageCount||_scrollView.bounds.size.width<=0||_scrollView.bounds.size.height<=0)return;
    CGPDFPageRef p=CGPDFDocumentGetPage(_document,_currentPage);
    CGRect box=CGPDFPageGetBoxRect(p,kCGPDFMediaBox);
    CGFloat w=box.size.width,h=box.size.height;
    int r=CGPDFPageGetRotationAngle(p);
    if(r==90||r==270){CGFloat q=w;w=h;h=q;}
    CGFloat aw=MAX(1.0f,_scrollView.bounds.size.width-20.0f);
    CGFloat ah=MAX(1.0f,_scrollView.bounds.size.height-20.0f);
    CGFloat s=MIN(aw/w,ah/h);
    CGSize z=CGSizeMake(floor(w*s),floor(h*s));
    _pageView.frame=CGRectMake(0,0,z.width,z.height);
    _overlay.frame=_pageView.bounds;
    _scrollView.contentSize=z;
    [self centerZoomedPage];
}

- (void)relayoutPreservingZoom {
    CGFloat zoom=_scrollView.zoomScale;
    if(zoom<1.0f)zoom=1.0f;
    CGPoint relative=[self normalizedViewportCenter];
    [_scrollView setZoomScale:1.0f animated:NO];
    [self layoutPageBase];
    [_scrollView setZoomScale:MIN(_scrollView.maximumZoomScale,zoom) animated:NO];
    [self centerZoomedPage];
    [self restoreNormalizedViewportCenter:relative];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat h=44.0f;
    CGRect b=self.view.bounds;
    _toolbar.frame=CGRectMake(0,b.size.height-h,b.size.width,h);
    _scrollView.frame=CGRectMake(0,0,b.size.width,b.size.height-h);
    [self relayoutPreservingZoom];
}

- (void)displayCurrentPage {
    CGFloat desiredZoom=_scrollView.zoomScale;
    if(desiredZoom<1.0f)desiredZoom=_sessionZoomScale;
    if(desiredZoom<1.0f)desiredZoom=1.0f;
    CGPoint relative=[self normalizedViewportCenter];

    [_overlay clearTemporarySelection];
    [_scrollView setZoomScale:1.0f animated:NO];
    [_pageView setPDFPage:CGPDFDocumentGetPage(_document,_currentPage)];
    [BookmarkStore setLastPage:_currentPage forPath:_pdfPath];
    _overlay.page=_currentPage;
    [_overlay reloadAnnotations];
    _pageLabel.text=[NSString stringWithFormat:@"%lu/%lu",(unsigned long)_currentPage,(unsigned long)_pageCount];
    _bookmarkButton.title=[BookmarkStore isBookmarkedPage:_currentPage forPath:_pdfPath]?@"★":@"☆";
    [self layoutPageBase];

    desiredZoom=MIN(_scrollView.maximumZoomScale,MAX(_scrollView.minimumZoomScale,desiredZoom));
    [_scrollView setZoomScale:desiredZoom animated:NO];
    _sessionZoomScale=desiredZoom;
    [self centerZoomedPage];
    [self restoreNormalizedViewportCenter:relative];
}

- (void)previousPage { if(_currentPage>1){_currentPage--;[self displayCurrentPage];} }
- (void)nextPage { if(_currentPage<_pageCount){_currentPage++;[self displayCurrentPage];} }

- (void)handleDoubleTap:(UITapGestureRecognizer *)g {
    if(g.state!=UIGestureRecognizerStateRecognized)return;
    if(_scrollView.zoomScale>1.05f){[_scrollView setZoomScale:1.0f animated:YES];return;}
    CGFloat target=MIN(2.5f,_scrollView.maximumZoomScale);
    CGPoint p=[g locationInView:_pageView];
    CGSize b=_scrollView.bounds.size;
    CGRect rect=CGRectMake(p.x-b.width/(2.0f*target),p.y-b.height/(2.0f*target),b.width/target,b.height/target);
    [_scrollView zoomToRect:rect animated:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView { _sessionZoomScale=scrollView.zoomScale; [self centerZoomedPage]; }
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale { _sessionZoomScale=scale; [self centerZoomedPage]; }
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)s { return _pageView; }

- (void)toggleBookmark {
    [BookmarkStore toggleBookmarkForPage:_currentPage forPath:_pdfPath];
    _bookmarkButton.title=[BookmarkStore isBookmarkedPage:_currentPage forPath:_pdfPath]?@"★":@"☆";
}

- (void)showThumbs {
    ThumbnailViewController *v=[[[ThumbnailViewController alloc] initWithPDFPath:_pdfPath] autorelease];
    v.delegate=self;
    [self.navigationController pushViewController:v animated:YES];
}
- (void)thumbnailControllerSelectedPage:(NSUInteger)p { if(p>=1&&p<=_pageCount){_currentPage=p;[self displayCurrentPage];} }
- (void)searchControllerSelectedPage:(NSUInteger)p { if(p>=1&&p<=_pageCount){_currentPage=p;[self displayCurrentPage];} }
- (void)outlineControllerSelectedPage:(NSUInteger)p { if(p>=1&&p<=_pageCount){_currentPage=p;[self displayCurrentPage];} }
- (void)documentNavigatorSelectedPage:(NSUInteger)p { if(p>=1&&p<=_pageCount){_currentPage=p;[self displayCurrentPage];} }

- (void)showBookmarks {
    [_bookmarkSheetPages release];
    _bookmarkSheetPages=[[BookmarkStore bookmarksForPath:_pdfPath] copy];
    if([_bookmarkSheetPages count]==0){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Yer İmleri" message:@"Henüz yer imi yok." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];return;
    }
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Yer İmleri" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    s.tag=101;
    NSUInteger count=MIN((NSUInteger)24,[_bookmarkSheetPages count]);
    for(NSUInteger i=0;i<count;i++) [s addButtonWithTitle:[NSString stringWithFormat:@"Sayfa %@",[_bookmarkSheetPages objectAtIndex:i]]];
    [s addButtonWithTitle:@"İptal"]; s.cancelButtonIndex=[s numberOfButtons]-1; [s showFromToolbar:_toolbar];
}

- (void)showPageNotes {
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
    NSMutableArray *indexes=[NSMutableArray array];
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Sayfa Notları" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    s.tag=102;
    for(NSUInteger i=0;i<[anns count];i++){
        NSDictionary *a=[anns objectAtIndex:i];
        if(![[a objectForKey:@"type"] isEqualToString:@"note"])continue;
        [indexes addObject:[NSNumber numberWithUnsignedInteger:i]];
        NSString *text=[a objectForKey:@"text"];
        if(!text||[text length]==0)text=@"(boş not)";
        if([text length]>36)text=[NSString stringWithFormat:@"%@…",[text substringToIndex:36]];
        [s addButtonWithTitle:text];
        if([indexes count]>=20)break;
    }
    if([indexes count]==0){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Sayfa Notları" message:@"Bu sayfada not yok." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];return;}
    [_noteSheetIndexes release]; _noteSheetIndexes=[indexes copy];
    [s addButtonWithTitle:@"İptal"]; s.cancelButtonIndex=[s numberOfButtons]-1; [s showFromToolbar:_toolbar];
}

- (void)showDocumentNavigator {
    DocumentNavigatorViewController *v=[[[DocumentNavigatorViewController alloc] initWithPDFPath:_pdfPath pageCount:_pageCount] autorelease];
    v.delegate=self;
    [self.navigationController pushViewController:v animated:YES];
}

- (void)showHighlightColors {
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Fosfor Rengi" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Sarı",@"Yeşil",@"Pembe",@"Turuncu",@"Açık Mavi",nil] autorelease];
    s.tag=103;
    [s showFromToolbar:_toolbar];
}

- (void)beginHighlightWithColor:(NSString *)color {
    if(!_document||_currentPage<1||_currentPage>_pageCount)return;
    CGPDFPageRef page=CGPDFDocumentGetPage(_document,_currentPage);
    NSArray *rects=[PDFTextExtractor normalizedTextRectsForPage:page maxRects:160];
    _overlay.drawingEnabled=NO;
    _overlay.highlightColorName=color?color:@"yellow";
    _overlay.pageTextRects=rects;
    [[NSUserDefaults standardUserDefaults] setObject:_overlay.highlightColorName forKey:LastHighlightColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _overlay.highlightSelectionEnabled=YES;

    NSString *message=([rects count]>0)?@"Metin üzerinde parmağınızı sürükleyin. Highlight aktif sayfadaki metin kutularına oturur.":@"Bu sayfada seçilebilir metin bulunamadı. Alan highlight modu kullanılacak; OCR çalıştırılmaz.";
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Highlight" message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)showTools {
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Araçlar" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:
                      @"Ara",@"Belge Gezgini",@"Reflow",@"İçindekiler",@"Sayfaya Git",@"Yer İmleri",@"Çizim Aç/Kapat",@"Highlight Seç",@"Not Ekle",@"Sayfa Notları",@"İmza",@"Sayfa Yöneticisi",@"Annotation'lı PDF Dışa Aktar",nil] autorelease];
    s.tag=100; [s showFromToolbar:_toolbar];
}

- (void)actionSheet:(UIActionSheet *)s clickedButtonAtIndex:(NSInteger)b {
    if(s.tag==101){
        if(b>=0&&(NSUInteger)b<[_bookmarkSheetPages count]&&(NSUInteger)b<24){NSUInteger p=[[_bookmarkSheetPages objectAtIndex:(NSUInteger)b] unsignedIntegerValue];if(p>=1&&p<=_pageCount){_currentPage=p;[self displayCurrentPage];}}
        return;
    }
    if(s.tag==102){
        if(b>=0&&(NSUInteger)b<[_noteSheetIndexes count]){
            _editingAnnotationIndex=[[_noteSheetIndexes objectAtIndex:(NSUInteger)b] unsignedIntegerValue];
            NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
            if(_editingAnnotationIndex<[anns count]){
                NSDictionary *d=[anns objectAtIndex:_editingAnnotationIndex];
                NSString *text=[d objectForKey:@"text"]?:@"";
                UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Not" message:text delegate:self cancelButtonTitle:@"Kapat" otherButtonTitles:@"Düzenle",@"Sil",nil] autorelease];a.tag=40;[a show];
            }
        }
        return;
    }
    if(s.tag==103){
        if(b==0)[self beginHighlightWithColor:@"yellow"];
        else if(b==1)[self beginHighlightWithColor:@"green"];
        else if(b==2)[self beginHighlightWithColor:@"pink"];
        else if(b==3)[self beginHighlightWithColor:@"orange"];
        else if(b==4)[self beginHighlightWithColor:@"cyan"];
        return;
    }
    if(s.tag!=100)return;

    if(b==0){SearchViewController *v=[[[SearchViewController alloc] initWithPDFPath:_pdfPath] autorelease];v.delegate=self;[self.navigationController pushViewController:v animated:YES];}
    else if(b==1)[self showDocumentNavigator];
    else if(b==2)[self.navigationController pushViewController:[[[ReflowViewController alloc] initWithPDFPath:_pdfPath] autorelease] animated:YES];
    else if(b==3){OutlineViewController *v=[[[OutlineViewController alloc] initWithItems:[PDFOutlineParser outlineForDocument:_document]] autorelease];v.delegate=self;[self.navigationController pushViewController:v animated:YES];}
    else if(b==4){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Sayfaya Git" message:[NSString stringWithFormat:@"1 - %lu",(unsigned long)_pageCount] delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Git",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;[[a textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];a.tag=31;[a show];}
    else if(b==5)[self showBookmarks];
    else if(b==6){[_overlay clearTemporarySelection];_overlay.drawingEnabled=!_overlay.drawingEnabled;}
    else if(b==7)[self showHighlightColors];
    else if(b==8){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Sayfa Notu" message:@"Bu not yalnızca mevcut sayfaya bağlıdır." delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=32;[a show];}
    else if(b==9)[self showPageNotes];
    else if(b==10){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"İmza" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=30;[a show];}
    else if(b==11)[self.navigationController pushViewController:[[[PageManagerViewController alloc] initWithPDFPath:_pdfPath] autorelease] animated:YES];
    else if(b==12){NSString *out=[[_pdfPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-annotated.pdf",[[_pdfPath lastPathComponent] stringByDeletingPathExtension]]];BOOL ok=[PDFAnnotationExporter exportFlattenedPDFAtPath:_pdfPath toPath:out];UIAlertView *a=[[[UIAlertView alloc] initWithTitle:ok?@"Hazır":@"Hata" message:ok?@"Yeni PDF oluşturuldu.":@"Dışa aktarılamadı." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];}
}

- (void)alertView:(UIAlertView *)a clickedButtonAtIndex:(NSInteger)b {
    if(a.tag==30&&b==1){
        NSString *txt=[[a textFieldAtIndex:0] text];
        NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:@"signature",@"type",txt?txt:@"",@"text",NSStringFromCGRect(CGRectMake(.55,.80,.35,.10)),@"rect",nil];
        [AnnotationStore addAnnotation:d path:_pdfPath page:_currentPage];[_overlay reloadAnnotations];
    }
    else if(a.tag==31&&b==1){
        NSInteger p=[[[a textFieldAtIndex:0] text] integerValue];
        if(p>=1&&(NSUInteger)p<=_pageCount){_currentPage=(NSUInteger)p;[self displayCurrentPage];}
        else {UIAlertView *e=[[[UIAlertView alloc] initWithTitle:@"Geçersiz Sayfa" message:[NSString stringWithFormat:@"1 ile %lu arasında bir sayfa girin.",(unsigned long)_pageCount] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[e show];}
    }
    else if(a.tag==32&&b==1){
        NSString *txt=[[a textFieldAtIndex:0] text];
        if([txt length]>0){NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:@"note",@"type",txt,@"text",NSStringFromCGRect(CGRectMake(.05,.05,.04,.04)),@"rect",nil];[AnnotationStore addAnnotation:d path:_pdfPath page:_currentPage];[_overlay reloadAnnotations];}
    }
    else if(a.tag==40){
        if(b==1){
            NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
            if(_editingAnnotationIndex<[anns count]){
                NSDictionary *d=[anns objectAtIndex:_editingAnnotationIndex];
                UIAlertView *e=[[[UIAlertView alloc] initWithTitle:@"Notu Düzenle" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Kaydet",nil] autorelease];
                e.alertViewStyle=UIAlertViewStylePlainTextInput; [e textFieldAtIndex:0].text=[d objectForKey:@"text"]?:@""; e.tag=41; [e show];
            }
        } else if(b==2&&_editingAnnotationIndex!=NSNotFound){
            [AnnotationStore removeAnnotationAtIndex:_editingAnnotationIndex path:_pdfPath page:_currentPage]; _editingAnnotationIndex=NSNotFound; [_overlay reloadAnnotations];
        }
    }
    else if(a.tag==41&&b==1&&_editingAnnotationIndex!=NSNotFound){
        NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
        if(_editingAnnotationIndex<[anns count]){
            NSDictionary *old=[anns objectAtIndex:_editingAnnotationIndex];
            NSString *txt=[[a textFieldAtIndex:0] text]?:@"";
            NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:@"note",@"type",txt,@"text",[old objectForKey:@"rect"]?:NSStringFromCGRect(CGRectMake(.05,.05,.04,.04)),@"rect",nil];
            [AnnotationStore replaceAnnotationAtIndex:_editingAnnotationIndex withAnnotation:d path:_pdfPath page:_currentPage]; [_overlay reloadAnnotations];
        }
        _editingAnnotationIndex=NSNotFound;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_bookmarkSheetPages release]; _bookmarkSheetPages=nil;
    [_noteSheetIndexes release]; _noteSheetIndexes=nil;
    [_overlay clearTemporarySelection];
    if(!self.view.window)_pageView.pdfPage=NULL;
}

- (void)dealloc {
    _scrollView.delegate=nil;
    [_overlay clearTemporarySelection];
    [_pdfPath release];
    [_bookmarkSheetPages release];
    [_noteSheetIndexes release];
    [_doubleTapRecognizer release];
    [_scrollView release];
    [_pageView release];
    [_overlay release];
    [_toolbar release];
    [_pageLabel release];
    [_previousButton release];
    [_nextButton release];
    [_bookmarkButton release];
    if(_document)CGPDFDocumentRelease(_document);
    [super dealloc];
}
@end
