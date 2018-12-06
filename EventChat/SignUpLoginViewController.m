//
//  SignUpLoginViewController.m
//  EventChat
//
//  Created by Jigish Belani on 3/30/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "SignUpLoginViewController.h"
#import "AppDelegate.h"
#import "TermsConditionsViewController.h"
#import "ECAuthAPI.h"
#import "IonIcons.h"
#import "ECCommonClass.h"
#import "CustomButton.h"
#import <Crashlytics/Crashlytics.h>
#import "RegisterViewController.h"
#import "FCAlertView.h"
#import "SVProgressHUD.h"
#import "ECFeedViewController.h"

@interface SignUpLoginViewController ()
@property (strong, nonatomic) IBOutlet TWTRLogInButton *twtrLogInButton;
@property (strong, nonatomic) IBOutlet GIDSignInButton *gidSignInButton;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *fbSDKLoginButton;
@property (strong, nonatomic) UIButton *signUpWithEmailButton;
@property (strong, nonatomic) IBOutlet UIButton *loginWithEmailButton;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, weak) IBOutlet UIButton *googleButton;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, weak) IBOutlet UIStackView *buttonStackView;
@property (retain, nonatomic) UIImage *alertImage;
@property (retain, nonatomic) NSString *alertTitle;
@property (retain, nonatomic) NSArray *arrayOfButtonTitles;
@end

@implementation SignUpLoginViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"storyboardIdentifierString: %@", _storyboardIdentifierString);
    //[self.backgroundImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"LaunchScreen_%@.png", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"]]]];
    // Load launch image
    if ([UIScreen mainScreen].bounds.size.height == 812){
        [self.backgroundImageView setImage:[UIImage imageNamed:@"LaunchScreen_edgetvchat_X.png"]]; // iPhone X
    }
    else {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"LaunchScreen_edgetvchat_Plus.png"]]; // Other iPhones
    }
    _fullNameTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_person  size:30.0 color:[UIColor lightGrayColor]]];
    profileImageView.frame = CGRectMake(0.0, 0.0, profileImageView.image.size.width, profileImageView.image.size.height);
    _fullNameTextField.leftView = profileImageView;
    
    _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_email  size:30.0 color:[UIColor lightGrayColor]]];
    emailImageView.frame = CGRectMake(0.0, 0.0, emailImageView.image.size.width, emailImageView.image.size.height);
    _emailTextField.leftView = emailImageView;
    
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *lockImageView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_locked  size:30.0 color:[UIColor lightGrayColor]]];
    lockImageView.frame = CGRectMake(0.0, 0.0, lockImageView.image.size.width, lockImageView.image.size.height);
    _passwordTextField.leftView = lockImageView;
    
    _loginWithEmailButton.layer.cornerRadius = 5.0;
    
//    // Twitter
    self.twtrLogInButton = [[TWTRLogInButton alloc] init];
    self.twtrLogInButton.loginMethods = TWTRLoginMethodWebBased;
    [self.twtrLogInButton addTarget:self action:@selector(twitterLogin:) forControlEvents:UIControlEventTouchUpInside];
    
//    // Google
    self.gidSignInButton = [[GIDSignInButton alloc] init];
    [GIDSignIn sharedInstance].uiDelegate = self;
    self.gidSignInButton.translatesAutoresizingMaskIntoConstraints = NO;
//
//    // Facebook
    [self.fbSDKLoginButton setDelegate:self];
    self.fbSDKLoginButton.readPermissions =
    @[@"public_profile", @"email", @"user_friends"];
    self.fbSDKLoginButton.publishPermissions = @[@"publish_actions"];
//
//    // login
//    self.signUpWithEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.signUpWithEmailButton setBackgroundColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
//    self.signUpWithEmailButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.signUpWithEmailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.signUpWithEmailButton addTarget:self action:@selector(didTapViewDocument:) forControlEvents:UIControlEventTouchUpInside];
//    [self.signUpWithEmailButton.layer setCornerRadius:5];
//    [self.signUpWithEmailButton setTitle:@"Login" forState:UIControlStateNormal];
//    
//    // Email SignUp
//    self.signUpWithEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.signUpWithEmailButton setBackgroundColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
//    self.signUpWithEmailButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.signUpWithEmailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.signUpWithEmailButton addTarget:self action:@selector(didTapViewDocument:) forControlEvents:UIControlEventTouchUpInside];
//    [self.signUpWithEmailButton.layer setCornerRadius:2];
//    [self.signUpWithEmailButton setTitle:@"Sign Up with Email" forState:UIControlStateNormal];
//    
//    UIButton *termsOfUseButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    termsOfUseButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [termsOfUseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [termsOfUseButton addTarget:self action:@selector(didTapViewDocument:) forControlEvents:UIControlEventTouchUpInside];
//    [termsOfUseButton setTitle:@"Terms Of Use" forState:UIControlStateNormal];
//    [termsOfUseButton setTag:1];
//    
//    UIButton *privacyPolicyButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    privacyPolicyButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [privacyPolicyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [privacyPolicyButton addTarget:self action:@selector(didTapViewDocument:) forControlEvents:UIControlEventTouchUpInside];
//    [privacyPolicyButton setTitle:@"Privacy Policy" forState:UIControlStateNormal];
//    [privacyPolicyButton setTag:2];
//    
//    [self.view addSubview:_fbSDKLoginButton];
//    [self.view addSubview:_twtrLogInButton];
//    [self.view addSubview:_gidSignInButton];
//    [self.view addSubview:termsOfUseButton];
//    [self.view addSubview:privacyPolicyButton];
//    
//    NSDictionary * buttonDic = NSDictionaryOfVariableBindings(_signUpWithEmailButton, _gidSignInButton, _twtrLogInButton, _fbSDKLoginButton);
//    _signUpWithEmailButton.translatesAutoresizingMaskIntoConstraints = NO;
//    _gidSignInButton.translatesAutoresizingMaskIntoConstraints = NO;
//    _twtrLogInButton.translatesAutoresizingMaskIntoConstraints = NO;
//    _fbSDKLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[_gidSignInButton]-80-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:buttonDic]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[_twtrLogInButton]-80-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:buttonDic]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[_fbSDKLoginButton]-80-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:buttonDic]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fbSDKLoginButton(44)]-30-[_twtrLogInButton(44)]-30-[_gidSignInButton(44)]-80-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:buttonDic]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:termsOfUseButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-25.0]];
//    
//    NSDictionary *views = NSDictionaryOfVariableBindings(termsOfUseButton, privacyPolicyButton);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[termsOfUseButton][privacyPolicyButton(==termsOfUseButton)]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];
    
    //[_facebookButton setImage:[IonIcons imageWithIcon:ion_social_facebook size:30.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_facebookButton setImage:[IonIcons imageWithIcon:ion_social_facebook size:50.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_facebookButton setTintColor:[UIColor whiteColor]];
    _facebookButton.layer.cornerRadius = 5.0;
    _facebookButton.layer.masksToBounds = YES;
    _facebookButton.layer.borderWidth = 1.0;
    _facebookButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_facebookButton
     addTarget:self
     action:@selector(didTapLoginWithSocial:) forControlEvents:UIControlEventTouchUpInside];
    
    [_twitterButton setImage:[[UIImage imageNamed:@"twitterIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_twitterButton  setTintColor:[UIColor whiteColor]];
    [_googleButton setImage:[IonIcons imageWithIcon:ion_social_google size:50.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_googleButton setTintColor:[UIColor whiteColor]];
    _googleButton.layer.cornerRadius = 5.0;
    _googleButton.layer.masksToBounds = YES;
    _googleButton.layer.borderWidth = 1.0;
    _googleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_googleButton
     addTarget:self
     action:@selector(didTapLoginWithSocial:) forControlEvents:UIControlEventTouchUpInside];
    [_emailButton setImage:[IonIcons imageWithIcon:ion_ios_email size:50.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_emailButton  setTintColor:[UIColor whiteColor]];
    _emailButton.layer.cornerRadius = 5.0;
    _emailButton.layer.masksToBounds = YES;
    _emailButton.layer.borderWidth = 1.0;
    _emailButton.layer.borderColor = [UIColor whiteColor].CGColor;
   // [_twitterButton setHidden:YES];
    
    self.arrayOfButtonTitles = @[@"Cancel"];
}

- (void)viewWillAppear:(BOOL)animated{
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_arrow_back  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [self.navigationItem setLeftBarButtonItem:closeBarButtonItem];
}

#pragma mark:- IBAction Methods

- (IBAction)Back{
    ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
    if (sharedInstance.isUserLogoutTap == false){
        [self.navigationController popViewControllerAnimated:true];
    }else{
        sharedInstance.isFromMore = false;
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] backToMainVC];
    }
}

- (IBAction)dismissKeyboaard:(id)sender{
   [self.view endEditing:YES];
}

#pragma mark - Twitter Login methods
-(IBAction)twitterLogin:(id)sender{
    // If using the log in methods on the Twitter instance
    [[Twitter sharedInstance] logInWithMethods:TWTRLoginMethodWebBased completion:^(TWTRSession *session, NSError *error) {
        if(error != nil) {
                        //error state
            
                    } else {
                        TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
                        NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                                         URL:@"https://api.twitter.com/1.1/account/verify_credentials.json"
                                                                  parameters:@{@"include_email": @"true", @"skip_status": @"true"}
                                                                       error:nil];
                        
                        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            // handle the response data e.g.
                            NSError *jsonError;
                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                            
                            NSString *twitterId = [json objectForKey:@"id_str"];
                            NSString *firstName = [[[json objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:0];
                            NSString *lastName;
                            NSString *profilePicUrl = [json objectForKey:@"profile_image_url_https"];
                            NSString *username = [NSString stringWithFormat:@"TW_%@", twitterId];
                            NSString *tempPassword = [[[NSUUID UUID] UUIDString] componentsSeparatedByString:@"-"][0];
                            if([[[json objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] count] > 1){
                                lastName = [[[json objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:1];
                            }
                            else {
                                lastName = nil;
                            }
                            
                            [[ECAPI sharedManager] createUserWithSocial:nil firstName:firstName lastName:lastName deviceToken:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getDeviceToken] facebookUserId:nil googleUserId:nil twitterUserId:twitterId socialConnect:@"twitter" username:username password:tempPassword callback:^(NSError *error) {
                                
                                if (error) {
                                    NSLog(@"Error adding user: %@", error.localizedDescription);
                                    NSLog(@"%@", error);
                                    //!!!: This is a clumsy way to handle the error
                                    //!!!: The "error" may just be that you have a nil status (which should actually be fine)
                                    UIAlertView *alertView = [[UIAlertView alloc]
                                                              initWithTitle:@"Twitter error"
                                                              message:[NSString stringWithFormat:@"%@", error]
                                                              delegate:nil
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                                    [alertView show];
                                } else {
                                    self.signedInUser = [[ECAPI sharedManager] signedInUser];
                                    NSLog(@"%@", self.signedInUser.userId);
                                    [[ECAPI sharedManager] updateProfilePicUrl:self.signedInUser.userId profilePicUrl:profilePicUrl callback:^(NSError *error) {
                                        if (error) {
                                            NSLog(@"Error adding user: %@", error);
                                            NSLog(@"%@", error);
                                        } else {
                                            // code
                                            [[NSUserDefaults standardUserDefaults] setObject:twitterId forKey:@"socialUserId"];
                                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
                                            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                                            [[NSUserDefaults standardUserDefaults] setObject:tempPassword forKey:@"password"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                                                           password:tempPassword
                                                                                            success:^(AFOAuthCredential *credential) {
//                                                                                                [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                                ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
                                                                                                if (sharedInstance.isUserLogoutTap == false){
                                                                                                    [self.navigationController popViewControllerAnimated:false];
                                                                                                    [self.delegate didTapLoginButton:_storyboardIdentifierString];
                                                                                                }else{
                                                                                                    [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                                }
                                                                                            }
                                                                                            failure:^(NSError *error) {
                                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                    
                                                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                                    [alert show];
                                                                                                });
                                                                                            }];
                                        }
                                    }];
                                    
                                }
                            }];
                        }];
                    }
    }];
}

- (IBAction)didTapLoginWithSocial:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(button.tag == 3) {
        self.socialType = FacebookLogin;
    }
    else if(button.tag == 5){
        self.socialType = GoogleLogin;
    }
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:nil
              withSubtitle:@"Please click \"Agree\" to indicate that you have read and agree to the terms presented in the Terms of Use agreement."
           withCustomImage:_alertImage
       withDoneButtonTitle:@"Agree"
                andButtons:self.arrayOfButtonTitles];
}

#pragma mark - Facebook Login methods
// Once the button is clicked, show the login dialog
-(void)fbLoginButtonClicked
{
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             if(!result.isCancelled){
                 NSLog(@"Login");

                 if ([FBSDKAccessToken currentAccessToken]){
                     NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                     [parameters setValue:@"id, name, email, gender, first_name, last_name" forKey:@"fields"];

                     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
                          // fetch all your data
                          if (!error) {
                              NSString *userId = [result objectForKey:@"id"];
                              NSString *username = [NSString stringWithFormat:@"FB_%@", userId];
                              NSString *tempPassword = [[[NSUUID UUID] UUIDString] componentsSeparatedByString:@"-"][0];
                              NSString *email = @"N/A";
                              if([result objectForKey:@"email"]){
                                  email = [result objectForKey:@"email"];
                              }
                              [Answers logLoginWithMethod:@"Facebook"
                                                  success:@YES
                                         customAttributes:@{
                                                            @"ID" : userId,
                                                            @"Email" : email,
                                                            @"Name" : [NSString stringWithFormat:@"%@ %@", [result objectForKey:@"first_name"], [result objectForKey:@"last_name"]]
                                                            }];
                              NSLog(@"fetched user:%@", [result objectForKey:@"first_name"]);


                              [[ECAPI sharedManager] createUserWithSocial:[result objectForKey:@"email"] firstName:[result objectForKey:@"first_name"] lastName:[result objectForKey:@"last_name"] deviceToken:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getDeviceToken] facebookUserId:[result objectForKey:@"id"] googleUserId:nil twitterUserId:nil socialConnect:@"Facebook" username:username password:tempPassword callback:^(NSError *error) {

                                  if (error) {
                                      NSLog(@"Error adding user: %@", error.localizedDescription);
                                      //!!!: This is a clumsy way to handle the error
                                      //!!!: The "error" may just be that you have a nil status (which should actually be fine)
                                      UIAlertView *alertView = [[UIAlertView alloc]
                                                                initWithTitle:@"Facebook error"
                                                                message:[NSString stringWithFormat:@"%@", error]
                                                                delegate:nil
                                                                cancelButtonTitle:@"Okay"
                                                                otherButtonTitles:nil];
                                      [alertView show];
                                  } else {
                                      [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"email"] forKey:@"SignedInUserEmail"];
                                      [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:@"socialUserId"];
                                      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
                                      [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                                      [[NSUserDefaults standardUserDefaults] setObject:tempPassword forKey:@"password"];
                                      [[NSUserDefaults standardUserDefaults] synchronize];

                                      [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                                                     password:tempPassword
                                                                                      success:^(AFOAuthCredential *credential) {
//                                                                                          [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                          ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
                                                                                          if (sharedInstance.isUserLogoutTap == false){
                                                                                              [self.navigationController popViewControllerAnimated:false];
                                                                                              [self.delegate didTapLoginButton:_storyboardIdentifierString];
                                                                                          }else{
                                                                                              [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                          }
                                                                                      }
                                                                                      failure:^(NSError *error) {
                                                                                          dispatch_async(dispatch_get_main_queue(), ^{

                                                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                              [alert show];
                                                                                          });
                                                                                      }];
                                  }


                              }];

                          }
                          else{

                          }
                      }];
                 }
             }
         }
     }];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    if(!result.isCancelled){
        NSLog(@"Login");
        
        if ([FBSDKAccessToken currentAccessToken]){
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id, name, email, gender, first_name, last_name" forKey:@"fields"];
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
                 // fetch all your data
                 if (!error) {
                     NSLog(@"fetched user:%@", [result objectForKey:@"first_name"]);
                     NSString *userId = [result objectForKey:@"id"];
                     NSString *username = [NSString stringWithFormat:@"FB_%@", userId];
                     NSString *tempPassword = [[[NSUUID UUID] UUIDString] componentsSeparatedByString:@"-"][0];
                     
                     [[ECAPI sharedManager] createUserWithSocial:[result objectForKey:@"email"] firstName:[result objectForKey:@"first_name"] lastName:[result objectForKey:@"last_name"] deviceToken:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getDeviceToken] facebookUserId:[result objectForKey:@"id"] googleUserId:nil twitterUserId:nil socialConnect:@"Facebook" username:username password:tempPassword callback:^(NSError *error) {
                         
                         if (error) {
                             NSLog(@"Error adding user: %@", error.localizedDescription);
                             NSLog(@"%@", error);
                             //!!!: This is a clumsy way to handle the error
                             //!!!: The "error" may just be that you have a nil status (which should actually be fine)
                             UIAlertView *alertView = [[UIAlertView alloc]
                                                       initWithTitle:@"Facebook error"
                                                       message:[NSString stringWithFormat:@"%@", error]
                                                       delegate:nil
                                                       cancelButtonTitle:@"Okay"
                                                       otherButtonTitles:nil];
                             [alertView show];
                         } else {
                             [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"email"] forKey:@"SignedInUserEmail"];
                             [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"id"] forKey:@"socialUserId"];
                             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
                             [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                             [[NSUserDefaults standardUserDefaults] setObject:tempPassword forKey:@"password"];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                             
                             [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                                            password:tempPassword
                                                                             success:^(AFOAuthCredential *credential) {
//                                                                                 [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                 ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
                                                                                 if (sharedInstance.isUserLogoutTap == false){
                                                                                     [self.navigationController popViewControllerAnimated:false];
                                                                                     [self.delegate didTapLoginButton:_storyboardIdentifierString];
                                                                                 }else{
                                                                                     [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                 }
                                                                             }
                                                                             failure:^(NSError *error) {
                                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                                     
                                                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                     [alert show];
                                                                                 });
                                                                             }];
                         }
                     }];
                 }
                 else{
                     
                 }
             }];
        }
    }
    else{
        NSLog(@"Cancelled");
    }
    
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

- (IBAction)didTapViewDocument:(id)sender{
    /*
    UIButton *button = (UIButton *)sender;
    TermsConditionsViewController *termsConditionsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsConditionsViewController"];
    
    if(button.tag == 1) {
        termsConditionsViewController.urlToOpen = @"https://docs.google.com/document/d/e/2PACX-1vS2KQuYMEsZ6F5OEsEyCEidH-Afg8rFvjldhA_gbvVnO5nCFq6LK9yHA3bDLf8Qco5uumCsRyge7sPg/pub";
    }
    else if(button.tag == 2){
        termsConditionsViewController.urlToOpen = @"https://docs.google.com/document/d/e/2PACX-1vQGAPSY9BYAXnlQC0GK0PXl3Uloa1HQrNDbpI4bpqMepMf3iGeAVYxfGkKrV3dl_HMv04hTt-27cOOg/pub";
    }
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:termsConditionsViewController];
    termsConditionsViewController.isSocialLogin = false;
    [self presentViewController:navigationController animated:YES completion:nil];
     */
}

- (void)showTermsOfUseModal{
    /*
    TermsConditionsViewController *termsConditionsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsConditionsViewController"];
    termsConditionsViewController.urlToOpen = @"https://docs.google.com/document/d/e/2PACX-1vS2KQuYMEsZ6F5OEsEyCEidH-Afg8rFvjldhA_gbvVnO5nCFq6LK9yHA3bDLf8Qco5uumCsRyge7sPg/pub";
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:termsConditionsViewController];
    termsConditionsViewController.isSocialLogin = true;
    [self presentViewController:navigationController animated:YES completion:nil];
     */
}

- (IBAction)didTapSignUpWithEmail:(id)sender{
    RegisterViewController *registerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:registerViewController];
    //[self presentViewController:registerViewController animated:YES completion:nil];
    registerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navigationController animated:YES completion:nil];
}

//** Simple Login
- (IBAction)didTapLogInWithEmail:(id)sender{
    NSString *email = [_emailTextField.text lowercaseString];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Authenticating..."];
    
    [[ECAuthAPI sharedClient] signInWithEmailAndPassword:email
                                                   password:_passwordTextField.text
                                                    success:^(AFOAuthCredential *credential) {
                                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                                                     1 * NSEC_PER_SEC),
                                                                       dispatch_get_main_queue(),
                                                                       ^{
                                                                           [[ECAPI sharedManager] getUserByEmail:email callback:^(ECUser *ecUser, NSError *error) {
                                                                               if(error){
                                                                                   NSLog(@"Error: %@", error);
                                                                                   [SVProgressHUD dismiss];
                                                                               }
                                                                               else{
                                                                                   NSLog(@"User: %@", ecUser);
                                                                                   [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"SignedInUserEmail"];
                                                                                   [[NSUserDefaults standardUserDefaults] setObject:@"n/a" forKey:@"socialUserId"];
                                                                                   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
                                                                                   [[NSUserDefaults standardUserDefaults] setObject:ecUser.username forKey:@"username"];
                                                                                   [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"password"];
                                                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                   [SVProgressHUD dismiss];
                                                                                   //@kj_undo_change
//                                                                                   [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                   ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
                                                                                   if (sharedInstance.isUserLogoutTap == false){
                                                                                       [self.navigationController popViewControllerAnimated:false];
                                                                                       [self.delegate didTapLoginButton:_storyboardIdentifierString];
                                                                                   }else{
                                                                                       [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                                   }
                                                                               }
                                                                           }];
                                                                       });
                                                        
                                                    }
                                                    failure:^(NSError *error) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [SVProgressHUD dismiss];
                                                            FCAlertView *alert = [[FCAlertView alloc] init];
                                                            [alert makeAlertTypeWarning];
                                                            [alert showAlertInView:self
                                                                         withTitle:@"Login Error"
                                                                      withSubtitle:@"Incorrect email or password. Please try again."
                                                                   withCustomImage:_alertImage
                                                               withDoneButtonTitle:nil
                                                                        andButtons:self.arrayOfButtonTitles];
                                                        });
                                                    }];
}

#pragma mark - Google Login methods
// Implement these methods only if the GIDSignInUIDelegate is not a subclass of
// UIViewController.

// Stop the UIActivityIndicatorView animation that was started when the user
// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    //[myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapLogInWithGoogle{
    [GIDSignIn sharedInstance].uiDelegate = self;
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title {
    
    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
    
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView {
    
    NSLog(@"Done Button Clicked");
    switch (self.socialType) {
        case FacebookLogin:
            [self fbLoginButtonClicked];
            break;
        case GoogleLogin:
            [self didTapLogInWithGoogle];
            break;
        default:
            break;
    }
    
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView {
    
    NSLog(@"Alert Dismissed");
    
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView {
    
    NSLog(@"Alert Will Appear");
    
}

@end
