//
//  ZALinkParser.h
//  LinkParser
//
//  Created by Minh Nguyen's Mac on 10/18/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZALinkModel : NSObject
@property (strong, nonatomic) NSString*title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *thumbPath; 
@property (strong, nonatomic) NSString *faviconPath; // 1. shortcut icon 2. size ex: 72x72
@property (strong, nonatomic) NSString *domain;

@property (strong, nonatomic) NSString *url;

// entirely : priority which over wich, for example thumbnail & og:image
// NOTE : other option : request header and only parse html 
@end

typedef void(^ParseLinkCompletion) ( ZALinkModel* _Nullable , NSError*_Nullable);

@interface ZALinkParser : NSObject

- (void)parseLink:(NSString*)link completion:(ParseLinkCompletion)completion;
+ (void)parseLink:(NSString*)link completion:(ParseLinkCompletion)completion ;
@end



NS_ASSUME_NONNULL_END
