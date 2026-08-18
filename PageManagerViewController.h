#import <UIKit/UIKit.h>
@interface PageManagerViewController : UITableViewController {
    NSString *_pdfPath;
    NSMutableArray *_pages;
    NSMutableDictionary *_rotations;
    BOOL _dirty;
}
- (id)initWithPDFPath:(NSString *)path;
@end
