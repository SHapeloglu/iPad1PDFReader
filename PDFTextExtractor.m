#import "PDFTextExtractor.h"
typedef struct { NSMutableString *text; } PDFTextState;

static void AppendPDFString(CGPDFStringRef pdfString, PDFTextState *state) {
    if(!pdfString || !state) return;
    CFStringRef s=CGPDFStringCopyTextString(pdfString);
    if(s) {
        [state->text appendString:(NSString *)s];
        [state->text appendString:@" "];
        CFRelease(s);
    }
}
static void Op_Tj(CGPDFScannerRef scanner, void *info) {
    CGPDFStringRef s=NULL;
    if(CGPDFScannerPopString(scanner,&s)) AppendPDFString(s,(PDFTextState *)info);
}
static void Op_TJ(CGPDFScannerRef scanner, void *info) {
    CGPDFArrayRef a=NULL;
    if(!CGPDFScannerPopArray(scanner,&a)) return;
    size_t n=CGPDFArrayGetCount(a);
    for(size_t i=0;i<n;i++) {
        CGPDFStringRef s=NULL;
        if(CGPDFArrayGetString(a,i,&s)) AppendPDFString(s,(PDFTextState *)info);
    }
}
@implementation PDFTextExtractor
+ (NSString *)textForPage:(CGPDFPageRef)page {
    if(!page) return @"";
    NSMutableString *out=[NSMutableString string];
    PDFTextState state; state.text=out;
    CGPDFOperatorTableRef table=CGPDFOperatorTableCreate();
    CGPDFOperatorTableSetCallback(table,"Tj",Op_Tj);
    CGPDFOperatorTableSetCallback(table,"TJ",Op_TJ);
    CGPDFContentStreamRef stream=CGPDFContentStreamCreateWithPage(page);
    CGPDFScannerRef scanner=CGPDFScannerCreate(stream,table,&state);
    CGPDFScannerScan(scanner);
    CGPDFScannerRelease(scanner);
    CGPDFContentStreamRelease(stream);
    CGPDFOperatorTableRelease(table);
    return out;
}
+ (NSArray *)searchTerm:(NSString *)term inDocument:(CGPDFDocumentRef)document maxResults:(NSUInteger)maxResults {
    if(!document || !term || [term length]==0) return [NSArray array];
    NSMutableArray *results=[NSMutableArray array];
    size_t count=CGPDFDocumentGetNumberOfPages(document);
    for(size_t i=1;i<=count && [results count]<maxResults;i++) {
        NSString *text=[self textForPage:CGPDFDocumentGetPage(document,i)];
        NSRange r=[text rangeOfString:term options:NSCaseInsensitiveSearch];
        if(r.location!=NSNotFound) {
            NSUInteger st=(r.location>50)?r.location-50:0;
            NSUInteger en=MIN([text length],NSMaxRange(r)+80);
            NSString *snippet=[text substringWithRange:NSMakeRange(st,en-st)];
            snippet=[snippet stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            [results addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithUnsignedInteger:i],@"page",
                snippet,@"snippet",nil]];
        }
    }
    return results;
}
@end
