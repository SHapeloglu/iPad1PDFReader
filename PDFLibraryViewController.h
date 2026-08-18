#import <UIKit/UIKit.h>
@interface PDFLibraryViewController : UITableViewController <UIActionSheetDelegate,UIAlertViewDelegate> {
    NSArray *_pdfFiles; UILabel *_emptyLabel; NSIndexPath *_actionIndexPath;
}
- (void)reloadPDFList;
- (void)importExternalPDFURL:(NSURL *)url;
@end
