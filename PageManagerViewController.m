#import "PageManagerViewController.h"
#import "PageManager.h"
#import <CoreGraphics/CoreGraphics.h>
@implementation PageManagerViewController
- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithStyle:UITableViewStylePlain])) {
        _pdfPath=[path copy]; _pages=[[NSMutableArray alloc] init]; _rotations=[[NSMutableDictionary alloc] init];
        CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]); size_t c=d?CGPDFDocumentGetNumberOfPages(d):0;
        for(size_t i=1;i<=c;i++)[_pages addObject:[NSNumber numberWithUnsignedInteger:i]]; if(d)CGPDFDocumentRelease(d);
        self.title=@"Sayfa Yöneticisi"; self.navigationItem.rightBarButtonItem=self.editButtonItem;
    } return self;
}
- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s { return [_pages count]; }
- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"p"; UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];
    NSNumber *p=[_pages objectAtIndex:i.row]; c.textLabel.text=[NSString stringWithFormat:@"Sayfa %@",p]; c.detailTextLabel.text=[NSString stringWithFormat:@"Döndürme: %@°",[_rotations objectForKey:p]?:@0]; return c;
}
- (BOOL)tableView:(UITableView *)t canMoveRowAtIndexPath:(NSIndexPath *)i { return YES; }
- (void)tableView:(UITableView *)t moveRowAtIndexPath:(NSIndexPath *)f toIndexPath:(NSIndexPath *)to { id o=[[_pages objectAtIndex:f.row] retain]; [_pages removeObjectAtIndex:f.row]; [_pages insertObject:o atIndex:to.row]; [o release]; }
- (void)tableView:(UITableView *)t commitEditingStyle:(UITableViewCellEditingStyle)s forRowAtIndexPath:(NSIndexPath *)i { if(s==UITableViewCellEditingStyleDelete){[_pages removeObjectAtIndex:i.row];[t deleteRowsAtIndexPaths:[NSArray arrayWithObject:i] withRowAnimation:UITableViewRowAnimationAutomatic];} }
- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i { NSNumber *p=[_pages objectAtIndex:i.row]; NSInteger r=([[_rotations objectForKey:p] integerValue]+90)%360; [_rotations setObject:[NSNumber numberWithInteger:r] forKey:p]; [t reloadRowsAtIndexPaths:[NSArray arrayWithObject:i] withRowAnimation:UITableViewRowAnimationNone]; }
- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; if([self isMovingFromParentViewController]){ NSString *dir=[_pdfPath stringByDeletingLastPathComponent]; NSString *out=[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-edited.pdf",[[_pdfPath lastPathComponent] stringByDeletingPathExtension]]]; [PageManager exportDocumentAtPath:_pdfPath pageOrder:_pages rotations:_rotations toPath:out]; } }
- (void)dealloc { [_pdfPath release]; [_pages release]; [_rotations release]; [super dealloc]; }
@end
