//
//  DCLaunchScreenViewController.m
//  EventChat
//
//  Created by Jigish Belani on 3/7/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCLaunchScreenViewController.h"

@interface DCLaunchScreenViewController ()

@end

@implementation DCLaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Load launch image
    if ([UIScreen mainScreen].bounds.size.height == 812){
        [self.backgroundImageView setImage:[UIImage imageNamed:@"LaunchScreen_edgetvchat_X.png"]]; // iPhone X
    }
    else {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"LaunchScreen_edgetvchat_X.png"]]; // Other iPhones
    }
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
