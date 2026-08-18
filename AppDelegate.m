#import "AppDelegate.h"
#import "PDFLibraryViewController.h"
#import "MemoryBudget.h"
@implementation AppDelegate
@synthesize window=_window;
@synthesize navigationController=_navigationController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    PDFLibraryViewController *library=[[[PDFLibraryViewController alloc] init] autorelease];
    self.navigationController=[[[UINavigationController alloc] initWithRootViewController:library] autorelease];
    self.window.rootViewController=self.navigationController;
    [self.window makeKeyAndVisible];
    [MemoryBudget logMemoryPolicy];
    NSURL *url=[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(url) [library importExternalPDFURL:url];
    return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if([self.navigationController.viewControllers count]==0) return NO;
    id root=[self.navigationController.viewControllers objectAtIndex:0];
    if([root respondsToSelector:@selector(importExternalPDFURL:)]) {
        [root importExternalPDFURL:url];
        return YES;
    }
    return NO;
}
- (void)dealloc { [_navigationController release]; [_window release]; [super dealloc]; }
@end
