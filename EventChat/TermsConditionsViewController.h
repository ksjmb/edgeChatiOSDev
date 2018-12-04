//
//  TermsConditionsViewController.h
//  EventChat
//
//  Created by Jigish Belani on 12/31/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsConditionsViewController : UIViewController
@property (nonatomic, weak) NSString *urlToOpen;
@property (nonatomic, weak) NSString *documentTitle;
@property (nonatomic, assign) BOOL isSocialLogin;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *agreeToTermsButton;
@end
