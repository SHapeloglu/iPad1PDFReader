#import <Foundation/Foundation.h>
typedef enum { PDFThemeNormal=0, PDFThemeSepia=1, PDFThemeNight=2 } PDFTheme;
@interface AppearanceStore : NSObject
+ (PDFTheme)theme;
+ (void)setTheme:(PDFTheme)t;
@end
