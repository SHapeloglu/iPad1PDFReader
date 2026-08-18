#import "RecentStore.h"
@implementation RecentStore
+ (NSArray *)arrayForKey:(NSString *)k { NSArray *a=[[NSUserDefaults standardUserDefaults] arrayForKey:k]; return a?a:[NSArray array]; }
+ (void)touchPath:(NSString *)path { NSUserDefaults *d=[NSUserDefaults standardUserDefaults]; NSMutableArray *a=[NSMutableArray arrayWithArray:[self arrayForKey:@"recent_paths"]]; [a removeObject:path]; [a insertObject:path atIndex:0]; while([a count]>20)[a removeLastObject]; [d setObject:a forKey:@"recent_paths"]; [d synchronize]; }
+ (NSArray *)recentPaths { return [self arrayForKey:@"recent_paths"]; }
+ (BOOL)isFavoritePath:(NSString *)path { return [[self arrayForKey:@"favorite_paths"] containsObject:path]; }
+ (void)toggleFavoritePath:(NSString *)path { NSUserDefaults *d=[NSUserDefaults standardUserDefaults]; NSMutableArray *a=[NSMutableArray arrayWithArray:[self arrayForKey:@"favorite_paths"]]; if([a containsObject:path])[a removeObject:path]; else [a addObject:path]; [d setObject:a forKey:@"favorite_paths"]; [d synchronize]; }
@end
