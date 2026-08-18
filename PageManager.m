#import "PageManager.h"
#import <CoreGraphics/CoreGraphics.h>
@implementation PageManager
+ (BOOL)exportDocumentAtPath:(NSString *)path pageOrder:(NSArray *)pages rotations:(NSDictionary *)rotations toPath:(NSString *)outPath {
    CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]); if(!d)return NO;
    CGContextRef c=CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:outPath],NULL,NULL); if(!c){CGPDFDocumentRelease(d);return NO;}
    for(NSNumber *n in pages){ size_t idx=[n unsignedIntegerValue]; if(idx<1||idx>CGPDFDocumentGetNumberOfPages(d))continue; CGPDFPageRef p=CGPDFDocumentGetPage(d,idx); CGPDFContextBeginPage(c,NULL); NSInteger r=[[rotations objectForKey:n] integerValue]; CGContextSaveGState(c); if(r){ CGRect b=CGPDFPageGetBoxRect(p,kCGPDFMediaBox); if(r==90){CGContextTranslateCTM(c,b.size.width,0);CGContextRotateCTM(c,M_PI_2);} else if(r==180){CGContextTranslateCTM(c,b.size.width,b.size.height);CGContextRotateCTM(c,M_PI);} else if(r==270){CGContextTranslateCTM(c,0,b.size.height);CGContextRotateCTM(c,-M_PI_2);} } CGContextDrawPDFPage(c,p); CGContextRestoreGState(c); CGPDFContextEndPage(c); }
    CGPDFContextClose(c); CGContextRelease(c); CGPDFDocumentRelease(d); return YES;
}
+ (BOOL)mergePaths:(NSArray *)paths toPath:(NSString *)outPath {
    CGContextRef c=CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:outPath],NULL,NULL); if(!c)return NO;
    for(NSString *path in paths){ CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]); if(!d)continue; size_t ct=CGPDFDocumentGetNumberOfPages(d); for(size_t i=1;i<=ct;i++){CGPDFContextBeginPage(c,NULL);CGContextDrawPDFPage(c,CGPDFDocumentGetPage(d,i));CGPDFContextEndPage(c);} CGPDFDocumentRelease(d);}
    CGPDFContextClose(c); CGContextRelease(c); return YES;
}
@end
