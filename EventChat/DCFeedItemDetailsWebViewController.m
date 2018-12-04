//
//  DCFeedItemDetailsWebViewController.m
//  EventChat
//
//  Created by Jigish Belani on 10/18/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "DCFeedItemDetailsWebViewController.h"

@interface DCFeedItemDetailsWebViewController ()

@end

@implementation DCFeedItemDetailsWebViewController

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

- (IBAction)closeOverlay:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
