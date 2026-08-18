#import "SearchViewController.h"
#import "PDFTextExtractor.h"
#import "MemoryBudget.h"

@implementation SearchViewController
@synthesize delegate=_delegate;

- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithStyle:UITableViewStylePlain])) {
        _pdfPath=[path copy];
        _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        self.title=@"PDF Ara";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    _searchBar.delegate=self;
    self.tableView.tableHeaderView=_searchBar;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)s {
    [_results release];
    _results=[[PDFTextExtractor searchTerm:s.text
                                inDocument:_document
                                maxResults:IPAD1_SEARCH_MAX_RESULTS] retain];

    [self.tableView reloadData];
    [s resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}

- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"search";
    UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)
        c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];

    NSDictionary *r=[_results objectAtIndex:i.row];
    c.textLabel.text=[NSString stringWithFormat:@"Sayfa %@",[r objectForKey:@"page"]];
    c.detailTextLabel.text=[r objectForKey:@"snippet"];
    c.detailTextLabel.numberOfLines=2;
    return c;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    NSUInteger p=[[[_results objectAtIndex:i.row] objectForKey:@"page"] unsignedIntegerValue];
    if([_delegate respondsToSelector:@selector(searchControllerSelectedPage:)])
        [_delegate searchControllerSelectedPage:p];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_results release];
    _results=nil;
    [self.tableView reloadData];
}

- (void)dealloc {
    [_pdfPath release];
    [_results release];
    [_searchBar release];
    if(_document) CGPDFDocumentRelease(_document);
    [super dealloc];
}
@end
