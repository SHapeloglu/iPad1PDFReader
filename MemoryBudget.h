#import <Foundation/Foundation.h>

#define IPAD1_THUMBNAIL_CACHE_LIMIT 8
#define IPAD1_SEARCH_MAX_RESULTS 40
#define IPAD1_REFLOW_PAGE_WINDOW 3

@interface MemoryBudget : NSObject
+ (void)logMemoryPolicy;
@end
