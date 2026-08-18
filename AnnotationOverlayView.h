#import <UIKit/UIKit.h>
@interface AnnotationOverlayView : UIView {
    NSString *_pdfPath;
    NSUInteger _page;
    BOOL _drawingEnabled;
    BOOL _highlightSelectionEnabled;
    NSString *_highlightColorName;
    NSMutableArray *_points;
    CGPoint _highlightStart;
    CGPoint _highlightCurrent;
    BOOL _hasHighlightPreview;
}
@property(nonatomic,copy) NSString *pdfPath;
@property(nonatomic,assign) NSUInteger page;
@property(nonatomic,assign) BOOL drawingEnabled;
@property(nonatomic,assign) BOOL highlightSelectionEnabled;
@property(nonatomic,copy) NSString *highlightColorName;
- (void)reloadAnnotations;
@end
