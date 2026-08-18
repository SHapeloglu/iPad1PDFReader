#import "PDFOutlineParser.h"
@implementation PDFOutlineParser
static void ParseNode(CGPDFDictionaryRef node,NSMutableArray*out,int depth){if(!node||depth>8)return;CGPDFStringRef title=NULL;CGPDFDictionaryGetString(node,"Title",&title);NSString*t=title?(NSString*)CGPDFStringCopyTextString(title):[@"Başlıksız" retain];[out addObject:[NSDictionary dictionaryWithObjectsAndKeys:t,@"title",[NSNumber numberWithInt:depth],@"depth",nil]];[t release];CGPDFDictionaryRef first=NULL,next=NULL;if(CGPDFDictionaryGetDictionary(node,"First",&first))ParseNode(first,out,depth+1);if(CGPDFDictionaryGetDictionary(node,"Next",&next))ParseNode(next,out,depth);}
+ (NSArray*)outlineForDocument:(CGPDFDocumentRef)doc{NSMutableArray*out=[NSMutableArray array];CGPDFDictionaryRef cat=CGPDFDocumentGetCatalog(doc),ol=NULL,first=NULL;if(cat&&CGPDFDictionaryGetDictionary(cat,"Outlines",&ol)&&CGPDFDictionaryGetDictionary(ol,"First",&first))ParseNode(first,out,0);return out;}
@end
