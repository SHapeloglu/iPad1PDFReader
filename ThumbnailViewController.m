#import "ThumbnailViewController.h"
#import "MemoryBudget.h"

@implementation ThumbnailViewController
@synthesize delegate=_delegate;

- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithStyle:UITableViewStylePlain])) {
        _pdfPath=[path copy];
        _doc=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        _count=_doc?CGPDFDocumentGetNumberOfPages(_doc):0;
        _thumbnailCache=[[NSMutableDictionary alloc] init];
        _thumbnailLRU=[[NSMutableArray alloc] init];
        self.title=@"Sayfalar";
    }
    return self;
}

- (void)touchCacheKey:(NSNumber *)key {
    [_thumbnailLRU removeObject:key];
    [_thumbnailLRU addObject:key];

    while([_thumbnailLRU count] > IPAD1_THUMBNAIL_CACHE_LIMIT) {
        NSNumber *old=[_thumbnailLRU objectAtIndex:0];
        [_thumbnailCache removeObjectForKey:old];
        [_thumbnailLRU removeObjectAtIndex:0];
    }
}

- (UIImage *)thumbnailForPage:(NSUInteger)pageNumber {
    NSNumber *key=[NSNumber numberWithUnsignedInteger:pageNumber];
    UIImage *cached=[_thumbnailCache objectForKey:key];
    if(cached) {
        [self touchCacheKey:key];
        return cached;
    }

    CGPDFPageRef page=CGPDFDocumentGetPage(_doc,pageNumber);
    if(!page) return nil;

    CGSize sz=CGSizeMake(56.0f,72.0f);
    UIGraphicsBeginImageContext(sz);
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx,1,1,1,1);
    CGContextFillRect(ctx,(CGRect){CGPointZero,sz});
    CGContextTranslateCTM(ctx,0,sz.height);
    CGContextScaleCTM(ctx,1,-1);
    CGContextConcatCTM(ctx,CGPDFPageGetDrawingTransform(page,kCGPDFMediaBox,(CGRect){CGPointZero,sz},0,true));
    CGContextSetInterpolationQuality(ctx,kCGInterpolationLow);
    CGContextDrawPDFPage(ctx,page);
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if(image) {
        [_thumbnailCache setObject:image forKey:key];
        [self touchCacheKey:key];
    }
    return image;
}

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s {
    return _count;
}

- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"thumb";
    UITableViewCell *cell=[t dequeueReusableCellWithIdentifier:cid];
    if(!cell) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid] autorelease];
        cell.imageView.contentMode=UIViewContentModeScaleAspectFit;
    }

    NSUInteger page=(NSUInteger)i.row+1;
    cell.textLabel.text=[NSString stringWithFormat:@"Sayfa %lu",(unsigned long)page];

    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    cell.imageView.image=[self thumbnailForPage:page];
    [pool drain];

    return cell;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    if([_delegate respondsToSelector:@selector(thumbnailControllerSelectedPage:)])
        [_delegate thumbnailControllerSelectedPage:(NSUInteger)i.row+1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearThumbnailCache {
    [_thumbnailCache removeAllObjects];
    [_thumbnailLRU removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self clearThumbnailCache];
}

- (void)dealloc {
    [self clearThumbnailCache];
    [_thumbnailCache release];
    [_thumbnailLRU release];
    [_pdfPath release];
    if(_doc) CGPDFDocumentRelease(_doc);
    [super dealloc];
}
@end
