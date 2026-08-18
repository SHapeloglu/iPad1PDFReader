#import "SearchViewController.h"
#import "PDFTextExtractor.h"
#import "MemoryBudget.h"

@implementation SearchViewController
@synthesize delegate=_delegate;

- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithStyle:UITableViewStylePlain])) {
        _pdfPath=[path copy];
        _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        _searchPageCount=_document?CGPDFDocumentGetNumberOfPages(_document):0;
        self.title=@"PDF Ara";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    _searchBar.delegate=self;
    self.tableView.tableHeaderView=_searchBar;

    _progressLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,34)];
    _progressLabel.textAlignment=UITextAlignmentCenter;
    _progressLabel.font=[UIFont systemFontOfSize:13.0f];
    _progressLabel.textColor=[UIColor darkGrayColor];
    _progressLabel.backgroundColor=[UIColor clearColor];
    _progressLabel.text=@"Arama terimi girin.";
    self.tableView.tableFooterView=_progressLabel;
}

- (void)cancelSearch {
    _cancelRequested=YES;
    self.navigationItem.rightBarButtonItem=nil;
}

- (void)finishSearchWithText:(NSString *)text {
    _searching=NO;
    _cancelRequested=NO;
    self.navigationItem.rightBarButtonItem=nil;
    _progressLabel.text=text;
    [_searchBar setUserInteractionEnabled:YES];
}

- (void)processNextPage {
    if(!_searching)return;
    if(_cancelRequested){
        [self finishSearchWithText:[NSString stringWithFormat:@"İptal edildi — %lu sonuç",(unsigned long)[_results count]]];
        return;
    }
    if(_searchPage>_searchPageCount || [_results count]>=IPAD1_SEARCH_MAX_RESULTS){
        [self finishSearchWithText:[NSString stringWithFormat:@"Tamamlandı — %lu sonuç",(unsigned long)[_results count]]];
        return;
    }

    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    CGPDFPageRef page=CGPDFDocumentGetPage(_document,_searchPage);
    NSString *text=[PDFTextExtractor textForPage:page];
    NSRange r=[text rangeOfString:_activeTerm options:NSCaseInsensitiveSearch];
    if(r.location!=NSNotFound) {
        NSUInteger start=(r.location>50)?r.location-50:0;
        NSUInteger end=MIN([text length],NSMaxRange(r)+80);
        NSString *snippet=[text substringWithRange:NSMakeRange(start,end-start)];
        snippet=[snippet stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSDictionary *row=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithUnsignedInteger:_searchPage],@"page",
                           snippet,@"snippet",nil];
        [_results addObject:row];
    }
    [pool drain];

    _progressLabel.text=[NSString stringWithFormat:@"Aranıyor: %lu / %lu — %lu sonuç",
                         (unsigned long)_searchPage,(unsigned long)_searchPageCount,(unsigned long)[_results count]];
    _searchPage++;
    [self.tableView reloadData];
    [self performSelector:@selector(processNextPage) withObject:nil afterDelay:0.0];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)s {
    NSString *term=[s.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([term length]==0)return;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(processNextPage) object:nil];
    [_activeTerm release]; _activeTerm=[term copy];
    [_results release]; _results=[[NSMutableArray alloc] init];
    _searchPage=1;
    _searching=YES;
    _cancelRequested=NO;
    [_searchBar setUserInteractionEnabled:NO];
    [s resignFirstResponder];

    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"İptal" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSearch)] autorelease];
    _progressLabel.text=[NSString stringWithFormat:@"Aranıyor: 0 / %lu",(unsigned long)_searchPageCount];
    [self.tableView reloadData];
    [self performSelector:@selector(processNextPage) withObject:nil afterDelay:0.0];
}

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section { return [_results count]; }

- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"search";
    UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];
    NSDictionary *r=[_results objectAtIndex:i.row];
    c.textLabel.text=[NSString stringWithFormat:@"Sayfa %@",[r objectForKey:@"page"]];
    c.detailTextLabel.text=[r objectForKey:@"snippet"];
    c.detailTextLabel.numberOfLines=2;
    return c;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    NSUInteger p=[[[_results objectAtIndex:i.row] objectForKey:@"page"] unsignedIntegerValue];
    if([_delegate respondsToSelector:@selector(searchControllerSelectedPage:)])[_delegate searchControllerSelectedPage:p];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _cancelRequested=YES;
    [_results release]; _results=nil;
    [self.tableView reloadData];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_pdfPath release];
    [_results release];
    [_searchBar release];
    [_progressLabel release];
    [_activeTerm release];
    if(_document)CGPDFDocumentRelease(_document);
    [super dealloc];
}
@end
