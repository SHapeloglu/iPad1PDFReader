#import <UIKit/UIKit.h>

@protocol DocumentNavigatorViewControllerDelegate <NSObject>
- (void)documentNavigatorSelectedPage:(NSUInteger)page;
@end

@interface DocumentNavigatorViewController : UITableViewController {
    NSString *_pdfPath;
    NSUInteger _pageCount;
    NSArray *_sections;
    id<DocumentNavigatorViewControllerDelegate> _delegate;
}
@property(nonatomic,assign) id<DocumentNavigatorViewControllerDelegate> delegate;
- (id)initWithPDFPath:(NSString *)path pageCount:(NSUInteger)pageCount;
@end
