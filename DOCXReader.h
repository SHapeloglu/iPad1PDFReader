#import <Foundation/Foundation.h>

@interface DOCXReader : NSObject <NSXMLParserDelegate> {
    NSString *_plainText;
    NSArray *_styles;
    NSMutableString *_workingText;
    NSMutableArray *_workingStyles;
    NSMutableString *_textBuffer;
    BOOL _inText;
    BOOL _runBold;
    BOOL _runItalic;
    BOOL _paragraphHasText;
    BOOL _paragraphIsList;
    BOOL _inTable;
    BOOL _inCell;
    NSUInteger _headingLevel;
    NSUInteger _cellStartLength;
}
@property(nonatomic,readonly) NSString *plainText;
@property(nonatomic,readonly) NSArray *styles;
+ (unsigned long long)maximumSafeCompressedSize;
+ (NSUInteger)maximumSafeXMLSize;
- (BOOL)loadDOCXAtPath:(NSString *)path error:(NSError **)error;
@end
