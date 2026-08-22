#import "AnnotationOverlayView.h"
#import "AnnotationStore.h"
#import <math.h>

static void SetHighlightFill(CGContextRef c, NSString *name, CGFloat alpha) {
    if([name isEqualToString:@"green"]) CGContextSetRGBFillColor(c,.35f,1.0f,.30f,alpha);
    else if([name isEqualToString:@"pink"]) CGContextSetRGBFillColor(c,1.0f,.35f,.70f,alpha);
    else if([name isEqualToString:@"orange"]) CGContextSetRGBFillColor(c,1.0f,.62f,.18f,alpha);
    else if([name isEqualToString:@"cyan"]) CGContextSetRGBFillColor(c,.25f,.90f,1.0f,alpha);
    else CGContextSetRGBFillColor(c,1.0f,1.0f,.10f,alpha);
}

@implementation AnnotationOverlayView
@synthesize pdfPath=_pdfPath,page=_page,drawingEnabled=_drawingEnabled,highlightSelectionEnabled=_highlightSelectionEnabled,highlightColorName=_highlightColorName,pageTextRects=_pageTextRects;

- (id)initWithFrame:(CGRect)f {
    if((self=[super initWithFrame:f])){
        self.backgroundColor=[UIColor clearColor];
        self.opaque=NO;
        self.userInteractionEnabled=NO;
        _points=[[NSMutableArray alloc] init];
        _highlightColorName=[@"yellow" copy];
    }
    return self;
}

- (UIScrollView *)parentScrollView {
    UIView *v=self.superview;
    while(v){ if([v isKindOfClass:[UIScrollView class]])return (UIScrollView *)v; v=v.superview; }
    return nil;
}

- (void)setDrawingEnabled:(BOOL)v {
    _drawingEnabled=v;
    if(v)_highlightSelectionEnabled=NO;
    self.userInteractionEnabled=(_drawingEnabled||_highlightSelectionEnabled);
}

- (void)setHighlightSelectionEnabled:(BOOL)v {
    _highlightSelectionEnabled=v;
    if(v)_drawingEnabled=NO;
    _hasHighlightPreview=NO;
    self.userInteractionEnabled=(_drawingEnabled||_highlightSelectionEnabled);
    UIScrollView *s=[self parentScrollView];
    if(s)s.scrollEnabled=!v;
    [self setNeedsDisplay];
}

- (void)clearTemporarySelection {
    _hasHighlightPreview=NO;
    _highlightStart=CGPointZero;
    _highlightCurrent=CGPointZero;
    [_pageTextRects release]; _pageTextRects=nil;
    self.highlightSelectionEnabled=NO;
    [self setNeedsDisplay];
}

- (void)reloadAnnotations { [self setNeedsDisplay]; }

- (CGRect)highlightPreviewRect {
    CGFloat x=MIN(_highlightStart.x,_highlightCurrent.x);
    CGFloat y=MIN(_highlightStart.y,_highlightCurrent.y);
    CGFloat w=fabs(_highlightCurrent.x-_highlightStart.x);
    CGFloat h=fabs(_highlightCurrent.y-_highlightStart.y);
    return CGRectMake(x,y,w,h);
}

- (NSArray *)semanticRectsIntersectingPreview {
    if([_pageTextRects count]==0||self.bounds.size.width<=0||self.bounds.size.height<=0) return [NSArray array];
    CGRect selection=[self highlightPreviewRect];
    NSMutableArray *matches=[NSMutableArray arrayWithCapacity:8];
    for(NSString *s in _pageTextRects){
        CGRect n=CGRectFromString(s);
        CGRect q=CGRectMake(n.origin.x*self.bounds.size.width,n.origin.y*self.bounds.size.height,n.size.width*self.bounds.size.width,n.size.height*self.bounds.size.height);
        if(CGRectIntersectsRect(selection,CGRectInset(q,-3.0f,-3.0f))){
            [matches addObject:s];
            if([matches count]>=32)break;
        }
    }
    return matches;
}

- (void)drawNormalizedHighlightRects:(NSArray *)rects context:(CGContextRef)c color:(NSString *)color alpha:(CGFloat)alpha {
    SetHighlightFill(c,color,alpha);
    for(NSString *s in rects){
        CGRect n=CGRectFromString(s);
        CGRect q=CGRectMake(n.origin.x*self.bounds.size.width,n.origin.y*self.bounds.size.height,n.size.width*self.bounds.size.width,n.size.height*self.bounds.size.height);
        CGContextFillRect(c,q);
    }
}

- (void)drawRect:(CGRect)r {
    CGContextRef c=UIGraphicsGetCurrentContext();
    NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:_page];
    for(NSDictionary*a in anns){
        NSString*t=[a objectForKey:@"type"];
        if([t isEqualToString:@"draw"]){
            NSArray*pts=[a objectForKey:@"points"];
            if([pts count]>1){
                CGContextSetRGBStrokeColor(c,0,0,1,.85);
                CGContextSetLineWidth(c,2);
                for(NSUInteger i=0;i<[pts count];i++){
                    CGPoint p=CGPointFromString([pts objectAtIndex:i]);
                    p=CGPointMake(p.x*self.bounds.size.width,p.y*self.bounds.size.height);
                    if(i==0)CGContextMoveToPoint(c,p.x,p.y); else CGContextAddLineToPoint(c,p.x,p.y);
                }
                CGContextStrokePath(c);
            }
        } else if([t isEqualToString:@"highlight"]){
            NSArray *rects=[a objectForKey:@"rects"];
            if([rects count]>0){
                [self drawNormalizedHighlightRects:rects context:c color:[a objectForKey:@"color"] alpha:.34f];
            } else {
                CGRect q=CGRectFromString([a objectForKey:@"rect"]);
                q=CGRectMake(q.origin.x*self.bounds.size.width,q.origin.y*self.bounds.size.height,q.size.width*self.bounds.size.width,q.size.height*self.bounds.size.height);
                SetHighlightFill(c,[a objectForKey:@"color"],.34f);CGContextFillRect(c,q);
            }
        } else {
            CGRect q=CGRectFromString([a objectForKey:@"rect"]);
            q=CGRectMake(q.origin.x*self.bounds.size.width,q.origin.y*self.bounds.size.height,q.size.width*self.bounds.size.width,q.size.height*self.bounds.size.height);
            if([t isEqualToString:@"note"]){CGContextSetRGBFillColor(c,1,.8,.1,.9);CGContextFillEllipseInRect(c,q);}
            else if([t isEqualToString:@"signature"]){[[UIColor darkGrayColor] set];[[a objectForKey:@"text"] drawInRect:q withFont:[UIFont italicSystemFontOfSize:22]];}
        }
    }
    if(_highlightSelectionEnabled&&_hasHighlightPreview){
        NSArray *semantic=[self semanticRectsIntersectingPreview];
        if([semantic count]>0){
            [self drawNormalizedHighlightRects:semantic context:c color:_highlightColorName alpha:.24f];
        } else if([_pageTextRects count]==0) {
            SetHighlightFill(c,_highlightColorName,.24f);
            CGContextFillRect(c,[self highlightPreviewRect]);
            CGContextSetRGBStrokeColor(c,1,.55,0,.9);
            CGContextSetLineWidth(c,1.0f);
            CGContextStrokeRect(c,[self highlightPreviewRect]);
        } else {
            CGContextSetRGBStrokeColor(c,1,.55,0,.9);
            CGContextSetLineWidth(c,1.0f);
            CGContextStrokeRect(c,[self highlightPreviewRect]);
        }
    }
}

- (void)touchesBegan:(NSSet*)t withEvent:(UIEvent*)e {
    CGPoint p=[[t anyObject] locationInView:self];
    if(_highlightSelectionEnabled){_highlightStart=p;_highlightCurrent=p;_hasHighlightPreview=YES;[self setNeedsDisplay];return;}
    [_points removeAllObjects];[_points addObject:NSStringFromCGPoint(p)];
}
- (void)touchesMoved:(NSSet*)t withEvent:(UIEvent*)e {
    CGPoint p=[[t anyObject] locationInView:self];
    if(_highlightSelectionEnabled){_highlightCurrent=p;[self setNeedsDisplay];return;}
    [_points addObject:NSStringFromCGPoint(p)];[self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet*)t withEvent:(UIEvent*)e {
    if(_highlightSelectionEnabled){
        _highlightCurrent=[[t anyObject] locationInView:self];
        NSArray *semantic=[self semanticRectsIntersectingPreview];
        if([semantic count]>0){
            NSDictionary *a=[NSDictionary dictionaryWithObjectsAndKeys:@"highlight",@"type",semantic,@"rects",_highlightColorName?_highlightColorName:@"yellow",@"color",nil];
            [AnnotationStore addAnnotation:a path:_pdfPath page:_page];
        } else if([_pageTextRects count]==0) {
            CGRect q=[self highlightPreviewRect];
            if(q.size.width>=8.0f&&q.size.height>=5.0f&&self.bounds.size.width>0&&self.bounds.size.height>0){
                CGRect n=CGRectMake(q.origin.x/self.bounds.size.width,q.origin.y/self.bounds.size.height,q.size.width/self.bounds.size.width,q.size.height/self.bounds.size.height);
                NSDictionary *a=[NSDictionary dictionaryWithObjectsAndKeys:@"highlight",@"type",NSStringFromCGRect(n),@"rect",_highlightColorName?_highlightColorName:@"yellow",@"color",nil];
                [AnnotationStore addAnnotation:a path:_pdfPath page:_page];
            }
        }
        [self clearTemporarySelection];
        return;
    }
    if([_points count]>1){
        NSMutableArray*n=[NSMutableArray array];
        for(NSString*s in _points){CGPoint p=CGPointFromString(s);[n addObject:NSStringFromCGPoint(CGPointMake(p.x/self.bounds.size.width,p.y/self.bounds.size.height))];}
        [AnnotationStore addAnnotation:[NSDictionary dictionaryWithObjectsAndKeys:@"draw",@"type",n,@"points",nil] path:_pdfPath page:_page];
    }
    [_points removeAllObjects];[self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [_points removeAllObjects];
    if(_highlightSelectionEnabled)[self clearTemporarySelection];
    else {_hasHighlightPreview=NO;[self setNeedsDisplay];}
}
- (void)dealloc { [_pdfPath release];[_highlightColorName release];[_pageTextRects release];[_points release];[super dealloc]; }
@end
