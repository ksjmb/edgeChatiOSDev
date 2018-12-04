//
//  DCPersonDetailWebViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/28/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCPersonDetailWebViewController.h"

@interface DCPersonDetailWebViewController ()

@end

@implementation DCPersonDetailWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:self.selectedFeedItem.website_url];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
    [self.navigationItem setTitle:self.selectedFeedItem.influencer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
