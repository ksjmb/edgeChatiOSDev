//
//  SignUpLoginViewController.h
//  EventChat
//
//  Created by Jigish Belani on 3/30/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Google/SignIn.h>
#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ECUser.h"
#import "ECColor.h"
#import "FCAlertView.h"

@class ECUser;
@class GIDSignIn;
@class GIDSignInButton;

@class SignUpLoginViewController;
@protocol SignUpLoginViewControllerDelegate <NSObject>
-(void)didTapLoginButton:(NSString *)storyboardIdentifier;
@end

typedef enum {
    FacebookLogin,
    GoogleLogin,
    TwitterLogin
} SocialType;

@interface SignUpLoginViewController : UIViewController <GIDSignInUIDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate, FCAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITextField *fullNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic) SocialType socialType;
@property (retain, nonatomic) NSString *storyboardIdentifierString;
@property (nonatomic, assign) BOOL isCommingFromSignInVC;
@property (nonatomic, weak) id <SignUpLoginViewControllerDelegate> delegate;

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error;

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton;

@end
