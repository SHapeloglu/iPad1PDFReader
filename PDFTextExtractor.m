#import "PDFTextExtractor.h"

typedef struct {
    NSMutableString *text;
    NSMutableArray *rects;
    NSUInteger maxRects;
    CGPDFPageRef page;
    CGRect mediaBox;
    CGAffineTransform textMatrix;
    CGAffineTransform lineMatrix;
    CGFloat fontSize;
    CGFloat leading;
    CGFloat horizontalScale;
    CGFloat rise;
} PDFTextState;

static void AppendPDFString(CGPDFStringRef pdfString, PDFTextState *state) {
    if(!pdfString || !state) return;
    CFStringRef s=CGPDFStringCopyTextString(pdfString);
    if(s) {
        [state->text appendString:(NSString *)s];
        [state->text appendString:@" "];
        CFRelease(s);
    }
}

static CGFloat ApproximateStringWidth(CGPDFStringRef pdfString, PDFTextState *state) {
    if(!pdfString || !state) return 0.0f;
    CFStringRef s=CGPDFStringCopyTextString(pdfString);
    if(!s) return 0.0f;
    CFIndex length=CFStringGetLength(s);
    CFRelease(s);
    if(length<=0) return 0.0f;
    CGFloat scale=(state->horizontalScale>0.0f?state->horizontalScale:1.0f);
    return MAX(state->fontSize*0.35f,(CGFloat)length*state->fontSize*0.50f*scale);
}

static void AddTextRectForString(CGPDFStringRef pdfString, PDFTextState *state) {
    if(!state || !state->rects || [state->rects count]>=state->maxRects) return;
    CGFloat width=ApproximateStringWidth(pdfString,state);
    CGFloat height=MAX(4.0f,state->fontSize);
    if(width<=0.0f) return;

    CGRect local=CGRectMake(0.0f,state->rise,width,height);
    CGRect pdfRect=CGRectApplyAffineTransform(local,state->textMatrix);
    if(CGRectIsNull(pdfRect)||CGRectIsInfinite(pdfRect)||pdfRect.size.width<=0.0f||pdfRect.size.height<=0.0f) return;

    CGFloat displayW=state->mediaBox.size.width;
    CGFloat displayH=state->mediaBox.size.height;
    int rotation=CGPDFPageGetRotationAngle(state->page);
    if(rotation==90||rotation==270){CGFloat q=displayW;displayW=displayH;displayH=q;}
    if(displayW<=0.0f||displayH<=0.0f) return;

    CGRect target=CGRectMake(0,0,displayW,displayH);
    CGAffineTransform pageTransform=CGPDFPageGetDrawingTransform(state->page,kCGPDFMediaBox,target,0,true);
    CGRect mapped=CGRectApplyAffineTransform(pdfRect,pageTransform);
    CGRect normalized=CGRectMake(mapped.origin.x/displayW,
                                 (displayH-CGRectGetMaxY(mapped))/displayH,
                                 mapped.size.width/displayW,
                                 mapped.size.height/displayH);
    normalized=CGRectIntersection(CGRectMake(0,0,1,1),normalized);
    if(!CGRectIsNull(normalized)&&normalized.size.width>0.001f&&normalized.size.height>0.001f)
        [state->rects addObject:NSStringFromCGRect(normalized)];

    state->textMatrix=CGAffineTransformTranslate(state->textMatrix,width,0.0f);
}

static void Op_BT(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    state->textMatrix=CGAffineTransformIdentity;
    state->lineMatrix=CGAffineTransformIdentity;
}
static void Op_Tf(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    CGPDFReal size=0;
    if(CGPDFScannerPopNumber(scanner,&size)) state->fontSize=MAX(4.0f,(CGFloat)fabs(size));
    CGPDFName name=NULL; CGPDFScannerPopName(scanner,&name);
}
static void Op_Tm(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    CGPDFReal a,b,c,d,e,f;
    if(CGPDFScannerPopNumber(scanner,&f)&&CGPDFScannerPopNumber(scanner,&e)&&CGPDFScannerPopNumber(scanner,&d)&&CGPDFScannerPopNumber(scanner,&c)&&CGPDFScannerPopNumber(scanner,&b)&&CGPDFScannerPopNumber(scanner,&a)) {
        state->textMatrix=CGAffineTransformMake(a,b,c,d,e,f);
        state->lineMatrix=state->textMatrix;
    }
}
static void MoveTextLine(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    CGPDFReal tx,ty;
    if(CGPDFScannerPopNumber(scanner,&ty)&&CGPDFScannerPopNumber(scanner,&tx)) {
        state->lineMatrix=CGAffineTransformTranslate(state->lineMatrix,tx,ty);
        state->textMatrix=state->lineMatrix;
    }
}
static void Op_TD(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    CGPDFReal tx,ty;
    if(CGPDFScannerPopNumber(scanner,&ty)&&CGPDFScannerPopNumber(scanner,&tx)) {
        state->leading=-ty;
        state->lineMatrix=CGAffineTransformTranslate(state->lineMatrix,tx,ty);
        state->textMatrix=state->lineMatrix;
    }
}
static void Op_Tstar(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    state->lineMatrix=CGAffineTransformTranslate(state->lineMatrix,0.0f,-state->leading);
    state->textMatrix=state->lineMatrix;
}
static void Op_TL(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info; CGPDFReal v=0;
    if(CGPDFScannerPopNumber(scanner,&v)) state->leading=v;
}
static void Op_Tz(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info; CGPDFReal v=100;
    if(CGPDFScannerPopNumber(scanner,&v)) state->horizontalScale=MAX(0.01f,(CGFloat)v/100.0f);
}
static void Op_Ts(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info; CGPDFReal v=0;
    if(CGPDFScannerPopNumber(scanner,&v)) state->rise=v;
}
static void Op_Tj(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    CGPDFStringRef s=NULL;
    if(CGPDFScannerPopString(scanner,&s)) { AppendPDFString(s,state); AddTextRectForString(s,state); }
}
static void Op_TJ(CGPDFScannerRef scanner, void *info) {
    PDFTextState *state=(PDFTextState *)info;
    CGPDFArrayRef a=NULL;
    if(!CGPDFScannerPopArray(scanner,&a)) return;
    size_t n=CGPDFArrayGetCount(a);
    for(size_t i=0;i<n;i++) {
        CGPDFStringRef s=NULL;
        if(CGPDFArrayGetString(a,i,&s)) { AppendPDFString(s,state); AddTextRectForString(s,state); }
        if([state->rects count]>=state->maxRects) break;
    }
}

static void ScanPage(CGPDFPageRef page, PDFTextState *state) {
    CGPDFOperatorTableRef table=CGPDFOperatorTableCreate();
    CGPDFOperatorTableSetCallback(table,"BT",Op_BT);
    CGPDFOperatorTableSetCallback(table,"Tf",Op_Tf);
    CGPDFOperatorTableSetCallback(table,"Tm",Op_Tm);
    CGPDFOperatorTableSetCallback(table,"Td",MoveTextLine);
    CGPDFOperatorTableSetCallback(table,"TD",Op_TD);
    CGPDFOperatorTableSetCallback(table,"T*",Op_Tstar);
    CGPDFOperatorTableSetCallback(table,"TL",Op_TL);
    CGPDFOperatorTableSetCallback(table,"Tz",Op_Tz);
    CGPDFOperatorTableSetCallback(table,"Ts",Op_Ts);
    CGPDFOperatorTableSetCallback(table,"Tj",Op_Tj);
    CGPDFOperatorTableSetCallback(table,"TJ",Op_TJ);
    CGPDFContentStreamRef stream=CGPDFContentStreamCreateWithPage(page);
    CGPDFScannerRef scanner=CGPDFScannerCreate(stream,table,state);
    CGPDFScannerScan(scanner);
    CGPDFScannerRelease(scanner);
    CGPDFContentStreamRelease(stream);
    CGPDFOperatorTableRelease(table);
}

@implementation PDFTextExtractor
+ (NSString *)textForPage:(CGPDFPageRef)page {
    if(!page) return @"";
    NSMutableString *out=[NSMutableString string];
    PDFTextState state;
    state.text=out; state.rects=nil; state.maxRects=0; state.page=page;
    state.mediaBox=CGPDFPageGetBoxRect(page,kCGPDFMediaBox);
    state.textMatrix=CGAffineTransformIdentity; state.lineMatrix=CGAffineTransformIdentity;
    state.fontSize=12.0f; state.leading=12.0f; state.horizontalScale=1.0f; state.rise=0.0f;
    ScanPage(page,&state);
    return out;
}

+ (NSArray *)normalizedTextRectsForPage:(CGPDFPageRef)page maxRects:(NSUInteger)maxRects {
    if(!page||maxRects==0) return [NSArray array];
    NSMutableArray *rects=[NSMutableArray arrayWithCapacity:MIN(maxRects,(NSUInteger)160)];
    PDFTextState state;
    state.text=[NSMutableString string]; state.rects=rects; state.maxRects=maxRects; state.page=page;
    state.mediaBox=CGPDFPageGetBoxRect(page,kCGPDFMediaBox);
    state.textMatrix=CGAffineTransformIdentity; state.lineMatrix=CGAffineTransformIdentity;
    state.fontSize=12.0f; state.leading=12.0f; state.horizontalScale=1.0f; state.rise=0.0f;
    ScanPage(page,&state);
    return rects;
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
