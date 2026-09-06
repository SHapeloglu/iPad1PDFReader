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
static const NSUInteger IPAD1_READING_HISTORY_LIMIT=20;
static const NSUInteger IPAD1_DIRECT_ANNOTATION_HIT_LIMIT=80;

@implementation PDFReaderViewController

- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _pdfPath=[path copy];
        _sessionZoomScale=1.0f;
        _editingAnnotationIndex=NSNotFound;
        _editingHighlightIndex=NSNotFound;
        _backHistory=[[NSMutableArray alloc] init];
        _forwardHistory=[[NSMutableArray alloc] init];
        _restoringHistory=NO;
        _pageLocked=NO;
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

    _edgeTapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgeTap:)];
    _edgeTapRecognizer.numberOfTapsRequired=1;
    [_edgeTapRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
    [_scrollView addGestureRecognizer:_edgeTapRecognizer];

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
    _pageLabel.text=[NSString stringWithFormat:@"%@%lu/%lu",_pageLocked?@"🔒 ":@"",(unsigned long)_currentPage,(unsigned long)_pageCount];
    _bookmarkButton.title=[BookmarkStore isBookmarkedPage:_currentPage forPath:_pdfPath]?@"★":@"☆";
    [self layoutPageBase];

    desiredZoom=MIN(_scrollView.maximumZoomScale,MAX(_scrollView.minimumZoomScale,desiredZoom));
    [_scrollView setZoomScale:desiredZoom animated:NO];
    _sessionZoomScale=desiredZoom;
    [self centerZoomedPage];
    [self restoreNormalizedViewportCenter:relative];
}

- (void)fitPage {
    if(_pageLocked)return;
    [_scrollView setZoomScale:1.0f animated:YES];
    _sessionZoomScale=1.0f;
    [self centerZoomedPage];
    _scrollView.contentOffset=CGPointZero;
}

- (void)fitWidth {
    if(_pageLocked||_pageView.bounds.size.width<=0||_scrollView.bounds.size.width<=0)return;
    CGFloat available=MAX(1.0f,_scrollView.bounds.size.width-20.0f);
    CGFloat target=available/_pageView.bounds.size.width;
    target=MIN(_scrollView.maximumZoomScale,MAX(_scrollView.minimumZoomScale,target));
    [_scrollView setZoomScale:target animated:YES];
    _sessionZoomScale=target;
    [self centerZoomedPage];
    CGPoint offset=_scrollView.contentOffset;
    offset.y=0.0f;
    _scrollView.contentOffset=offset;
}

- (void)trimReadingHistory:(NSMutableArray *)history {
    while([history count]>IPAD1_READING_HISTORY_LIMIT)[history removeObjectAtIndex:0];
}

- (void)navigateToPage:(NSUInteger)page recordHistory:(BOOL)record {
    if(page<1||page>_pageCount||page==_currentPage)return;
    if(record&&!_restoringHistory){
        [_backHistory addObject:[NSNumber numberWithUnsignedInteger:_currentPage]];
        [self trimReadingHistory:_backHistory];
        [_forwardHistory removeAllObjects];
    }
    _currentPage=page;
    [self displayCurrentPage];
}

- (void)previousPage { if(!_pageLocked&&_currentPage>1)[self navigateToPage:_currentPage-1 recordHistory:YES]; }
- (void)nextPage { if(!_pageLocked&&_currentPage<_pageCount)[self navigateToPage:_currentPage+1 recordHistory:YES]; }

- (void)goBackReadingLocation {
    if([_backHistory count]==0){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Konum Geri" message:@"Geri dönülecek okuma konumu yok." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
        [a show];
        return;
    }
    NSNumber *target=[[_backHistory lastObject] retain];
    [_backHistory removeLastObject];
    [_forwardHistory addObject:[NSNumber numberWithUnsignedInteger:_currentPage]];
    [self trimReadingHistory:_forwardHistory];
    _restoringHistory=YES;
    [self navigateToPage:[target unsignedIntegerValue] recordHistory:NO];
    _restoringHistory=NO;
    [target release];
}

- (void)goForwardReadingLocation {
    if([_forwardHistory count]==0){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Konum İleri" message:@"İleri gidilecek okuma konumu yok." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
        [a show];
        return;
    }
    NSNumber *target=[[_forwardHistory lastObject] retain];
    [_forwardHistory removeLastObject];
    [_backHistory addObject:[NSNumber numberWithUnsignedInteger:_currentPage]];
    [self trimReadingHistory:_backHistory];
    _restoringHistory=YES;
    [self navigateToPage:[target unsignedIntegerValue] recordHistory:NO];
    _restoringHistory=NO;
    [target release];
}

- (NSString *)displayNameForTextMarkType:(NSString *)type {
    if([type isEqualToString:@"underline"])return @"Altı Çizili";
    if([type isEqualToString:@"strikeout"])return @"Üstü Çizili";
    return @"Highlight";
}

- (BOOL)annotation:(NSDictionary *)a containsOverlayPoint:(CGPoint)p {
    NSString *type=[a objectForKey:@"type"];
    CGFloat w=_overlay.bounds.size.width,h=_overlay.bounds.size.height;
    if(w<=0||h<=0)return NO;
    NSArray *rects=[a objectForKey:@"rects"];
    if(([type isEqualToString:@"highlight"]||[type isEqualToString:@"underline"]||[type isEqualToString:@"strikeout"])&&[rects count]>0){
        NSUInteger count=MIN((NSUInteger)32,[rects count]);
        for(NSUInteger i=0;i<count;i++){
            CGRect n=CGRectFromString([rects objectAtIndex:i]);
            CGRect q=CGRectMake(n.origin.x*w,n.origin.y*h,n.size.width*w,n.size.height*h);
            if(CGRectContainsPoint(CGRectInset(q,-8.0f,-8.0f),p))return YES;
        }
        return NO;
    }
    NSString *rect=[a objectForKey:@"rect"];
    if([rect length]>0&&([type isEqualToString:@"highlight"]||[type isEqualToString:@"note"])){
        CGRect n=CGRectFromString(rect);
        CGRect q=CGRectMake(n.origin.x*w,n.origin.y*h,n.size.width*w,n.size.height*h);
        return CGRectContainsPoint(CGRectInset(q,-10.0f,-10.0f),p);
    }
    return NO;
}

- (void)presentNoteAtIndex:(NSUInteger)index {
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
    if(index>=[anns count])return;
    NSDictionary *d=[anns objectAtIndex:index];
    if(![[d objectForKey:@"type"] isEqualToString:@"note"])return;
    _editingAnnotationIndex=index;
    NSString *text=[d objectForKey:@"text"]?:@"";
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Not" message:text delegate:self cancelButtonTitle:@"Kapat" otherButtonTitles:@"Düzenle",@"Sil",nil] autorelease];
    a.tag=40;
    [a show];
}

- (void)presentTextMarkAtIndex:(NSUInteger)index {
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
    if(index>=[anns count])return;
    NSDictionary *d=[anns objectAtIndex:index];
    NSString *type=[d objectForKey:@"type"];
    if(![type isEqualToString:@"highlight"]&&![type isEqualToString:@"underline"]&&![type isEqualToString:@"strikeout"])return;
    _editingHighlightIndex=index;
    UIActionSheet *e=[[[UIActionSheet alloc] initWithTitle:[self displayNameForTextMarkType:type] delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:@"Sil" otherButtonTitles:@"Sarı",@"Yeşil",@"Pembe",@"Turuncu",@"Açık Mavi",nil] autorelease];
    e.tag=106;
    [e showFromToolbar:_toolbar];
}

- (BOOL)openAnnotationAtOverlayPoint:(CGPoint)p {
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
    NSUInteger count=MIN((NSUInteger)IPAD1_DIRECT_ANNOTATION_HIT_LIMIT,[anns count]);
    while(count>0){
        NSUInteger index=count-1;
        NSDictionary *a=[anns objectAtIndex:index];
        if([self annotation:a containsOverlayPoint:p]){
            NSString *type=[a objectForKey:@"type"];
            if([type isEqualToString:@"note"]){[self presentNoteAtIndex:index];return YES;}
            if([type isEqualToString:@"highlight"]||[type isEqualToString:@"underline"]||[type isEqualToString:@"strikeout"]){[self presentTextMarkAtIndex:index];return YES;}
        }
        count--;
    }
    return NO;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)g {
    if(_pageLocked||g.state!=UIGestureRecognizerStateRecognized)return;
    if(_scrollView.zoomScale>1.05f){[_scrollView setZoomScale:1.0f animated:YES];return;}
    CGFloat target=MIN(2.5f,_scrollView.maximumZoomScale);
    CGPoint p=[g locationInView:_pageView];
    CGSize b=_scrollView.bounds.size;
    CGRect rect=CGRectMake(p.x-b.width/(2.0f*target),p.y-b.height/(2.0f*target),b.width/target,b.height/target);
    [_scrollView zoomToRect:rect animated:YES];
}

- (void)handleEdgeTap:(UITapGestureRecognizer *)g {
    if(_pageLocked||g.state!=UIGestureRecognizerStateRecognized)return;
    if(_overlay.userInteractionEnabled)return;
    CGPoint annotationPoint=[g locationInView:_overlay];
    if(CGRectContainsPoint(_overlay.bounds,annotationPoint)&&[self openAnnotationAtOverlayPoint:annotationPoint])return;
    if(_scrollView.zoomScale>1.05f)return;
    CGPoint p=[g locationInView:_scrollView];
    CGFloat w=_scrollView.bounds.size.width;
    if(w<=0)return;
    if(p.x<=w*.18f)[self previousPage];
    else if(p.x>=w*.82f)[self nextPage];
}

- (void)setPageLocked:(BOOL)locked {
    _pageLocked=locked;
    [_overlay clearTemporarySelection];
    _overlay.drawingEnabled=NO;
    _scrollView.scrollEnabled=!locked;
    _doubleTapRecognizer.enabled=!locked;
    _edgeTapRecognizer.enabled=!locked;
    [self displayCurrentPage];
}

- (void)applyTheme:(PDFTheme)theme {
    [AppearanceStore setTheme:theme];
    _pageView.theme=theme;
    [_pageView setNeedsDisplay];
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
- (void)thumbnailControllerSelectedPage:(NSUInteger)p { [self navigateToPage:p recordHistory:YES]; }
- (void)searchControllerSelectedPage:(NSUInteger)p { [self navigateToPage:p recordHistory:YES]; }
- (void)outlineControllerSelectedPage:(NSUInteger)p { [self navigateToPage:p recordHistory:YES]; }
- (void)documentNavigatorSelectedPage:(NSUInteger)p { [self navigateToPage:p recordHistory:YES]; }

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

- (void)showCurrentPageHighlights {
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
    NSMutableArray *indexes=[NSMutableArray array];
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"İşaret Düzenle" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    s.tag=105;
    for(NSUInteger i=0;i<[anns count];i++){
        NSDictionary *a=[anns objectAtIndex:i];
        NSString *type=[a objectForKey:@"type"];
        if(![type isEqualToString:@"highlight"]&&![type isEqualToString:@"underline"]&&![type isEqualToString:@"strikeout"])continue;
        [indexes addObject:[NSNumber numberWithUnsignedInteger:i]];
        NSString *color=[a objectForKey:@"color"]?:@"yellow";
        [s addButtonWithTitle:[NSString stringWithFormat:@"%@ %lu — %@",[self displayNameForTextMarkType:type],(unsigned long)[indexes count],color]];
        if([indexes count]>=20)break;
    }
    if([indexes count]==0){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"İşaret Düzenle" message:@"Bu sayfada metin işareti yok." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];return;}
    [_highlightSheetIndexes release]; _highlightSheetIndexes=[indexes copy];
    [s addButtonWithTitle:@"İptal"];s.cancelButtonIndex=[s numberOfButtons]-1;[s showFromToolbar:_toolbar];
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

- (void)showTextMarkChoices {
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Metin İşaretle" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Highlight",@"Altını Çiz",@"Üstünü Çiz",nil] autorelease];
    s.tag=108;
    [s showFromToolbar:_toolbar];
}

- (void)showReadingOptions {
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Okuma Görünümü" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Gündüz",@"Sepya",@"Gece",@"Sayfaya Sığdır",@"Genişliğe Sığdır",_pageLocked?@"Sayfa Kilidini Aç":@"Sayfayı Kilitle",nil] autorelease];
    s.tag=107;
    [s showFromToolbar:_toolbar];
}

- (void)beginHighlightWithColor:(NSString *)color {
    if(!_document||_currentPage<1||_currentPage>_pageCount||_pageLocked)return;
    CGPDFPageRef page=CGPDFDocumentGetPage(_document,_currentPage);
    NSArray *rects=[PDFTextExtractor normalizedTextRectsForPage:page maxRects:160];
    _overlay.drawingEnabled=NO;
    _overlay.selectionAnnotationType=@"highlight";
    _overlay.highlightColorName=color?color:@"yellow";
    _overlay.pageTextRects=rects;
    [[NSUserDefaults standardUserDefaults] setObject:_overlay.highlightColorName forKey:LastHighlightColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _overlay.highlightSelectionEnabled=YES;

    NSString *message=([rects count]>0)?@"Metin üzerinde parmağınızı sürükleyin. Highlight aktif sayfadaki metin kutularına oturur.":@"Bu sayfada seçilebilir metin bulunamadı. Alan highlight modu kullanılacak; OCR çalıştırılmaz.";
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Highlight" message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)beginTextMarkWithType:(NSString *)type {
    if(!_document||_currentPage<1||_currentPage>_pageCount||_pageLocked)return;
    CGPDFPageRef page=CGPDFDocumentGetPage(_document,_currentPage);
    NSArray *rects=[PDFTextExtractor normalizedTextRectsForPage:page maxRects:160];
    if([rects count]==0){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:[self displayNameForTextMarkType:type] message:@"Bu işlem için seçilebilir metin katmanı gerekli. OCR çalıştırılmaz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
        [a show];
        return;
    }
    _overlay.drawingEnabled=NO;
    _overlay.selectionAnnotationType=type;
    NSString *saved=[[NSUserDefaults standardUserDefaults] stringForKey:LastHighlightColorKey];
    _overlay.highlightColorName=[saved length]>0?saved:@"yellow";
    _overlay.pageTextRects=rects;
    _overlay.highlightSelectionEnabled=YES;
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:[self displayNameForTextMarkType:type] message:@"İşaretlemek istediğiniz metnin üzerinde parmağınızı sürükleyin. Yalnız aktif sayfa geometrisi kullanılır." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)replaceEditingHighlightColor:(NSString *)color {
    if(_editingHighlightIndex==NSNotFound)return;
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_currentPage];
    if(_editingHighlightIndex>=[anns count]){_editingHighlightIndex=NSNotFound;return;}
    NSDictionary *old=[anns objectAtIndex:_editingHighlightIndex];
    NSString *type=[old objectForKey:@"type"];
    if(![type isEqualToString:@"highlight"]&&![type isEqualToString:@"underline"]&&![type isEqualToString:@"strikeout"]){_editingHighlightIndex=NSNotFound;return;}
    NSMutableDictionary *updated=[NSMutableDictionary dictionaryWithDictionary:old];
    [updated setObject:color?color:@"yellow" forKey:@"color"];
    [AnnotationStore replaceAnnotationAtIndex:_editingHighlightIndex withAnnotation:updated path:_pdfPath page:_currentPage];
    [[NSUserDefaults standardUserDefaults] setObject:color?color:@"yellow" forKey:LastHighlightColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _editingHighlightIndex=NSNotFound;
    [_overlay reloadAnnotations];
}

- (void)showTools {
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Araçlar" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:
                      @"Ara",@"Gezinti Merkezi",@"Reflow",@"İçindekiler",@"Sayfaya Git",@"Yer İmleri",@"Çizim Aç/Kapat",@"Metin İşaretle",@"İşaret Düzenle",@"Okuma Görünümü",@"Konum Geri",@"Konum İleri",@"Not Ekle",@"Sayfa Notları",@"İmza",@"Sayfa Yöneticisi",@"Annotation'lı PDF Dışa Aktar",nil] autorelease];
    s.tag=100; [s showFromToolbar:_toolbar];
}

- (void)actionSheet:(UIActionSheet *)s clickedButtonAtIndex:(NSInteger)b {
    if(s.tag==101){
        if(b>=0&&(NSUInteger)b<[_bookmarkSheetPages count]&&(NSUInteger)b<24){NSUInteger p=[[_bookmarkSheetPages objectAtIndex:(NSUInteger)b] unsignedIntegerValue];[self navigateToPage:p recordHistory:YES];}
        return;
    }
    if(s.tag==102){
        if(b>=0&&(NSUInteger)b<[_noteSheetIndexes count]){
            NSUInteger index=[[_noteSheetIndexes objectAtIndex:(NSUInteger)b] unsignedIntegerValue];
            [self presentNoteAtIndex:index];
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
    if(s.tag==105){
        if(b>=0&&(NSUInteger)b<[_highlightSheetIndexes count]){
            NSUInteger index=[[_highlightSheetIndexes objectAtIndex:(NSUInteger)b] unsignedIntegerValue];
            [self presentTextMarkAtIndex:index];
        }
        return;
    }
    if(s.tag==106){
        if(b==0&&_editingHighlightIndex!=NSNotFound){[AnnotationStore removeAnnotationAtIndex:_editingHighlightIndex path:_pdfPath page:_currentPage];_editingHighlightIndex=NSNotFound;[_overlay reloadAnnotations];}
        else if(b==1)[self replaceEditingHighlightColor:@"yellow"];
        else if(b==2)[self replaceEditingHighlightColor:@"green"];
        else if(b==3)[self replaceEditingHighlightColor:@"pink"];
        else if(b==4)[self replaceEditingHighlightColor:@"orange"];
        else if(b==5)[self replaceEditingHighlightColor:@"cyan"];
        return;
    }
    if(s.tag==107){
        if(b==0)[self applyTheme:PDFThemeNormal];
        else if(b==1)[self applyTheme:PDFThemeSepia];
        else if(b==2)[self applyTheme:PDFThemeNight];
        else if(b==3)[self fitPage];
        else if(b==4)[self fitWidth];
        else if(b==5)[self setPageLocked:!_pageLocked];
        return;
    }
    if(s.tag==108){
        if(b==0)[self showHighlightColors];
        else if(b==1)[self beginTextMarkWithType:@"underline"];
        else if(b==2)[self beginTextMarkWithType:@"strikeout"];
        return;
    }
    if(s.tag!=100)return;

    if(b==0){SearchViewController *v=[[[SearchViewController alloc] initWithPDFPath:_pdfPath] autorelease];v.delegate=self;[self.navigationController pushViewController:v animated:YES];}
    else if(b==1)[self showDocumentNavigator];
    else if(b==2)[self.navigationController pushViewController:[[[ReflowViewController alloc] initWithPDFPath:_pdfPath] autorelease] animated:YES];
    else if(b==3){OutlineViewController *v=[[[OutlineViewController alloc] initWithItems:[PDFOutlineParser outlineForDocument:_document]] autorelease];v.delegate=self;[self.navigationController pushViewController:v animated:YES];}
    else if(b==4){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Sayfaya Git" message:[NSString stringWithFormat:@"1 - %lu",(unsigned long)_pageCount] delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Git",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;[[a textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];a.tag=31;[a show];}
    else if(b==5)[self showBookmarks];
    else if(b==6){if(!_pageLocked){[_overlay clearTemporarySelection];_overlay.drawingEnabled=!_overlay.drawingEnabled;}}
    else if(b==7)[self showTextMarkChoices];
    else if(b==8)[self showCurrentPageHighlights];
    else if(b==9)[self showReadingOptions];
    else if(b==10)[self goBackReadingLocation];
    else if(b==11)[self goForwardReadingLocation];
    else if(b==12){if(!_pageLocked){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Sayfa Notu" message:@"Bu not yalnızca mevcut sayfaya bağlıdır." delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=32;[a show];}}
    else if(b==13)[self showPageNotes];
    else if(b==14){if(!_pageLocked){UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"İmza" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=30;[a show];}}
    else if(b==15)[self.navigationController pushViewController:[[[PageManagerViewController alloc] initWithPDFPath:_pdfPath] autorelease] animated:YES];
    else if(b==16){NSString *out=[[_pdfPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-annotated.pdf",[[_pdfPath lastPathComponent] stringByDeletingPathExtension]]];BOOL ok=[PDFAnnotationExporter exportFlattenedPDFAtPath:_pdfPath toPath:out];UIAlertView *a=[[[UIAlertView alloc] initWithTitle:ok?@"Hazır":@"Hata" message:ok?@"Yeni PDF oluşturuldu.":@"Dışa aktarılamadı." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];}
}

- (void)alertView:(UIAlertView *)a clickedButtonAtIndex:(NSInteger)b {
    if(a.tag==30&&b==1){
        NSString *txt=[[a textFieldAtIndex:0] text];
        NSDictionary *d=[NSDictionary dictionaryWithObjectsAndKeys:@"signature",@"type",txt?txt:@"",@"text",NSStringFromCGRect(CGRectMake(.55,.80,.35,.10)),@"rect",nil];
        [AnnotationStore addAnnotation:d path:_pdfPath page:_currentPage];[_overlay reloadAnnotations];
    }
    else if(a.tag==31&&b==1){
        NSInteger p=[[[a textFieldAtIndex:0] text] integerValue];
        if(p>=1&&(NSUInteger)p<=_pageCount)[self navigateToPage:(NSUInteger)p recordHistory:YES];
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
    [_highlightSheetIndexes release]; _highlightSheetIndexes=nil;
    [_overlay clearTemporarySelection];
    if(!self.view.window)_pageView.pdfPage=NULL;
}

- (void)dealloc {
    _scrollView.delegate=nil;
    [_overlay clearTemporarySelection];
    [_pdfPath release];
    [_bookmarkSheetPages release];
    [_noteSheetIndexes release];
    [_highlightSheetIndexes release];
    [_doubleTapRecognizer release];
    [_edgeTapRecognizer release];
    [_backHistory release];
    [_forwardHistory release];
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
