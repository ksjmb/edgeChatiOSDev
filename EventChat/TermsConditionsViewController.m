//
//  TermsConditionsViewController.m
//  EventChat
//
//  Created by Jigish Belani on 12/31/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "TermsConditionsViewController.h"
#import "FCAlertView.h"

@interface TermsConditionsViewController ()
@property (nonatomic, strong) IBOutlet UIWebView *tcWebView;
@end

@implementation TermsConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:_urlToOpen];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_tcWebView loadRequest:urlRequest];
    [self.navigationController.navigationItem setTitle:_documentTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    if(_isSocialLogin){
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:nil
                  withSubtitle:@"Please click \"Agree\" to indicate that you have read and agree to the terms presented in the Terms of Use agreement."
               withCustomImage:nil
           withDoneButtonTitle:nil
                    andButtons:nil];
    }
    else{
        _agreeToTermsButton = nil;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
