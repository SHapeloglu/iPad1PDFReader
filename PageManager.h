#import <Foundation/Foundation.h>
@interface PageManager : NSObject
+ (BOOL)exportDocumentAtPath:(NSString *)path pageOrder:(NSArray *)pages rotations:(NSDictionary *)rotations toPath:(NSString *)outPath;
+ (BOOL)mergePaths:(NSArray *)paths toPath:(NSString *)outPath;
@end
