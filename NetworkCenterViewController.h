#import <UIKit/UIKit.h>
#import "WebDAVClient.h"
@interface NetworkCenterViewController : UITableViewController <WebDAVClientDelegate,UIAlertViewDelegate> {
    NSArray *_types; WebDAVClient *_webdav;
}
@end
