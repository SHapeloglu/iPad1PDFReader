#import "PDFLibraryViewController.h"
#import "PDFReaderViewController.h"
#import "RecentStore.h"
#import "NetworkCenterViewController.h"
@implementation PDFLibraryViewController
- (void)viewDidLoad {
    [super viewDidLoad]; self.title=@"PDF Dosyaları";
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Ağ" style:UIBarButtonItemStylePlain target:self action:@selector(showNetwork)] autorelease];
    _emptyLabel=[[UILabel alloc] initWithFrame:CGRectZero]; _emptyLabel.textAlignment=NSTextAlignmentCenter; _emptyLabel.numberOfLines=0; _emptyLabel.backgroundColor=[UIColor clearColor];
    _emptyLabel.text=@"Henüz PDF yok.\n\nAğ düğmesiyle HTTP/FTP/WebDAV kullanın\nveya iTunes File Sharing ile PDF kopyalayın.";
    [self.tableView addSubview:_emptyLabel]; [self reloadPDFList];
}
- (void)viewWillAppear:(BOOL)a { [super viewWillAppear:a]; [self reloadPDFList]; }
- (void)viewDidLayoutSubviews { [super viewDidLayoutSubviews]; _emptyLabel.frame=CGRectMake(30,120,self.tableView.bounds.size.width-60,180); }
- (NSString *)documentsDirectory { NSArray *p=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES); return [p count]?[p objectAtIndex:0]:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]; }
- (void)reloadPDFList { NSString *d=[self documentsDirectory]; [[NSFileManager defaultManager] createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil]; NSArray *a=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:d error:nil]; NSMutableArray *m=[NSMutableArray array]; for(NSString *n in a)if([[[n pathExtension] lowercaseString] isEqualToString:@"pdf"])[m addObject:n]; [m sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; [_pdfFiles release]; _pdfFiles=[m copy]; _emptyLabel.hidden=[m count]>0; [self.tableView reloadData]; }
- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s { return [_pdfFiles count]; }
- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i { static NSString *cid=@"pdf"; UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid]; if(!c)c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease]; NSString *n=[_pdfFiles objectAtIndex:i.row]; NSString *p=[[self documentsDirectory] stringByAppendingPathComponent:n]; NSDictionary *a=[[NSFileManager defaultManager] attributesOfItemAtPath:p error:nil]; c.textLabel.text=[n stringByDeletingPathExtension]; c.detailTextLabel.text=[NSString stringWithFormat:@"%@ %.1f MB",[RecentStore isFavoritePath:p]?@"★":@"",[[a objectForKey:NSFileSize] doubleValue]/1048576.0]; c.accessoryType=UITableViewCellAccessoryDisclosureIndicator; return c; }
- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i { NSString *p=[[self documentsDirectory] stringByAppendingPathComponent:[_pdfFiles objectAtIndex:i.row]]; [RecentStore touchPath:p]; [self.navigationController pushViewController:[[[PDFReaderViewController alloc] initWithPDFPath:p] autorelease] animated:YES]; }
- (void)showNetwork { [self.navigationController pushViewController:[[[NetworkCenterViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease] animated:YES]; }
- (void)importExternalPDFURL:(NSURL *)url { if(![url isFileURL])return; NSString *dst=[[self documentsDirectory] stringByAppendingPathComponent:[[url path] lastPathComponent]]; if(![[url path] isEqualToString:dst])[[NSFileManager defaultManager] copyItemAtPath:[url path] toPath:dst error:nil]; [self reloadPDFList]; }
- (void)dealloc { [_pdfFiles release]; [_emptyLabel release]; [_actionIndexPath release]; [super dealloc]; }
@end
