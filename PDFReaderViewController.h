#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ThumbnailViewController.h"
#import "SearchViewController.h"
@class PDFPageView,AnnotationOverlayView;
@interface PDFReaderViewController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate,ThumbnailViewControllerDelegate,SearchViewControllerDelegate,UIAlertViewDelegate> {
    NSString *_pdfPath; CGPDFDocumentRef _document; NSUInteger _currentPage,_pageCount;
    UIScrollView *_scrollView; PDFPageView *_pageView; AnnotationOverlayView *_overlay;
    UIToolbar *_toolbar; UILabel *_pageLabel; UIBarButtonItem *_previousButton,*_nextButton,*_bookmarkButton;
    CGFloat _sessionZoomScale;
    NSArray *_bookmarkSheetPages;
    NSArray *_noteSheetIndexes;
    NSUInteger _editingAnnotationIndex;
    UITapGestureRecognizer *_doubleTapRecognizer;
}
- (id)initWithPDFPath:(NSString *)path;
@end
