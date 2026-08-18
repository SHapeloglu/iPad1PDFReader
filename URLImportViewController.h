#import <UIKit/UIKit.h>
@protocol URLImportViewControllerDelegate<NSObject>- (void)urlImportFinishedAtPath:(NSString*)path;@end
@interface URLImportViewController:UIViewController<UITextFieldDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>{UITextField*_field;UILabel*_status;NSMutableData*_data;NSURLConnection*_conn;id<URLImportViewControllerDelegate>_delegate;NSURL*_url;}
@property(nonatomic,assign)id<URLImportViewControllerDelegate>delegate;
@end
