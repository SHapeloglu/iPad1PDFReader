#import "DocumentNavigatorViewController.h"
#import "BookmarkStore.h"
#import "AnnotationStore.h"
#import "MemoryBudget.h"

@implementation DocumentNavigatorViewController
@synthesize delegate=_delegate;

- (id)initWithPDFPath:(NSString *)path pageCount:(NSUInteger)pageCount {
    if((self=[super initWithStyle:UITableViewStyleGrouped])) {
        _pdfPath=[path copy];
        _pageCount=pageCount;
        self.title=@"Belge";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableArray *bookmarkRows=[NSMutableArray array];
    NSArray *bookmarks=[BookmarkStore bookmarksForPath:_pdfPath];
    NSUInteger bookmarkCount=MIN((NSUInteger)IPAD1_NAVIGATOR_MAX_PER_KIND,[bookmarks count]);
    for(NSUInteger i=0;i<bookmarkCount;i++) {
        NSNumber *p=[bookmarks objectAtIndex:i];
        [bookmarkRows addObject:[NSDictionary dictionaryWithObjectsAndKeys:p,@"page",@"Yer İmi",@"kind",nil]];
    }

    NSMutableArray *noteRows=[NSMutableArray array];
    NSMutableArray *highlightRows=[NSMutableArray array];
    NSUInteger total=0;
    for(NSUInteger page=1;page<=_pageCount && total<IPAD1_NAVIGATOR_MAX_ITEMS;page++) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:page];
        for(NSDictionary *a in anns) {
            NSString *type=[a objectForKey:@"type"];
            if([type isEqualToString:@"note"] && [noteRows count]<IPAD1_NAVIGATOR_MAX_PER_KIND) {
                NSString *text=[a objectForKey:@"text"];
                if(!text||[text length]==0) text=@"(boş not)";
                if([text length]>60) text=[NSString stringWithFormat:@"%@…",[text substringToIndex:60]];
                [noteRows addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:page],@"page",text,@"detail",@"Not",@"kind",nil]];
                total++;
            } else if([type isEqualToString:@"highlight"] && [highlightRows count]<IPAD1_NAVIGATOR_MAX_PER_KIND) {
                [highlightRows addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:page],@"page",@"Highlight",@"kind",nil]];
                total++;
            }
            if(total>=IPAD1_NAVIGATOR_MAX_ITEMS) break;
        }
        [pool drain];
    }

    [_sections release];
    _sections=[[NSArray alloc] initWithObjects:bookmarkRows,noteRows,highlightRows,nil];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 3; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!_sections||section<0||(NSUInteger)section>=[_sections count])return 0;
    return [[_sections objectAtIndex:section] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0)return @"Yer İmleri";
    if(section==1)return @"Notlar";
    return @"Highlight'lar";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section==2)return [NSString stringWithFormat:@"iPad 1 bellek güvenliği için özet en fazla %d kayıt tutar.",IPAD1_NAVIGATOR_MAX_ITEMS];
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cid=@"navrow";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cid];
    if(!cell)cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];
    NSDictionary *row=[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSNumber *page=[row objectForKey:@"page"];
    cell.textLabel.text=[NSString stringWithFormat:@"%@ — Sayfa %@",[row objectForKey:@"kind"],page];
    cell.detailTextLabel.text=[row objectForKey:@"detail"];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!_sections)return;
    NSDictionary *row=[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSUInteger page=[[row objectForKey:@"page"] unsignedIntegerValue];
    if([_delegate respondsToSelector:@selector(documentNavigatorSelectedPage:)])[_delegate documentNavigatorSelectedPage:page];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(!self.view.window){[_sections release];_sections=nil;}
}
- (void)dealloc {
    [_pdfPath release];
    [_sections release];
    [super dealloc];
}
@end
