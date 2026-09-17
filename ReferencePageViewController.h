#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@class PDFPageView;

@interface ReferencePageViewController : UIViewController {
    NSString *_pdfPath;
    CGPDFDocumentRef _document;
    CGPDFPageRef _page;
    NSUInteger _pageNumber;
    PDFPageView *_pageView;
    UILabel *_titleLabel;
}
- (id)initWithPDFPath:(NSString *)path pageNumber:(NSUInteger)pageNumber;
@end
