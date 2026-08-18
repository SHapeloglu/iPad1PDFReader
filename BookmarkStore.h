#import <Foundation/Foundation.h>

@interface BookmarkStore : NSObject

+ (NSString *)documentKeyForPath:(NSString *)path;
+ (NSUInteger)lastPageForPath:(NSString *)path;
+ (void)setLastPage:(NSUInteger)page forPath:(NSString *)path;

+ (NSArray *)bookmarksForPath:(NSString *)path;
+ (BOOL)isBookmarkedPage:(NSUInteger)page forPath:(NSString *)path;
+ (void)toggleBookmarkForPage:(NSUInteger)page forPath:(NSString *)path;

@end
