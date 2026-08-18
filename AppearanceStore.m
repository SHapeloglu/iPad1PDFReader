#import "AppearanceStore.h"
@implementation AppearanceStore
+ (PDFTheme)theme { return (PDFTheme)[[NSUserDefaults standardUserDefaults] integerForKey:@"pdf_theme"]; }
+ (void)setTheme:(PDFTheme)t { [[NSUserDefaults standardUserDefaults] setInteger:t forKey:@"pdf_theme"]; [[NSUserDefaults standardUserDefaults] synchronize]; }
@end
