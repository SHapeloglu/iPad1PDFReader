#import <Foundation/Foundation.h>
@interface AnnotationStore : NSObject
+ (NSArray *)annotationsForPath:(NSString *)path page:(NSUInteger)page;
+ (void)addAnnotation:(NSDictionary *)a path:(NSString *)path page:(NSUInteger)page;
+ (void)replaceAnnotationAtIndex:(NSUInteger)index withAnnotation:(NSDictionary *)a path:(NSString *)path page:(NSUInteger)page;
+ (void)removeAnnotationAtIndex:(NSUInteger)index path:(NSString *)path page:(NSUInteger)page;
+ (void)clearAnnotationsForPath:(NSString *)path page:(NSUInteger)page;
@end
