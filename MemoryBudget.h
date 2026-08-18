#import <Foundation/Foundation.h>

#define IPAD1_THUMBNAIL_CACHE_LIMIT 8
#define IPAD1_SEARCH_MAX_RESULTS 40
#define IPAD1_REFLOW_PAGE_WINDOW 3
#define IPAD1_NAVIGATOR_MAX_ITEMS 80
#define IPAD1_NAVIGATOR_MAX_PER_KIND 40

@interface MemoryBudget : NSObject
+ (void)logMemoryPolicy;
@end
