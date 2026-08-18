#import <UIKit/UIKit.h>
@protocol OutlineViewControllerDelegate <NSObject>
- (void)outlineControllerSelectedPage:(NSUInteger)page;
@end
@interface OutlineViewController:UITableViewController{
    NSArray*_items;
    id<OutlineViewControllerDelegate> _delegate;
}
@property(nonatomic,assign) id<OutlineViewControllerDelegate> delegate;
- (id)initWithItems:(NSArray*)items;
@end
