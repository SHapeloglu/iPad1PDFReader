#import "AppDelegate.h"
#import "PDFLibraryViewController.h"
#import "MemoryBudget.h"

@implementation AppDelegate
@synthesize window=_window;
@synthesize navigationController=_navigationController;

- (NSString *)decodedQueryValueForKey:(NSString *)key URL:(NSURL *)url {
    NSString *query=[url query];
    if(!query || !key) return nil;
    NSArray *pairs=[query componentsSeparatedByString:@"&"];
    for(NSString *pair in pairs) {
        NSRange eq=[pair rangeOfString:@"="];
        NSString *rawKey=(eq.location==NSNotFound)?pair:[pair substringToIndex:eq.location];
        if(![rawKey isEqualToString:key]) continue;
        NSString *rawValue=(eq.location==NSNotFound)?@"":[pair substringFromIndex:eq.location+1];
        rawValue=[rawValue stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        return [rawValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (BOOL)openIncomingURL:(NSURL *)url {
    if(!url || [self.navigationController.viewControllers count]==0) return NO;
    id root=[self.navigationController.viewControllers objectAtIndex:0];

    if([[url scheme] caseInsensitiveCompare:@"ipad1pdf"]==NSOrderedSame) {
        NSString *path=[self decodedQueryValueForKey:@"path" URL:url];
        BOOL isDirectory=NO;
        if(!path || ![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] || isDirectory) return NO;
        if([[[path pathExtension] lowercaseString] isEqualToString:@"pdf"] &&
           [root respondsToSelector:@selector(openPDFAtPath:)]) {
            return (BOOL)[root openPDFAtPath:path];
        }
        return NO;
    }

    if([root respondsToSelector:@selector(importExternalPDFURL:)]) {
        [root importExternalPDFURL:url];
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;
    self.window=[[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    PDFLibraryViewController *library=[[[PDFLibraryViewController alloc] init] autorelease];
    self.navigationController=[[[UINavigationController alloc] initWithRootViewController:library] autorelease];
    self.window.rootViewController=self.navigationController;
    [self.window makeKeyAndVisible];
    [MemoryBudget logMemoryPolicy];
    NSURL *url=[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(url) [self openIncomingURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    (void)application;
    return [self openIncomingURL:url];
}

- (void)dealloc { [_navigationController release]; [_window release]; [super dealloc]; }
@end
