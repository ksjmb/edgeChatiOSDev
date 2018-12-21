#import "RegisterViewController.h"
#import "IonIcons.h"
#import "ECAPI.h"
#import "TextFieldValidator.h"
#import "FCAlertView.h"
#import "AppDelegate.h"
#import "ECAuthAPI.h"
#import "TermsConditionsViewController.h"
#import "ECCommonClass.h"

#define REGEX_MANDATORY @"[A-Za-z]{1,100}"
#define REGEX_USER_NAME_LIMIT @"^.{3,10}$"
#define REGEX_USER_NAME @"[A-Za-z0-9]{3,10}"
#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define REGEX_PASSWORD_LIMIT @"^.{6,20}$"
#define REGEX_PASSWORD @"[A-Za-z0-9]{6,20}"
#define REGEX_PHONE_DEFAULT @"[0-9]{3}\\-[0-9]{3}\\-[0-9]{4}"

@interface RegisterViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, strong) IBOutlet TextFieldValidator *firstNameTextField;
@property (nonatomic, strong) IBOutlet TextFieldValidator *lastNameTextField;
@property (nonatomic, strong) IBOutlet TextFieldValidator *emailTextField;
@property (nonatomic, strong) IBOutlet TextFieldValidator *passwordTextField;
@property (nonatomic, strong) IBOutlet TextFieldValidator *confirmPasswordTextField;
@property (nonatomic, strong) IBOutlet UISwitch *tcSwitch;
@property (retain, nonatomic) UIImage *alertImage;
@property (retain, nonatomic) NSString *alertTitle;
@property (retain, nonatomic) NSArray *arrayOfButtonTitles;
@property (nonatomic, assign) BOOL alreadyExists;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@end

@implementation RegisterViewController

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
//    [self.navigationController.navigationBar setTranslucent:YES];
    
    _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *emailImageView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_email  size:30.0 color:[UIColor lightGrayColor]]];
    emailImageView.frame = CGRectMake(0.0, 0.0, emailImageView.image.size.width, emailImageView.image.size.height);
    _emailTextField.leftView = emailImageView;
    
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *lockImageView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_locked  size:30.0 color:[UIColor lightGrayColor]]];
    lockImageView.frame = CGRectMake(0.0, 0.0, lockImageView.image.size.width, lockImageView.image.size.height);
    _passwordTextField.leftView = lockImageView;
    
    _confirmPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *lockImageView2 = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_locked  size:30.0 color:[UIColor lightGrayColor]]];
    lockImageView2.frame = CGRectMake(0.0, 0.0, lockImageView2.image.size.width, lockImageView2.image.size.height);
    _confirmPasswordTextField.leftView = lockImageView2;
    
    [self setupAlerts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupAlerts{
    [_firstNameTextField addRegx:REGEX_MANDATORY withMsg:@"This field cannot be blank"];
    [_lastNameTextField addRegx:REGEX_MANDATORY withMsg:@"This field cannot be blank"];
    [_emailTextField addRegx:REGEX_EMAIL withMsg:@"Enter valid email."];
    [_passwordTextField addRegx:REGEX_PASSWORD_LIMIT withMsg:@"Password characters limit should be come between 6-20"];
    [_passwordTextField addRegx:REGEX_PASSWORD withMsg:@"Password must contain alpha numeric characters."];
    [_confirmPasswordTextField addConfirmValidationTo:_passwordTextField withMsg:@"Confirm password didn't match."];
    
    self.alertTitle = nil;
    self.alertImage = nil;
    self.arrayOfButtonTitles = @[];
}

- (IBAction)didTapCancel:(id)sender{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)didTapSignUp:(id)sender{
    if([_firstNameTextField validate] & [_lastNameTextField validate] & [_emailTextField validate] & [_passwordTextField validate] & [_confirmPasswordTextField validate]){
        if([_tcSwitch isOn]){
            if(_alreadyExists){
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeWarning];
                [alert showAlertInView:self
                             withTitle:@"Validation Error"
                          withSubtitle:@"This email already exists. Please enter different email or login with password."
                       withCustomImage:_alertImage
                   withDoneButtonTitle:nil
                            andButtons:self.arrayOfButtonTitles];
            }
            else{
                NSString *username = [NSString stringWithFormat:@"DC_%@", [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                [[ECAPI sharedManager] createUserWithSocial:_emailTextField.text firstName:_firstNameTextField.text lastName:_lastNameTextField.text deviceToken:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getDeviceToken] facebookUserId:nil googleUserId:nil twitterUserId:nil socialConnect:@"n/a" username:username password:_passwordTextField.text callback:^(NSError *error) {
                
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
                            [[NSUserDefaults standardUserDefaults] setObject:_emailTextField.text forKey:@"SignedInUserEmail"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"n/a" forKey:@"socialUserId"];
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
                            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                            [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"password"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                
                            /*
                            [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                                           password:_passwordTextField.text
                                                                            success:^(AFOAuthCredential *credential) {
                                                                                [(AppDelegate *)[[UIApplication sharedApplication] delegate] replaceRootViewController];
                                                                            }
                                                                            failure:^(NSError *error) {
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                
                                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                    [alert show];
                                                                                });
                                                                            }];
                            */
                            
                            [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                                           password:_passwordTextField.text
                                                                            success:^(AFOAuthCredential *credential) {                                                                                ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
                                                                                if (sharedInstance.isUserLogoutTap == false){                                                                                    int count = (int)self.navigationController.viewControllers.count;
                                                                                    
                                                                                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count - 3] animated:NO];
//                                                                                    [self.mDelegate didTapSignUpButton:self.storyboardIdentifierStr];
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
        }
        else{
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert makeAlertTypeWarning];
            [alert showAlertInView:self
                         withTitle:_alertTitle
                      withSubtitle:@"Please agree to the terms and conditions."
                   withCustomImage:_alertImage
               withDoneButtonTitle:nil
                        andButtons:self.arrayOfButtonTitles];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag == 3){
        [[ECAPI sharedManager] checkIfEmailExists:_emailTextField.text callback:^(BOOL alreadyExists, NSError *error) {
            if(error){
                NSLog(@"Error adding user: %@", error.localizedDescription);
                NSLog(@"%@", error);
            }
            else{
                _alreadyExists = alreadyExists;
                if(alreadyExists){
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    [alert makeAlertTypeWarning];
                    [alert showAlertInView:self
                                 withTitle:@"Validation Error"
                              withSubtitle:@"This email already exists. Please enter different email or login with password."
                           withCustomImage:_alertImage
                       withDoneButtonTitle:nil
                                andButtons:self.arrayOfButtonTitles];
                }
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didTapViewDocument:(id)sender{
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
