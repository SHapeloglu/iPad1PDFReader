#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@protocol SearchViewControllerDelegate <NSObject>
- (void)searchControllerSelectedPage:(NSUInteger)page;
@end
@interface SearchViewController : UITableViewController <UISearchBarDelegate> {
    NSString *_pdfPath;
    NSArray *_results;
    UISearchBar *_searchBar;
    CGPDFDocumentRef _document;
    id<SearchViewControllerDelegate> _delegate;
}
@property (nonatomic, assign) id<SearchViewControllerDelegate> delegate;
- (id)initWithPDFPath:(NSString *)path;
@end
