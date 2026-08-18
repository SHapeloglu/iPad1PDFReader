#import "PDFLibraryViewController.h"
#import "PDFReaderViewController.h"
#import "RecentStore.h"
#import "NetworkCenterViewController.h"
@implementation PDFLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"PDF Dosyaları";
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Ağ" style:UIBarButtonItemStylePlain target:self action:@selector(showNetwork)] autorelease];
    _emptyLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    _emptyLabel.textAlignment=UITextAlignmentCenter;
    _emptyLabel.numberOfLines=0;
    _emptyLabel.backgroundColor=[UIColor clearColor];
    _emptyLabel.text=@"Henüz PDF yok.\n\niPad1Files/Downloads veya PDFs klasörüne PDF koyun\nya da iTunes File Sharing kullanın.";
    [self.tableView addSubview:_emptyLabel];
    [self reloadPDFList];
}

- (void)viewWillAppear:(BOOL)a { [super viewWillAppear:a]; [self reloadPDFList]; }
- (void)viewDidLayoutSubviews { [super viewDidLayoutSubviews]; _emptyLabel.frame=CGRectMake(30,120,self.tableView.bounds.size.width-60,180); }
- (NSString *)documentsDirectory { NSArray *p=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES); return [p count]?[p objectAtIndex:0]:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]; }

- (void)addPDFsFromDirectory:(NSString *)directory source:(NSString *)source toArray:(NSMutableArray *)out {
    BOOL isDir=NO;
    if(![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir]||!isDir)return;
    NSArray *names=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    for(NSString *name in names){
        if(![[[name pathExtension] lowercaseString] isEqualToString:@"pdf"])continue;
        NSString *path=[directory stringByAppendingPathComponent:name];
        [out addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",path,@"path",source,@"source",nil]];
    }
}

- (void)reloadPDFList {
    NSString *documents=[self documentsDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:documents withIntermediateDirectories:YES attributes:nil error:nil];
    NSMutableArray *items=[NSMutableArray array];
    [self addPDFsFromDirectory:documents source:@"Uygulama" toArray:items];
    [self addPDFsFromDirectory:@"/var/mobile/Media/iPad1Files/PDFs" source:@"iPad1Files/PDFs" toArray:items];
    [self addPDFsFromDirectory:@"/var/mobile/Media/iPad1Files/Downloads" source:@"iPad1Files/Downloads" toArray:items];
    [items sortUsingComparator:^NSComparisonResult(id a,id b){return [[[a objectForKey:@"name"] lowercaseString] compare:[[b objectForKey:@"name"] lowercaseString]];}];
    [_pdfFiles release];
    _pdfFiles=[items copy];
    _emptyLabel.hidden=[items count]>0;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s { return [_pdfFiles count]; }
- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"pdf";
    UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];
    NSDictionary *item=[_pdfFiles objectAtIndex:i.row];
    NSString *name=[item objectForKey:@"name"];
    NSString *path=[item objectForKey:@"path"];
    NSDictionary *attrs=[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    c.textLabel.text=[name stringByDeletingPathExtension];
    c.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@ %.1f MB",[RecentStore isFavoritePath:path]?@"★":@"",[item objectForKey:@"source"],[[attrs objectForKey:NSFileSize] doubleValue]/1048576.0];
    c.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return c;
}

- (BOOL)openPDFAtPath:(NSString *)path {
    if(!path||![[[path pathExtension] lowercaseString] isEqualToString:@"pdf"]||![[NSFileManager defaultManager] fileExistsAtPath:path])return NO;
    [RecentStore touchPath:path];
    [self.navigationController pushViewController:[[[PDFReaderViewController alloc] initWithPDFPath:path] autorelease] animated:YES];
    return YES;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    NSDictionary *item=[_pdfFiles objectAtIndex:i.row];
    [self openPDFAtPath:[item objectForKey:@"path"]];
}

- (void)showNetwork { [self.navigationController pushViewController:[[[NetworkCenterViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease] animated:YES]; }

- (void)importExternalPDFURL:(NSURL *)url {
    if(!url)return;
    if([[url scheme] isEqualToString:@"ipad1pdf"]){
        NSString *path=nil;
        NSString *query=[url query];
        for(NSString *pair in [query componentsSeparatedByString:@"&"]){
            NSArray *parts=[pair componentsSeparatedByString:@"="];
            if([parts count]>=2&&[[parts objectAtIndex:0] isEqualToString:@"path"]){
                NSString *encoded=[[parts subarrayWithRange:NSMakeRange(1,[parts count]-1)] componentsJoinedByString:@"="];
                path=[encoded stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                break;
            }
        }
        [self openPDFAtPath:path];
        return;
    }
    if(![url isFileURL])return;
    NSString *source=[url path];
    if([self openPDFAtPath:source])return;
    NSString *dst=[[self documentsDirectory] stringByAppendingPathComponent:[source lastPathComponent]];
    if(![source isEqualToString:dst])[[NSFileManager defaultManager] copyItemAtPath:source toPath:dst error:nil];
    [self reloadPDFList];
}

- (void)dealloc { [_pdfFiles release]; [_emptyLabel release]; [_actionIndexPath release]; [super dealloc]; }
@end
