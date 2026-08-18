#import "MemoryBudget.h"

@implementation MemoryBudget
+ (void)logMemoryPolicy {
    NSLog(@"[iPad1PDFReader] Memory policy: thumbnail cache=%d, search results=%d, reflow window=%d",
          IPAD1_THUMBNAIL_CACHE_LIMIT,
          IPAD1_SEARCH_MAX_RESULTS,
          IPAD1_REFLOW_PAGE_WINDOW);
}
@end
