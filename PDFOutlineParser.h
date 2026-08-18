#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface PDFOutlineParser:NSObject
+ (NSArray*)outlineForDocument:(CGPDFDocumentRef)doc;
@end
