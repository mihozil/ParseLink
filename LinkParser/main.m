//
//  main.m
//  LinkParser
//
//  Created by Minh Nguyen's Mac on 10/18/21.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ZALinkParser.h"

int main(int argc, char * argv[]) {
    
    ZALinkParser *parser = [[ZALinkParser alloc]init];
//    NSString *link = @"https://vnexpress.net/cap-do-dich-benh-cua-63-tinh-thanh-4373500.html";
//    NSString *link = @"https://zingnews.vn/fifa-xu-van-lam-thang-trong-vu-kien-voi-muangthong-post1271645.html";
//    NSString *link = @"https://www.techopedia.com/top-reasons-to-use-predictive-ai-for-enhanced-cybersecurity-in-2021/2/34588";
//    NSString *link = @"https://www.dailymail.co.uk/sport/football/article-10104757/MARTIN-SAMUEL-fact-dont-know-Solskjaers-Man-United-looks-like-makes-great-theatre.html";

//    NSString *link = @"https://www.businessinsider.com/global-energy-market-crunch-mess-inflation-risk-new-economic-era-2021-10";
//    NSString *link = @"http://boulderhomegrown.com/fiddletunes/JerusalemRidge-100.mp3";
//    NSString *link = @"https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/32/43/e7/3243e71e-d720-8fb9-b167-b3422418cc00/mzaf_771419641968084812.plus.aac.p.m4a";
//    NSString *link = @"https://zalo-filegroup-bf3.zdn.vn/de9bcfa083726c2c3563/8708906942335195087";
//    NSString *link = @"https://dantri.com.vn/giao-duc-huong-nghiep/giam-doc-so-gddt-ha-noi-bac-bo-tin-de-xuat-hoc-sinh-di-hoc-tu-2510-20211019141105626.htm#dt_source=Home&dt_campaign=Cover&dt_medium=1";
//    NSString *link = @"cafef.vn/bien-dong-ghe-nong-tai-hang-loat-ngan-hang-lan-song-ceo-chu-tich-8x-20211019140158662.chn";
//    NSString *link = @"http://bit.ly/3r3Uf8R";
//    NSString* link = @"https://shorturl.at/ilrJX";
//    NSString *link = @"https://shorten.one/BM6oV";
//    NSString *link = @"https://zalo-filegroup-bf3.zdn.vn/de9bcfa083726c2c3563/8708906942335195087";
    NSString *link = @"https://www.sciencedirect.com/science/article/pii/S0360319915319285";
    [parser parseLink:link completion:^(ZALinkModel*model, NSError*error) {
        NSLog(@"check:: title: %@ \n desc: %@ \n domain: %@ \n thumb: %@ \n favicon: %@ \n url: %@",model.title,model.desc,model.domain,model.thumbPath,model.faviconPath,model.url);
        NSLog(@"check:: domain: %@",model.domain);
    }];
    
//    NSURL *url = [NSURL URLWithString:link];
//    [url pathcom]
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:link] encoding:NSUTF8StringEncoding error:nil];

    
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
