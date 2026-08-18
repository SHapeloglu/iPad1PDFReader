#import "OutlineViewController.h"
@implementation OutlineViewController
- (id)initWithItems:(NSArray*)i{if((self=[super initWithStyle:UITableViewStylePlain])){_items=[i copy];self.title=@"İçindekiler";}return self;}
- (NSInteger)tableView:(UITableView*)t numberOfRowsInSection:(NSInteger)s{return [_items count];}
- (UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i{static NSString*cid=@"o";UITableViewCell*c=[t dequeueReusableCellWithIdentifier:cid];if(!c)c=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid]autorelease];NSDictionary*d=[_items objectAtIndex:i.row];c.indentationLevel=[[d objectForKey:@"depth"]intValue];c.textLabel.text=[d objectForKey:@"title"];return c;}
- (void)dealloc{[_items release];[super dealloc];}
@end
