#import "WebDAVClient.h"
@implementation WebDAVClient
@synthesize delegate=_delegate;
- (void)start:(NSMutableURLRequest *)r {
    [_data release]; _data=[[NSMutableData alloc] init];
    [_connection cancel]; [_connection release];
    _connection=[[NSURLConnection alloc] initWithRequest:r delegate:self startImmediately:YES];
}
- (void)listURL:(NSURL *)url {
    NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [r setHTTPMethod:@"PROPFIND"]; [r setValue:@"1" forHTTPHeaderField:@"Depth"];
    [r setHTTPBody:[@"<?xml version=\"1.0\"?><propfind xmlns=\"DAV:\"><prop><displayname/><getcontentlength/><resourcetype/></prop></propfind>" dataUsingEncoding:NSUTF8StringEncoding]];
    [self start:r];
}
- (void)downloadURL:(NSURL *)url {
    NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [r setHTTPMethod:@"GET"]; [self start:r];
}
- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)r { if([r isKindOfClass:[NSHTTPURLResponse class]])_status=[(NSHTTPURLResponse *)r statusCode]; }
- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)d { [_data appendData:d]; }
- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)e { if([_delegate respondsToSelector:@selector(webDAVClientFinishedData:status:error:)])[_delegate webDAVClientFinishedData:nil status:_status error:e]; }
- (void)connectionDidFinishLoading:(NSURLConnection *)c { if([_delegate respondsToSelector:@selector(webDAVClientFinishedData:status:error:)])[_delegate webDAVClientFinishedData:_data status:_status error:nil]; }
- (void)dealloc { [_connection cancel]; [_connection release]; [_data release]; [super dealloc]; }
@end
