#import <Foundation/Foundation.h>
@interface RecentStore : NSObject
+ (void)touchPath:(NSString *)path;
+ (NSArray *)recentPaths;
+ (BOOL)isFavoritePath:(NSString *)path;
+ (void)toggleFavoritePath:(NSString *)path;
@end
