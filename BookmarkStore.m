#import "BookmarkStore.h"

@implementation BookmarkStore

+ (NSString *)documentKeyForPath:(NSString *)path {
    NSString *name = [path lastPathComponent];
    return [name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

+ (NSString *)lastPageKeyForPath:(NSString *)path {
    return [NSString stringWithFormat:@"lastpage_%@", [self documentKeyForPath:path]];
}

+ (NSString *)bookmarkKeyForPath:(NSString *)path {
    return [NSString stringWithFormat:@"bookmarks_%@", [self documentKeyForPath:path]];
}

+ (NSUInteger)lastPageForPath:(NSString *)path {
    NSInteger page = [[NSUserDefaults standardUserDefaults]
                      integerForKey:[self lastPageKeyForPath:path]];
    if (page < 1) {
        return 1;
    }
    return (NSUInteger)page;
}

+ (void)setLastPage:(NSUInteger)page forPath:(NSString *)path {
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)page
                                              forKey:[self lastPageKeyForPath:path]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)bookmarksForPath:(NSString *)path {
    NSArray *stored = [[NSUserDefaults standardUserDefaults]
                       arrayForKey:[self bookmarkKeyForPath:path]];
    if (stored == nil) {
        return [NSArray array];
    }
    return stored;
}

+ (BOOL)isBookmarkedPage:(NSUInteger)page forPath:(NSString *)path {
    NSNumber *needle = [NSNumber numberWithUnsignedInteger:page];
    return [[self bookmarksForPath:path] containsObject:needle];
}

+ (void)toggleBookmarkForPage:(NSUInteger)page forPath:(NSString *)path {
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self bookmarksForPath:path]];
    NSNumber *number = [NSNumber numberWithUnsignedInteger:page];

    if ([items containsObject:number]) {
        [items removeObject:number];
    } else {
        [items addObject:number];
        [items sortUsingSelector:@selector(compare:)];
    }

    [[NSUserDefaults standardUserDefaults] setObject:items
                                              forKey:[self bookmarkKeyForPath:path]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
