#import "PDFReaderViewController+Handoff.h"
#import "PDFPageView.h"
#import "AnnotationOverlayView.h"

@implementation PDFReaderViewController (Handoff)
- (void)prepareForExternalPDFHandoff {
    if(_scrollView) _scrollView.delegate=nil;
    if(_overlay) [_overlay clearTemporarySelection];
    if(_pageView) _pageView.pdfPage=NULL;

    if(_document){
        CGPDFDocumentRelease(_document);
        _document=NULL;
    }

    _pageCount=0;
    _currentPage=0;
    _sessionZoomScale=1.0f;
}
@end
