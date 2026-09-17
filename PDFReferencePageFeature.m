#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "PDFReaderViewController.h"
#import "ReferencePageViewController.h"

static char IP1ReferenceBarItemKey;
static char IP1ReferenceButtonKey;
static char IP1ReferencePopoverKey;

@interface PDFReaderViewController (IP1ReferencePage)
- (void)ip1_reference_viewDidLoad;
- (void)ip1_referenceButtonTapped:(id)sender;
- (void)ip1_referenceButtonLongPressed:(UILongPressGestureRecognizer *)gesture;
@end

@implementation PDFReaderViewController (IP1ReferencePage)

+ (void)load {
    Method original=class_getInstanceMethod(self,@selector(viewDidLoad));
    Method replacement=class_getInstanceMethod(self,@selector(ip1_reference_viewDidLoad));
    method_exchangeImplementations(original,replacement);
}

- (NSString *)ip1_referenceDefaultsKey {
    NSString *path=nil;
    @try { path=[self valueForKey:@"pdfPath"]; } @catch(NSException *e) { (void)e; }
    if(![path length]) return nil;
    return [@"IP1ReferencePage:" stringByAppendingString:path];
}

- (NSUInteger)ip1_currentPageNumber {
    @try { return [[self valueForKey:@"currentPage"] unsignedIntegerValue]; }
    @catch(NSException *e) { (void)e; return 0; }
}

- (NSUInteger)ip1_pageCountValue {
    @try { return [[self valueForKey:@"pageCount"] unsignedIntegerValue]; }
    @catch(NSException *e) { (void)e; return 0; }
}

- (NSString *)ip1_pdfPathValue {
    @try { return [self valueForKey:@"pdfPath"]; }
    @catch(NSException *e) { (void)e; return nil; }
}

- (NSUInteger)ip1_savedReferencePage {
    NSString *key=[self ip1_referenceDefaultsKey];
    if(!key) return 0;
    NSUInteger page=(NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:key];
    NSUInteger count=[self ip1_pageCountValue];
    if(page<1 || (count>0 && page>count)) return 0;
    return page;
}

- (UIButton *)ip1_referenceButton {
    return (UIButton *)objc_getAssociatedObject(self,&IP1ReferenceButtonKey);
}

- (void)ip1_updateReferenceButtonTitle {
    UIButton *button=[self ip1_referenceButton];
    if(!button) return;
    [button setTitle:([self ip1_savedReferencePage]>0?@"Ref•":@"Ref") forState:UIControlStateNormal];
}

- (void)ip1_reference_viewDidLoad {
    [self ip1_reference_viewDidLoad];
    if(objc_getAssociatedObject(self,&IP1ReferenceBarItemKey)) return;

    UIToolbar *toolbar=nil;
    for(UIView *v in self.view.subviews) {
        if([v isKindOfClass:[UIToolbar class]]) { toolbar=(UIToolbar *)v; break; }
    }
    if(!toolbar) return;

    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0,0,42.0f,30.0f);
    button.titleLabel.font=[UIFont boldSystemFontOfSize:12.0f];
    [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset=CGSizeMake(0,1);
    [button addTarget:self action:@selector(ip1_referenceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UILongPressGestureRecognizer *longPress=[[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(ip1_referenceButtonLongPressed:)] autorelease];
    longPress.minimumPressDuration=0.65;
    [button addGestureRecognizer:longPress];

    UIBarButtonItem *item=[[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    NSMutableArray *items=[NSMutableArray arrayWithArray:toolbar.items?:[NSArray array]];
    NSUInteger insertIndex=MIN((NSUInteger)3,[items count]);
    [items insertObject:item atIndex:insertIndex];
    toolbar.items=items;

    objc_setAssociatedObject(self,&IP1ReferenceBarItemKey,item,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self,&IP1ReferenceButtonKey,button,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self ip1_updateReferenceButtonTitle];
}

- (void)ip1_saveCurrentPageAsReference {
    NSUInteger page=[self ip1_currentPageNumber];
    NSString *key=[self ip1_referenceDefaultsKey];
    if(page<1 || !key) return;
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)page forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self ip1_updateReferenceButtonTitle];

    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Referans Sayfa"
                                               message:[NSString stringWithFormat:@"Sayfa %lu referans olarak kaydedildi.\n\nBaşka bir sayfayı referans yapmak için Ref düğmesine basılı tutun.",(unsigned long)page]
                                              delegate:nil
                                     cancelButtonTitle:@"Tamam"
                                     otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)ip1_referenceButtonLongPressed:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state==UIGestureRecognizerStateBegan) [self ip1_saveCurrentPageAsReference];
}

- (void)ip1_referenceButtonTapped:(id)sender {
    (void)sender;
    NSUInteger page=[self ip1_savedReferencePage];
    if(page==0) {
        [self ip1_saveCurrentPageAsReference];
        return;
    }

    NSString *path=[self ip1_pdfPathValue];
    if(![path length]) return;

    UIPopoverController *old=(UIPopoverController *)objc_getAssociatedObject(self,&IP1ReferencePopoverKey);
    if(old) {
        [old dismissPopoverAnimated:NO];
        objc_setAssociatedObject(self,&IP1ReferencePopoverKey,nil,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    ReferencePageViewController *vc=[[[ReferencePageViewController alloc] initWithPDFPath:path pageNumber:page] autorelease];
    vc.contentSizeForViewInPopover=CGSizeMake(520.0f,620.0f);
    UIPopoverController *popover=[[[UIPopoverController alloc] initWithContentViewController:vc] autorelease];
    popover.delegate=(id<UIPopoverControllerDelegate>)self;
    objc_setAssociatedObject(self,&IP1ReferencePopoverKey,popover,OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIBarButtonItem *item=(UIBarButtonItem *)objc_getAssociatedObject(self,&IP1ReferenceBarItemKey);
    if(item) [popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    UIPopoverController *stored=(UIPopoverController *)objc_getAssociatedObject(self,&IP1ReferencePopoverKey);
    if(stored==popoverController) objc_setAssociatedObject(self,&IP1ReferencePopoverKey,nil,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
