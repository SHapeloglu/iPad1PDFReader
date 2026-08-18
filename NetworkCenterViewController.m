#import "NetworkCenterViewController.h"
#import "URLImportViewController.h"
@implementation NetworkCenterViewController
- (void)viewDidLoad { [super viewDidLoad]; self.title=@"Ağ"; _types=[[NSArray alloc] initWithObjects:@"HTTP / HTTPS",@"FTP",@"WebDAV",@"SMB (opsiyonel)",@"SFTP (opsiyonel)",nil]; }
- (NSInteger)tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)s { return [_types count]; }
- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)i {
    static NSString *cid=@"net"; UITableViewCell *c=[t dequeueReusableCellWithIdentifier:cid];
    if(!c)c=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid] autorelease];
    c.textLabel.text=[_types objectAtIndex:i.row];
    c.detailTextLabel.text=(i.row==3)?@"libsmb2 gerekir":((i.row==4)?@"libssh2 gerekir":@"Yerleşik bağlantı");
    return c;
}
- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)i {
    if(i.row<=1) [self.navigationController pushViewController:[[[URLImportViewController alloc] init] autorelease] animated:YES];
    else if(i.row==2) {
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"WebDAV URL" message:nil delegate:self cancelButtonTitle:@"İptal" otherButtonTitles:@"Listele",nil] autorelease];
        a.alertViewStyle=UIAlertViewStylePlainTextInput; a.tag=70; [a show];
    } else {
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Opsiyonel Connector" message:@"SMB/SFTP iOS 5'te yerleşik değildir; libsmb2/libssh2 ayrıca linklenmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease]; [a show];
    }
}
- (void)alertView:(UIAlertView *)a clickedButtonAtIndex:(NSInteger)b {
    if(a.tag==70&&b==1){ NSURL *u=[NSURL URLWithString:[[a textFieldAtIndex:0] text]]; if(!u)return; [_webdav release]; _webdav=[[WebDAVClient alloc] init]; _webdav.delegate=self; [_webdav listURL:u]; }
}
- (void)webDAVClientFinishedData:(NSData *)data status:(NSInteger)status error:(NSError *)error {
    NSString *m=error?[error localizedDescription]:[NSString stringWithFormat:@"HTTP %ld - %lu byte",(long)status,(unsigned long)[data length]];
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"WebDAV" message:m delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease]; [a show];
}
- (void)dealloc { [_types release]; [_webdav release]; [super dealloc]; }
@end
