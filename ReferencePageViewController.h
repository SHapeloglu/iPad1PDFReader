#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@class PDFPageView;

@interface ReferencePageViewController : UIViewController {
    CGPDFPageRef _page;
    NSUInteger _pageNumber;
    PDFPageView *_pageView;
    UILabel *_titleLabel;
}
- (id)initWithPDFPage:(CGPDFPageRef)page pageNumber:(NSUInteger)pageNumber;
@end
