//
//  ZALinkParser.m
//  LinkParser
//
//  Created by Minh Nguyen's Mac on 10/18/21.
//

#import "ZALinkParser.h"
#import "TFHpple.h"

NSInteger const limitParseSize = 1024*1024*2;
NSInteger const maxRedirect = 2;
@implementation ZALinkModel

@end

@interface ZALinkParser () <NSURLSessionDataDelegate>
@end

@implementation ZALinkParser {
    ParseLinkCompletion completionBlock;
    long redirectCount ;
    NSString *savedUrl;
    NSMutableData *dataReceived;
}

#pragma mark - Public

+ (void)parseLink:(NSString*)link completion:(ParseLinkCompletion)completion {
    ZALinkParser *parser = [[ZALinkParser alloc]init];
    [parser parseLink:link completion:completion];
}

- (void)parseLink:(NSString*)link completion:(ParseLinkCompletion)completion {
    if (![link isKindOfClass:[NSString class]])
        return;;
    
    savedUrl = link;
    completionBlock = completion;
    redirectCount = 0;
    
    NSURL *url = [NSURL URLWithString:link];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3.0];
    [request setHTTPMethod:@"GET"];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request ];
    
    [dataTask resume];
}

- (void) handleData:(NSData*) data error:( NSError*)error {
    if (data && !error) {
        ZALinkModel *model = [self processParseLinkWithData:data];
        if (completionBlock) completionBlock(model,error);
    } else {
        if (completionBlock) completionBlock(nil,error);
    }
}

#pragma mark - Parse

- (ZALinkModel*)processParseLinkWithData:(NSData*)data {
    if (!data || ![data isKindOfClass:[NSData class]])
        return nil;
    TFHpple *page = [[TFHpple alloc]initWithHTMLData:data];
    TFHppleElement *element = [page peekAtSearchWithXPathQuery:@"/html/head"];

    if (!element)
        return nil;
    ZALinkModel *model = [[ZALinkModel alloc]init];
    
    for (TFHppleElement *child in element.children) {
        if (![child isKindOfClass:[TFHppleElement class]])
            continue;
        if (!model.title)
            model.title =  [self titleWithElement:child];
        if (!model.desc)
            model.desc = [self descWithElement:child];
        if (!model.faviconPath)
            model.faviconPath = [self faviconWithElement:child];
        if (!model.thumbPath)
            model.thumbPath = [self thumbPathWithElement:child];
        if (!model.domain)
            model.domain = [self domainWithElement:child];
        if (!model.url)
            model.url = [self urlWithElement:child];
    }
    
//    if (!model.domain) model.domain = [self domainFromLink:link];
    
    return model;
}

- (NSString*) urlWithElement:(TFHppleElement*)element {
    NSString *content;
    if ([self element:element isTagName:@"meta" checkKey:@"property" checkValues:@[@"og:url"]]) {
        content = [element objectForKey:@"content"];
    }
    return content;
}

- (NSString*)domainFromLink:(NSString*)link {
    NSArray *paths = [link pathComponents];
    if (paths.count>1) return paths[1];
    return nil;
}

- (NSString *)titleWithElement:(TFHppleElement*)element {
    NSString *content;
    if ([self element:element isTagName:@"meta" checkKey:@"name" checkValues:@[@"title"]])
        content = [element objectForKey:@"content"];
    
    if (content) return content;
    
    if ([self element:element isTagName:@"meta" checkKey:@"name" checkValues:@[@"og:title"]])
        content = [element objectForKey:@"content"];
    
    if (content) return content;
    
    if ([self element:element isTagName:@"meta" checkKey:@"property" checkValues:@[@"og:title"]])
        content = [element objectForKey:@"content"];
    
    if (content) return content;
    
    return nil;
}

- (NSString*)descWithElement:(TFHppleElement*)element {
    if ([self element:element isTagName:@"meta" checkKey:@"name" checkValues:@[@"description"]]) {
        return [element objectForKey:@"content"];
    }
    return nil;
}

- (NSString*)faviconWithElement:(TFHppleElement*)element {
    
    if ([self element:element isTagName:@"link" checkKey:@"rel" checkValues:@[@"icon",@"apple-touch-icon",@"apple-touch-icon-precomposed"]]) { // sizeLater, may be add shortcut icon
        return [element objectForKey:@"href"];
    }
    return nil;
}

- (NSString*)thumbPathWithElement:(TFHppleElement*)element {
    NSString *content;
    if ([self element:element isTagName:@"meta" checkKey:@"name" checkValues:@[@"thumbnail"]]) {
        content = [element objectForKey:@"content"];
    }
    if (content) return content;
    
    if ([self element:element isTagName:@"meta" checkKey:@"property" checkValues:@[@"og:image"]]) {
        content = [element objectForKey:@"content"];
    }
    
    if (content) return content;
    
    if ([self element:element isTagName:@"meta" checkKey:@"itemprop" checkValues:@[@"thumbnailUrl"]]) {
        content = [element objectForKey:@"content"];
    }
    
    if (content) return content;
    
    return content;
}

- (NSString*)domainWithElement:(TFHppleElement*)element {
    if ([self element:element isTagName:@"meta" checkKey:@"property" checkValues:@[@"og:site_name"]]) {
        return [element objectForKey:@"content"];
    }
    
    return  nil;
}

- (BOOL)element:(TFHppleElement*)child isTagName:(NSString*)tagName checkKey:(NSString*)key checkValues:(NSArray<NSString*>*)values {
    if ([child.tagName isEqualToString:tagName] && key && [values isKindOfClass:[NSArray class]]) {
        NSString *value = [child objectForKey:key];
        if (value && [values containsObject:value])
            return YES;
    }
    return NO;
}

#pragma mark - Check url valid

- (BOOL)shouldRequestUrl:(NSURL*)url {
    return [url isKindOfClass:[NSURL class]] && [self isHttpsUrl:url] && ![self isFileDownloadUrl:url];
}

- (BOOL)isFileDownloadUrl:(NSURL*)url {
    if (!url || ![url isKindOfClass:[NSURL class]])
        return NO;
    NSString *lastPathComponent = url.lastPathComponent;
    if (!lastPathComponent)
        return NO;
    
    static NSSet *listFileExtension ;
    if (!listFileExtension) {
        listFileExtension = [NSSet setWithArray:@[@"m4a",@"jpg",@"jpeg",@"png",@"mp4",@"avi",@"zip"]]; // update later
    }
    NSString *extention = lastPathComponent.pathExtension;
    if (extention && [listFileExtension containsObject:extention]) {
        return YES;
    }
    return NO;
}

- (BOOL)isHttpsUrl:(NSURL*)url {
    return (url && [url.scheme isEqualToString:@"https"]);
}

- (BOOL)checkValidHeader:(NSDictionary*)header {
    if ([header isKindOfClass:[NSDictionary class]]) {
//        NSLog(@"header: %@",header);
        // minhnht noted : use ZALO's api
        NSString *contentType = [header objectForKey:@"Content-Type"];
        
        NSString *contentLength = [header objectForKey:@"Content-Length"];
        NSInteger length = [contentLength integerValue];
        
        NSLog(@"type & length: %@ %d",contentType,contentLength);
        // minhnht noted : "text/html; charset=utf-8"
        return [contentType containsString:@"text/html"] && length<=limitParseSize;
        
        
    }
    return YES;
}

#pragma mark - taskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    NSLog(@"redirecct");

    
    // minhnht noted : deo bao here ? 
    if ([[request.URL host] isEqualToString:[self domainFromLink:savedUrl]]) {
        
    } else {
        redirectCount +=1;
    }
    
    NSLog(@"redirect Count: %d %@",redirectCount,request.URL);
    
    savedUrl = request.URL.absoluteString;

    if (redirectCount<=maxRedirect) {
        if (completionHandler)
            completionHandler(request);
    } else {
        if (completionHandler) completionHandler(nil);
//        completionBlock(nil, [NSError errorWithDomain:@"com.vng.error" code:1 userInfo:nil]);
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"check:: rêciveResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]] && httpResponse.allHeaderFields && httpResponse.statusCode == 200) {
        if ([self checkValidHeader:httpResponse.allHeaderFields]) {
            if (completionHandler) completionHandler(NSURLSessionResponseAllow);
        } else
            if (completionHandler) completionHandler(NSURLSessionResponseCancel);
        
    } else
        if (completionHandler) completionHandler(NSURLSessionResponseCancel);
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"check:: didReceiveData: %@ %ld",dispatch_get_current_queue(),[data length]);
    if (!data) return;
    // minhnht noted : log
    if (!dataReceived)
        dataReceived = [data mutableCopy];
    else
        [dataReceived appendData:data];

    if ([dataReceived length]>limitParseSize) {
        [dataTask cancel];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"check:: totalData: %ld error: %@",[dataReceived length],error.localizedDescription);
    if (error) {
        dataReceived = nil;
    }
    [self handleData:dataReceived  error:error];
}
@end
