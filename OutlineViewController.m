#import "OutlineViewController.h"
@implementation OutlineViewController
@synthesize delegate=_delegate;
- (id)initWithItems:(NSArray*)i{if((self=[super initWithStyle:UITableViewStylePlain])){_items=[i copy];self.title=@"İçindekiler";}return self;}
- (NSInteger)tableView:(UITableView*)t numberOfRowsInSection:(NSInteger)s{return [_items count];}
- (UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i{
    static NSString*cid=@"o";
    UITableViewCell*c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)c=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid]autorelease];
    NSDictionary*d=[_items objectAtIndex:i.row];
    c.indentationLevel=[[d objectForKey:@"depth"]intValue];
    c.textLabel.text=[d objectForKey:@"title"];
    NSNumber *page=[d objectForKey:@"page"];
    c.detailTextLabel.text=page?[NSString stringWithFormat:@"Sayfa %@",page]:@"Sayfa hedefi çözülemedi";
    c.accessoryType=page?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    c.selectionStyle=page?UITableViewCellSelectionStyleBlue:UITableViewCellSelectionStyleNone;
    return c;
}
- (void)tableView:(UITableView*)t didSelectRowAtIndexPath:(NSIndexPath*)i{
    NSDictionary*d=[_items objectAtIndex:i.row];
    NSNumber *page=[d objectForKey:@"page"];
    if(!page)return;
    NSUInteger p=[page unsignedIntegerValue];
    if([_delegate respondsToSelector:@selector(outlineControllerSelectedPage:)])[_delegate outlineControllerSelectedPage:p];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc{[_items release];[super dealloc];}
@end
