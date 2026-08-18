#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface PDFTextExtractor : NSObject
+ (NSString *)textForPage:(CGPDFPageRef)page;
+ (NSArray *)searchTerm:(NSString *)term inDocument:(CGPDFDocumentRef)document maxResults:(NSUInteger)maxResults;
@end
