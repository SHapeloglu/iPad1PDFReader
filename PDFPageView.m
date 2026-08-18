#import "PDFPageView.h"
#import <QuartzCore/QuartzCore.h>
@implementation PDFPageView
@synthesize pdfPage=_pdfPage,theme=_theme;
- (id)initWithFrame:(CGRect)f { if((self=[super initWithFrame:f])){self.backgroundColor=[UIColor whiteColor];self.opaque=YES;self.contentMode=UIViewContentModeRedraw;} return self; }
- (void)setPDFPage:(CGPDFPageRef)p { if(_pdfPage==p)return; if(_pdfPage){CGPDFPageRelease(_pdfPage);_pdfPage=NULL;} if(p)_pdfPage=CGPDFPageRetain(p); [self setNeedsDisplay]; }
- (void)setTheme:(PDFTheme)t { _theme=t; [self setNeedsDisplay]; }
- (void)drawRect:(CGRect)r { CGContextRef c=UIGraphicsGetCurrentContext(); if(_theme==PDFThemeSepia)CGContextSetRGBFillColor(c,.96,.90,.76,1); else if(_theme==PDFThemeNight)CGContextSetRGBFillColor(c,.10,.10,.10,1); else CGContextSetRGBFillColor(c,1,1,1,1); CGContextFillRect(c,self.bounds); if(!_pdfPage)return; CGContextSaveGState(c); if(_theme==PDFThemeNight)CGContextSetBlendMode(c,kCGBlendModeScreen); CGContextTranslateCTM(c,0,self.bounds.size.height); CGContextScaleCTM(c,1,-1); CGContextConcatCTM(c,CGPDFPageGetDrawingTransform(_pdfPage,kCGPDFMediaBox,self.bounds,0,true)); CGContextDrawPDFPage(c,_pdfPage); CGContextRestoreGState(c); if(_theme==PDFThemeSepia){CGContextSetRGBFillColor(c,.55,.35,.1,.08);CGContextFillRect(c,self.bounds);} }
- (void)dealloc { if(_pdfPage)CGPDFPageRelease(_pdfPage); [super dealloc]; }
@end
