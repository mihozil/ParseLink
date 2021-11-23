//
//  ViewController.m
//  LinkParser
//
//  Created by Minh Nguyen's Mac on 10/18/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    UIImageView *imgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imgView = [[UIImageView alloc]init];
    imgView.frame = CGRectMake(100, 100, 222, 111);
    imgView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:imgView];
    
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSString *link = @"https://www.businessinsider.com/public/assets/BI/US/favicons/apple-touch-icon.png?v=2021-08";
////    NSString *link = @"https://lesrivesexperience.com/wp-content/uploads/2018/11/sunset-on-saigon-river.jpg";
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
//    [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData*data, NSURLResponse *response, NSError*error){
//        NSHTTPURLResponse *httpResponse = response;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            imgView.image = [UIImage imageWithData:data];
//        });
//    }];
//    [task resume];
    
}


@end
