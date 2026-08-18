#import "PDFOutlineParser.h"
@implementation PDFOutlineParser

static NSNumber *PageNumberForDestinationArray(CGPDFArrayRef dest, CGPDFDocumentRef doc) {
    if(!dest||!doc||CGPDFArrayGetCount(dest)<1)return nil;
    CGPDFObjectRef obj=NULL;
    if(!CGPDFArrayGetObject(dest,0,&obj)||!obj)return nil;
    CGPDFDictionaryRef target=NULL;
    if(!CGPDFObjectGetValue(obj,kCGPDFObjectTypeDictionary,&target)||!target)return nil;
    size_t count=CGPDFDocumentGetNumberOfPages(doc);
    for(size_t i=1;i<=count;i++) {
        CGPDFPageRef page=CGPDFDocumentGetPage(doc,i);
        if(page&&CGPDFPageGetDictionary(page)==target)return [NSNumber numberWithUnsignedInteger:i];
    }
    return nil;
}

static NSNumber *PageNumberForNode(CGPDFDictionaryRef node, CGPDFDocumentRef doc) {
    CGPDFArrayRef dest=NULL;
    if(CGPDFDictionaryGetArray(node,"Dest",&dest))return PageNumberForDestinationArray(dest,doc);
    CGPDFDictionaryRef action=NULL;
    if(CGPDFDictionaryGetDictionary(node,"A",&action)) {
        const char *type=NULL;
        if(CGPDFDictionaryGetName(action,"S",&type)&&type&&strcmp(type,"GoTo")==0) {
            CGPDFArrayRef d=NULL;
            if(CGPDFDictionaryGetArray(action,"D",&d))return PageNumberForDestinationArray(d,doc);
        }
    }
    return nil;
}

static void ParseNode(CGPDFDictionaryRef node,NSMutableArray*out,int depth,CGPDFDocumentRef doc){
    if(!node||depth>8)return;
    CGPDFStringRef title=NULL;
    CGPDFDictionaryGetString(node,"Title",&title);
    NSString*t=title?(NSString*)CGPDFStringCopyTextString(title):[@"Başlıksız" retain];
    NSNumber *page=PageNumberForNode(node,doc);
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithObjectsAndKeys:t,@"title",[NSNumber numberWithInt:depth],@"depth",nil];
    if(page)[item setObject:page forKey:@"page"];
    [out addObject:item];
    [t release];
    CGPDFDictionaryRef first=NULL,next=NULL;
    if(CGPDFDictionaryGetDictionary(node,"First",&first))ParseNode(first,out,depth+1,doc);
    if(CGPDFDictionaryGetDictionary(node,"Next",&next))ParseNode(next,out,depth,doc);
}

+ (NSArray*)outlineForDocument:(CGPDFDocumentRef)doc{
    NSMutableArray*out=[NSMutableArray array];
    CGPDFDictionaryRef cat=CGPDFDocumentGetCatalog(doc),ol=NULL,first=NULL;
    if(cat&&CGPDFDictionaryGetDictionary(cat,"Outlines",&ol)&&CGPDFDictionaryGetDictionary(ol,"First",&first))ParseNode(first,out,0,doc);
    return out;
}
@end
