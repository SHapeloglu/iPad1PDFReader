#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AppearanceStore.h"
@interface PDFPageView : UIView { CGPDFPageRef _pdfPage; PDFTheme _theme; }
@property(nonatomic,assign) CGPDFPageRef pdfPage;
@property(nonatomic,assign) PDFTheme theme;
- (void)setPDFPage:(CGPDFPageRef)p;
@end
