#import "PDFAnnotationExporter.h"
#import "AnnotationStore.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@implementation PDFAnnotationExporter
+ (BOOL)exportFlattenedPDFAtPath:(NSString *)path toPath:(NSString *)outPath {
    CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]); if(!d)return NO;
    CGContextRef c=CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:outPath],NULL,NULL); if(!c){CGPDFDocumentRelease(d);return NO;}
    size_t count=CGPDFDocumentGetNumberOfPages(d);
    for(size_t i=1;i<=count;i++){ CGPDFPageRef p=CGPDFDocumentGetPage(d,i); CGRect box=CGPDFPageGetBoxRect(p,kCGPDFMediaBox); CGPDFContextBeginPage(c,NULL); CGContextDrawPDFPage(c,p);
        for(NSDictionary *a in [AnnotationStore annotationsForPath:path page:i]){ NSString *type=[a objectForKey:@"type"]; if([type isEqualToString:@"highlight"]){CGRect r=CGRectFromString([a objectForKey:@"rect"]);CGRect q=CGRectMake(r.origin.x*box.size.width,r.origin.y*box.size.height,r.size.width*box.size.width,r.size.height*box.size.height);CGContextSetRGBFillColor(c,1,1,0,.35);CGContextFillRect(c,q);} else if([type isEqualToString:@"draw"]){NSArray *pts=[a objectForKey:@"points"];CGContextSetRGBStrokeColor(c,0,0,1,.9);CGContextSetLineWidth(c,2);for(NSUInteger k=0;k<[pts count];k++){CGPoint pt=CGPointFromString([pts objectAtIndex:k]);CGFloat x=pt.x*box.size.width,y=pt.y*box.size.height;if(k==0)CGContextMoveToPoint(c,x,y);else CGContextAddLineToPoint(c,x,y);}CGContextStrokePath(c);} }
        CGPDFContextEndPage(c);
    }
    CGPDFContextClose(c); CGContextRelease(c); CGPDFDocumentRelease(d); return YES;
}
@end
