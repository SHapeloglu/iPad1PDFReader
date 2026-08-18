#import "PageManagerViewController.h"
#import "PageManager.h"
#import <CoreGraphics/CoreGraphics.h>
@implementation PageManagerViewController
- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithStyle:UITableViewStylePlain])) {
        _pdfPath=[path copy];
        _pages=[[NSMutableArray alloc] init];
        _rotations=[[NSMutableDictionary alloc] init];
        CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        size_t c=d?CGPDFDocumentGetNumberOfPages(d):0;
        for(size_t i=1;i<=c;i++)[_pages addObject:[NSNumber numberWithUnsignedInteger:i]];
        if(d)CGPDFDocumentRelease(d);
        self.title=@"Sayfa Yöneticisi";
        self.navigationItem.leftBarButtonItem=self.editButtonItem;
        self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Kaydet" style:UIBarButtonItemStyleDone target:self action:@selector(saveCopy)] autorelease];
    }
    return self;
}
- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s { return [_pages count]; }
- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"p";
    UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];
    NSNumber *p=[_pages objectAtIndex:i.row];
    c.textLabel.text=[NSString stringWithFormat:@"Sayfa %@",p];
    c.detailTextLabel.text=[NSString stringWithFormat:@"Dokun: 90° döndür — Şu an: %@°",[_rotations objectForKey:p]?:@0];
    return c;
}
- (BOOL)tableView:(UITableView *)t canMoveRowAtIndexPath:(NSIndexPath *)i { return YES; }
- (void)tableView:(UITableView *)t moveRowAtIndexPath:(NSIndexPath *)f toIndexPath:(NSIndexPath *)to {
    id o=[[_pages objectAtIndex:f.row] retain];
    [_pages removeObjectAtIndex:f.row];
    [_pages insertObject:o atIndex:to.row];
    [o release];
    _dirty=YES;
}
- (void)tableView:(UITableView *)t commitEditingStyle:(UITableViewCellEditingStyle)s forRowAtIndexPath:(NSIndexPath *)i {
    if(s==UITableViewCellEditingStyleDelete){
        [_pages removeObjectAtIndex:i.row];
        [t deleteRowsAtIndexPaths:[NSArray arrayWithObject:i] withRowAnimation:UITableViewRowAnimationAutomatic];
        _dirty=YES;
    }
}
- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    NSNumber *p=[_pages objectAtIndex:i.row];
    NSInteger r=([[_rotations objectForKey:p] integerValue]+90)%360;
    [_rotations setObject:[NSNumber numberWithInteger:r] forKey:p];
    _dirty=YES;
    [t reloadRowsAtIndexPaths:[NSArray arrayWithObject:i] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)saveCopy {
    if([_pages count]==0){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Kaydedilemedi" message:@"Belgede en az bir sayfa kalmalı." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show];return;
    }
    NSString *dir=[_pdfPath stringByDeletingLastPathComponent];
    NSString *out=[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-edited.pdf",[[_pdfPath lastPathComponent] stringByDeletingPathExtension]]];
    BOOL ok=[PageManager exportDocumentAtPath:_pdfPath pageOrder:_pages rotations:_rotations toPath:out];
    if(ok)_dirty=NO;
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:ok?@"Kaydedildi":@"Hata" message:ok?[NSString stringWithFormat:@"Orijinal korunarak yeni dosya oluşturuldu:\n%@",[out lastPathComponent]]:@"Yeni PDF oluşturulamadı." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(_dirty&&[self isMovingFromParentViewController]){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Değişiklikler Kaydedilmedi" message:@"Sayfa düzenleme değişiklikleri yalnız Kaydet düğmesine bastığınızda yeni PDF'e yazılır." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
        [a show];
    }
}
- (void)dealloc { [_pdfPath release]; [_pages release]; [_rotations release]; [super dealloc]; }
@end
