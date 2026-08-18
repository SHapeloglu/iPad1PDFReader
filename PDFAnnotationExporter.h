#import <Foundation/Foundation.h>
@interface PDFAnnotationExporter : NSObject
+ (BOOL)exportFlattenedPDFAtPath:(NSString *)path toPath:(NSString *)outPath;
@end
