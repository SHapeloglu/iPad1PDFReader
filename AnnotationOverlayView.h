#import <UIKit/UIKit.h>
@interface AnnotationOverlayView : UIView { NSString *_pdfPath; NSUInteger _page; BOOL _drawingEnabled; NSMutableArray *_points; }
@property(nonatomic,copy) NSString *pdfPath;
@property(nonatomic,assign) NSUInteger page;
@property(nonatomic,assign) BOOL drawingEnabled;
- (void)reloadAnnotations;
@end
