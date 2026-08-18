#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol ThumbnailViewControllerDelegate <NSObject>
- (void)thumbnailControllerSelectedPage:(NSUInteger)page;
@end

@interface ThumbnailViewController : UITableViewController {
    NSString *_pdfPath;
    CGPDFDocumentRef _doc;
    NSUInteger _count;
    id<ThumbnailViewControllerDelegate> _delegate;
    NSMutableDictionary *_thumbnailCache;
    NSMutableArray *_thumbnailLRU;
}

@property (nonatomic, assign) id<ThumbnailViewControllerDelegate> delegate;
- (id)initWithPDFPath:(NSString *)path;
- (void)clearThumbnailCache;
@end
