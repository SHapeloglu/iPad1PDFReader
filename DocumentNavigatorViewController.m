#import "DocumentNavigatorViewController.h"
#import "BookmarkStore.h"
#import "AnnotationStore.h"

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
    NSUInteger bookmarkCount=MIN((NSUInteger)40,[bookmarks count]);
    for(NSUInteger i=0;i<bookmarkCount;i++) {
        NSNumber *p=[bookmarks objectAtIndex:i];
        [bookmarkRows addObject:[NSDictionary dictionaryWithObjectsAndKeys:p,@"page",@"Yer İmi",@"kind",nil]];
    }

    NSMutableArray *noteRows=[NSMutableArray array];
    NSMutableArray *highlightRows=[NSMutableArray array];
    NSUInteger total=0;
    for(NSUInteger page=1;page<=_pageCount && total<80;page++) {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        NSArray *anns=[AnnotationStore annotationsForPath:_pdfPath page:page];
        for(NSDictionary *a in anns) {
            NSString *type=[a objectForKey:@"type"];
            if([type isEqualToString:@"note"] && [noteRows count]<40) {
                NSString *text=[a objectForKey:@"text"];
                if(!text||[text length]==0) text=@"(boş not)";
                if([text length]>60) text=[NSString stringWithFormat:@"%@…",[text substringToIndex:60]];
                [noteRows addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:page],@"page",text,@"detail",@"Not",@"kind",nil]];
                total++;
            } else if([type isEqualToString:@"highlight"] && [highlightRows count]<40) {
                [highlightRows addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:page],@"page",@"Highlight",@"kind",nil]];
                total++;
            }
            if(total>=80) break;
        }
        [pool drain];
    }

    [_sections release];
    _sections=[[NSArray alloc] initWithObjects:bookmarkRows,noteRows,highlightRows,nil];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 3; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [[_sections objectAtIndex:section] count]; }
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0)return @"Yer İmleri";
    if(section==1)return @"Notlar";
    return @"Highlight'lar";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section==2)return @"iPad 1 bellek güvenliği için toplam özet 80 kayıtla sınırlıdır.";
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
    NSDictionary *row=[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSUInteger page=[[row objectForKey:@"page"] unsignedIntegerValue];
    if([_delegate respondsToSelector:@selector(documentNavigatorSelectedPage:)])[_delegate documentNavigatorSelectedPage:page];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_sections release]; _sections=nil;
}
- (void)dealloc {
    [_pdfPath release];
    [_sections release];
    [super dealloc];
}
@end
