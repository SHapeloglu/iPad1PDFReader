#import <Foundation/Foundation.h>
@protocol WebDAVClientDelegate <NSObject>
- (void)webDAVClientFinishedData:(NSData *)data status:(NSInteger)status error:(NSError *)error;
@end
@interface WebDAVClient : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate> {
    NSMutableData *_data; NSURLConnection *_connection; id<WebDAVClientDelegate> _delegate; NSInteger _status;
}
@property (nonatomic, assign) id<WebDAVClientDelegate> delegate;
- (void)listURL:(NSURL *)url;
- (void)downloadURL:(NSURL *)url;
@end
