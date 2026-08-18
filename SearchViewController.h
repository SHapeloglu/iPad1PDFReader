#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@protocol SearchViewControllerDelegate <NSObject>
- (void)searchControllerSelectedPage:(NSUInteger)page;
@end
@interface SearchViewController : UITableViewController <UISearchBarDelegate> {
    NSString *_pdfPath;
    NSMutableArray *_results;
    UISearchBar *_searchBar;
    UILabel *_progressLabel;
    CGPDFDocumentRef _document;
    id<SearchViewControllerDelegate> _delegate;
    NSString *_activeTerm;
    NSUInteger _searchPage;
    NSUInteger _searchPageCount;
    BOOL _searching;
    BOOL _cancelRequested;
}
@property (nonatomic, assign) id<SearchViewControllerDelegate> delegate;
- (id)initWithPDFPath:(NSString *)path;
@end
