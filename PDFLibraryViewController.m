#import "PDFLibraryViewController.h"
#import "PDFReaderViewController.h"
#import "PDFReaderViewController+Handoff.h"
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
    NSSortDescriptor *sort=[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    [items sortUsingDescriptors:[NSArray arrayWithObject:sort]];
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

- (void)showPDFOpenError:(NSString *)message {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"PDF açılamadı" message:message delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)prepareOpenReaderForReplacement {
    NSArray *stack=self.navigationController.viewControllers;
    for(NSInteger i=(NSInteger)[stack count]-1;i>=0;i--){
        UIViewController *vc=[stack objectAtIndex:(NSUInteger)i];
        if([vc isKindOfClass:[PDFReaderViewController class]]){
            [(PDFReaderViewController *)vc prepareForExternalPDFHandoff];
            break;
        }
    }
}

- (BOOL)openPDFAtPath:(NSString *)path {
    if(!path||![path hasPrefix:@"/"]){[self showPDFOpenError:@"Geçersiz PDF yolu."];return NO;}
    if(![[[path pathExtension] lowercaseString] isEqualToString:@"pdf"]){[self showPDFOpenError:@"Dosya bir PDF değil."];return NO;}
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){[self showPDFOpenError:@"PDF bulunamadı."];return NO;}

    [RecentStore touchPath:path];

    /* Warm-start handoff: explicitly drop the active page/document even if a
       reader-owned tool screen is currently on top of the navigation stack. */
    [self prepareOpenReaderForReplacement];
    if(self.navigationController.topViewController!=self)
        [self.navigationController popToViewController:self animated:NO];

    PDFReaderViewController *reader=[[[PDFReaderViewController alloc] initWithPDFPath:path] autorelease];
    [self.navigationController pushViewController:reader animated:YES];
    return YES;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    NSDictionary *item=[_pdfFiles objectAtIndex:i.row];
    [self openPDFAtPath:[item objectForKey:@"path"]];
}

- (void)showNetwork { [self.navigationController pushViewController:[[[NetworkCenterViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease] animated:YES]; }

- (BOOL)isStableDirectPath:(NSString *)path {
    if([path hasPrefix:@"/var/mobile/Media/iPad1Files/"])return YES;
    if([path hasPrefix:[self documentsDirectory]])return YES;
    return NO;
}

- (NSString *)decodedPDFPathFromHandoffURL:(NSURL *)url {
    if(!url)return nil;
    if(![[[url scheme] lowercaseString] isEqualToString:@"ipad1pdf"])return nil;
    if(![[[url host] lowercaseString] isEqualToString:@"open"])return nil;

    NSString *query=[url query];
    if(!query||[query length]==0)return nil;
    for(NSString *pair in [query componentsSeparatedByString:@"&"]){
        NSRange equals=[pair rangeOfString:@"="];
        if(equals.location==NSNotFound)continue;
        NSString *key=[pair substringToIndex:equals.location];
        if(![key isEqualToString:@"path"])continue;
        NSString *encoded=[pair substringFromIndex:equals.location+1];
        NSString *decoded=[encoded stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return decoded;
    }
    return nil;
}

- (void)importExternalPDFURL:(NSURL *)url {
    if(!url)return;

    if([[[url scheme] lowercaseString] isEqualToString:@"ipad1pdf"]){
        if(![[[url host] lowercaseString] isEqualToString:@"open"]){[self showPDFOpenError:@"Geçersiz PDF açma isteği."];return;}
        NSString *path=[self decodedPDFPathFromHandoffURL:url];
        if(!path||[path length]==0){[self showPDFOpenError:@"PDF yolu belirtilmedi."];return;}
        [self openPDFAtPath:path];
        return;
    }

    if(![url isFileURL])return;
    NSString *source=[url path];

    /* Shared/canonical files are always opened in place. Never duplicate
       iPad1Files/FTPDownloader handoff files into the app sandbox. */
    if([self isStableDirectPath:source]){[self openPDFAtPath:source];return;}

    /* Ordinary external Open In files may need a persistent app-owned copy. */
    NSString *dst=[[self documentsDirectory] stringByAppendingPathComponent:[source lastPathComponent]];
    if(![source isEqualToString:dst])[[NSFileManager defaultManager] copyItemAtPath:source toPath:dst error:nil];
    [self reloadPDFList];
    [self openPDFAtPath:dst];
}

- (void)dealloc { [_pdfFiles release]; [_emptyLabel release]; [_actionIndexPath release]; [super dealloc]; }
@end
