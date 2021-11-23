//
//  ZAParseLinkManager.m
//  LinkParser
//
//  Created by Minh Nguyen's Mac on 11/22/21.
//

#import "ZAParseLinkManager.h"
#import "ZALinkParser.h"

@implementation ZAParseLinkManager {
    // minhnht noted : change to ts
    NSMutableDictionary *cachedDic;
    NSMutableDictionary *parsingDic;
}
// minhnht noted : manager test later
+ (ZAParseLinkManager*)sharedInstance {
    static ZAParseLinkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZAParseLinkManager alloc]init];
    });
    return manager;
}

- (instancetype)init {
    if (self=[super init]) {
        cachedDic = [[NSMutableDictionary alloc]init];
        parsingDic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)requestParseLink:(NSString*)link completion:(ParseLinkCompletion)completion {
    if (![self preCheckShouldParseLink:link]) {
        // minhnht noted : changed to errorWithDomain: message:..
        if (completion) completion(nil,[NSError errorWithDomain:@"com.vng.parselink" code:0 userInfo:nil]);
        return;
    }
    
    ZALinkModel *model = [cachedDic objectForKey:link];
    if (model) {
        if (completion) completion(model,nil);
        return;
    }
    
    // minhnht noted : use fblPromisehere
    NSMutableArray *parsing = [parsingDic objectForKey:link];
    if ([parsing isKindOfClass:[NSMutableArray class]]) {
        [parsing addObject:completion];
        return;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    if (completion) [arr addObject:completion];
    [parsingDic setObject:arr forKey:link];
    __weak typeof(self) weakSelf = self;
    [ZALinkParser parseLink:link completion:^(ZALinkModel *model, NSError*error){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf resolveCompletionParsing:model error:error link:link];
        if (model && !error)
            [strongSelf->cachedDic setObject:model forKey:link];
    }];
    
}

- (BOOL)preCheckShouldParseLink:(NSString*)link {
    // minhnht noted :: add suffix
    if (![link isKindOfClass:[NSString class]]) return NO;
    if ([link pathComponents].count == 0) return NO;
    NSString *scheme = [[link pathComponents]firstObject];
    if (![scheme isEqualToString:@"https"]) return NO;
    if (![link canBeConvertedToEncoding:NSASCIIStringEncoding]) return NO;
    return YES;
}

- (void)resolveCompletionParsing:(ZALinkModel*)model error:(NSError*)error link:(NSString*)link{
    NSArray*arr = [parsingDic objectForKey:link];
    if ([arr isKindOfClass:NSArray.class]) {
        for (ParseLinkCompletion completion in arr) {
            completion(model,error);
        }
    }
    [parsingDic removeObjectForKey:link];

}

@end
