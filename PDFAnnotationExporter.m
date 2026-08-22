#import "PDFAnnotationExporter.h"
#import "AnnotationStore.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

static void SetExportHighlightFill(CGContextRef c, NSString *name) {
    if([name isEqualToString:@"green"]) CGContextSetRGBFillColor(c,.35f,1.0f,.30f,.34f);
    else if([name isEqualToString:@"pink"]) CGContextSetRGBFillColor(c,1.0f,.35f,.70f,.34f);
    else if([name isEqualToString:@"orange"]) CGContextSetRGBFillColor(c,1.0f,.62f,.18f,.34f);
    else if([name isEqualToString:@"cyan"]) CGContextSetRGBFillColor(c,.25f,.90f,1.0f,.34f);
    else CGContextSetRGBFillColor(c,1.0f,1.0f,.10f,.34f);
}

static CGRect PDFRectFromNormalizedOverlayRect(CGRect r, CGRect box) {
    CGFloat x=box.origin.x+r.origin.x*box.size.width;
    CGFloat y=box.origin.y+(1.0f-r.origin.y-r.size.height)*box.size.height;
    CGFloat w=r.size.width*box.size.width;
    CGFloat h=r.size.height*box.size.height;
    return CGRectMake(x,y,w,h);
}

static void DrawHighlightAnnotation(CGContextRef c, NSDictionary *a, CGRect box) {
    SetExportHighlightFill(c,[a objectForKey:@"color"]);
    NSArray *rects=[a objectForKey:@"rects"];
    if([rects count]>0){
        NSUInteger count=MIN((NSUInteger)32,[rects count]);
        for(NSUInteger i=0;i<count;i++){
            CGRect r=CGRectFromString([rects objectAtIndex:i]);
            CGContextFillRect(c,PDFRectFromNormalizedOverlayRect(r,box));
        }
        return;
    }
    NSString *legacy=[a objectForKey:@"rect"];
    if([legacy length]>0){
        CGRect r=CGRectFromString(legacy);
        CGContextFillRect(c,PDFRectFromNormalizedOverlayRect(r,box));
    }
}

@implementation PDFAnnotationExporter
+ (BOOL)exportFlattenedPDFAtPath:(NSString *)path toPath:(NSString *)outPath {
    CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]); if(!d)return NO;
    CGContextRef c=CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:outPath],NULL,NULL); if(!c){CGPDFDocumentRelease(d);return NO;}
    size_t count=CGPDFDocumentGetNumberOfPages(d);
    for(size_t i=1;i<=count;i++){ CGPDFPageRef p=CGPDFDocumentGetPage(d,i); CGRect box=CGPDFPageGetBoxRect(p,kCGPDFMediaBox); CGPDFContextBeginPage(c,NULL); CGContextDrawPDFPage(c,p);
        for(NSDictionary *a in [AnnotationStore annotationsForPath:path page:i]){ NSString *type=[a objectForKey:@"type"]; if([type isEqualToString:@"highlight"]){DrawHighlightAnnotation(c,a,box);} else if([type isEqualToString:@"draw"]){NSArray *pts=[a objectForKey:@"points"];CGContextSetRGBStrokeColor(c,0,0,1,.9);CGContextSetLineWidth(c,2);for(NSUInteger k=0;k<[pts count];k++){CGPoint pt=CGPointFromString([pts objectAtIndex:k]);CGFloat x=pt.x*box.size.width,y=pt.y*box.size.height;if(k==0)CGContextMoveToPoint(c,x,y);else CGContextAddLineToPoint(c,x,y);}CGContextStrokePath(c);} }
        CGPDFContextEndPage(c);
    }
    CGPDFContextClose(c); CGContextRelease(c); CGPDFDocumentRelease(d); return YES;
}
@end
