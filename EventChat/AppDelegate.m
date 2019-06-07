//
//  AppDelegate.m
//  EventChat
//
//  Created by Jigish Belani on 1/28/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "AppDelegate.h"
#import "ECColor.h"
#import "SignUpLoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <TwitterKit/TwitterKit.h>
#import "ECUser.h"
//#import "S3ServiceHandler.h"
#import "S3ServiceHandler.h"
#import "AFOAuth2Manager.h"
#import "ECAuthAPI.h"
#import "Branch.h"
#import "DCBranchIOParams.h"
#import "ECAPI.h"
#import "SVProgressHUD.h"
#import "IonIcons.h"
#import "ECEventTopicCommentsViewController.h"
#import "DCFeedItem.h"
#import "ECFeedViewController.h"
#import "ECCommonClass.h"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

#define GOOGLE_SCHEME @"com.googleusercontent.apps.825440785631-9n75nk5c9u49smh3oc08sd3r7fkqka3u"
//#define GOOGLE_SCHEME @"com.googleusercontent.apps.190223769082-ti5caahchke46c91husp9s27nqs13pcc"
#define FACEBOOK_SCHEME  @"fb970735719670767"
#define FACEBOOK_SCHEME_P90xChat  @"fb1403926949689578"
#define FACEBOOK_SCHEME_EdgeTVChat @"fb133172340606837"
#define FACEBOOK_SCHEME_CoachellaChat @"fb319153485197966"
#define FACEBOOK_SCHEME_BankChat @"fb119684115322604"

static NSString * const kClientBaseURL = @"http://localhost:3000";
static NSString * const kClientID = @"iOS";
static NSString * const kClientSecret = @"7A1017A3-7309-4F7F-8F88-F32B11EFB71A";

@interface AppDelegate ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, strong)ECUser *signedInUser;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // S3 initilaization
    [S3ServiceHandler initializeS3Service];
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
    NSLog(@"BaseAPIUrl: %@" , [[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]);
    NSLog(@"BaseDB: %@" , [[[NSBundle mainBundle] infoDictionary] valueForKey: @"DBName"]);
    NSLog(@"APIVersion: %@", [[[NSBundle mainBundle] infoDictionary] valueForKey: @"APIVersion"]);
    
    //register notification
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.tabBarController.delegate = self;
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        self.tabBarController = (UITabBarController *)self.window.rootViewController;
    } else {
        NSLog(@"Root view controller expected to be Tab Bar Controller at launch");
    }
    
    //@kj_undo_changes
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpLoginViewController = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    self.window.rootViewController = signUpLoginViewController;
   
    /*
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ECFeedViewController *ecFeedViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ECFeedViewController"];
    self.window.rootViewController = ecFeedViewController;
    self.window.rootViewController = self.tabBarController;
    [self.tabBarController setSelectedIndex:0];
     */
     
    // UIAppearance configuration
    // Set placeholder viewcontroller
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userEmail = [defaults objectForKey:@"SignedInUserEmail"];
    NSString *socialUserId = [defaults objectForKey:@"socialUserId"];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    
//    [[NSUserDefaults standardUserDefaults] setValue:userEmail forKey:@"SignedInUserEmail"];
    //NSString *socialUserId = @"10153412688527026";
    
    //TODO: Display logging-in loading screen here
    if(username != nil && ![username isEqual:@""]){
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//        [SVProgressHUD showWithStatus:@"Authenticating..."];
        [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                       password:password
                                                        success:^(AFOAuthCredential *credential) {
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                                                         1 * NSEC_PER_SEC),
                                                                           dispatch_get_main_queue(),
                                                                           ^{ 
                                                                               [[ECAPI sharedManager] getUserByUsername:username callback:^(ECUser *ecUser, NSError *error) {
                                                                                   if(error){
                                                                                       NSLog(@"Error: %@", error);
                                                                                       [SVProgressHUD dismiss];
                                                                                   }
                                                                                   else{
                                                                                       NSLog(@"User: %@", ecUser);
                                                                                       [SVProgressHUD dismiss];
                                                                                       ECCommonClass *instance = [ECCommonClass sharedManager];
                                                                                       instance.isAouthToken = true;
                                                                                       [self updateApplicationData];
                                                                                       [self replaceRootViewController];
                                                                                   }
                                                                               }];
                                                                           });
                                                            
                                                        }
                                                        failure:^(NSError *error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                [alert show];
                                                                
                                                                UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
                                                                SignUpLoginViewController *signUpLoginViewController = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
                                                                self.window.rootViewController = signUpLoginViewController;
                                                            });
                                                        }];
    }else{
        /*
         "grant_type" = password;
         password = qwertyuio;
         scope = "edgetvchat_stage";
         username = "DC_4786EF0D6BCB43F7971EC0FD65A18E4F";
         */
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//        [SVProgressHUD showWithStatus:@"Authenticating..."];
        [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:@"jigish"
                                                       password:@"test1234"
                                                        success:^(AFOAuthCredential *credential) {
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                                                         1 * NSEC_PER_SEC),
                                                                           dispatch_get_main_queue(),
                                                                           ^{
                                                                               ECCommonClass *instance = [ECCommonClass sharedManager];
                                                                               instance.isAouthToken = true;
                                                                               [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                                                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                                                               
                                                                               UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                               ECFeedViewController *ecFeedViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ECFeedViewController"];
                                                                               self.window.rootViewController = ecFeedViewController;
                                                                               self.window.rootViewController = self.tabBarController;
                                                                               [self.tabBarController setSelectedIndex:0];
                                                                           });
                                                            
                                                        }
                                                        failure:^(NSError *error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                [alert show];
                                                            });
                                                        }];
        
    }
    
    self.window.backgroundColor = [ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBar appearance] setSelectedImageTintColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                            NSFontAttributeName : [UIFont fontWithName:@"VOYAGER-LIGHT" size:17.0]}];
    
    // Navigation bar appearance
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
//    [[UINavigationBar appearance] setTranslucent:YES];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
    [self getCurrentLocation];
    
    // 3rd party SDK
    // Facebook
    [FBSDKLoginButton class];
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                             didFinishLaunchingWithOptions:launchOptions];
    // Twitter
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    
    // Google
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    [GIDSignIn sharedInstance].clientID = @"825440785631-9n75nk5c9u49smh3oc08sd3r7fkqka3u.apps.googleusercontent.com";
    [GIDSignIn sharedInstance].delegate = self;
    
    // Branch initialization
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            NSLog(@"params: %@", params.description);
            NSError *error;
            NSLog(@"initSession succeeded with params: %@", params);
            DCBranchIOParams *branchParams = [[DCBranchIOParams alloc] initWithDictionary:params error:nil];
            if (params[BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] && branchParams.playlistId) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             1 * NSEC_PER_SEC),
                               dispatch_get_main_queue(),
                               ^{
                                   if ([[ECAPI sharedManager] signedInUser] != nil){
                                       [[ECAPI sharedManager] downloadSharedPlaylistById:branchParams.playlistId userId:[[ECAPI sharedManager] signedInUser].userId callback:^(DCPlaylist *playlists, NSError *error) {
                                           if(error){
                                               NSLog(@"Error: %@", error);
                                           }
                                           else{
                                               UIAlertView *alertView = [[UIAlertView alloc]
                                                                         initWithTitle:@"Playlist"
                                                                         message:@"A new playlist has been downloaded to your profile. Navigate to More -> Playlists collection to access it."
                                                                         delegate:nil
                                                                         cancelButtonTitle:@"Okay"
                                                                         otherButtonTitles:nil];
                                               [alertView show];
                                           }
                                       }];
                                   }
                               });
            }
            else {
                NSLog(@"Branch TestBed: Finished init with params\n%@", params.description);
            }
        }
    }];
    
    [[self.tabBarController.tabBar.items objectAtIndex:1] setImage:[IonIcons imageWithIcon:ion_android_calendar size:30.0 color:[UIColor grayColor]]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setSelectedImage:[IonIcons imageWithIcon:ion_android_calendar size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]]];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setImage:[IonIcons imageWithIcon:ion_ios_bell size:30.0 color:[UIColor grayColor]]];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setSelectedImage:[IonIcons imageWithIcon:ion_ios_bell size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    [self getCurrentLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)replaceRootViewController{
    self.window.rootViewController = self.tabBarController;
    [self.tabBarController setSelectedIndex:0];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    if(self.signedInUser.notificationCount != 0){
        _badgeCount = self.signedInUser.notificationCount;
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d", _badgeCount]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = _badgeCount;
    }
}

- (void)updateApplicationData{
    [self getCurrentLocation];
}

/* Allow Landscape mode for specific ViewControllers */
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIViewController* topVC = [self topViewControllerWith: self.window.rootViewController];
    if ([topVC respondsToSelector:@selector(canRotate)]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else if ([topVC isKindOfClass:NSClassFromString(@"AVFullScreenViewController")]){
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

/* get the top ViewController */
- (UIViewController*) topViewControllerWith:(UIViewController *)rootViewController {
    if (rootViewController == nil) { return nil; }
    if ([rootViewController isKindOfClass: [UITabBarController class]]) {
        return [self topViewControllerWith: ((UITabBarController*) rootViewController).selectedViewController];
    }
    else if ([rootViewController isKindOfClass: [UINavigationController class]]) {
        return [self topViewControllerWith: ((UINavigationController*) rootViewController).visibleViewController];
    }
    else if (rootViewController.presentedViewController != nil) {
        return [self topViewControllerWith: [rootViewController presentedViewController]];
    }
    return rootViewController;
}

#pragma mark - Appdelegate Method
-(void)clearNotificationCount{
    [[ECAPI sharedManager] clearNotificationCount:self.signedInUser.userId callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error while clearNotificationCount: %@", error);
        } else {
            [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }];
}

- (void)updateBadgeCounts{
    if(_badgeCount > 0){
        _badgeCount = _badgeCount - 1;
        if(_badgeCount == 0){
            [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
        }
        else{
            [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d", _badgeCount]];
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = _badgeCount;
    }
}

- (void)backToMainVC{
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    [tabBar setSelectedIndex:0];
}

- (void)didSetRequiresFeedUpdate:(BOOL )requiresFeedUpdate{
    self.requiresFeedUpdate = requiresFeedUpdate;
}

- (void)switchTabToIndex:(NSInteger)index{
    [self.tabBarController setSelectedIndex:index];
}

- (void)showCommentViewController:(DCFeedItem *)feedItem{
    
}
#pragma mark - Location Manager Delegate
- (void)getCurrentLocation
{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    if (location.horizontalAccuracy >= self.locationManager.desiredAccuracy){
        [self.locationManager stopUpdatingLocation];
        self.lastLocation = location;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    NSLog(@"CLLocationManager Error: %@", error);
}

- (void)signOut{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //
    self.signedInUser = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FB_PROFILE_PIC_URL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ECFeedViewController *ecFeedViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ECFeedViewController"];
    self.window.rootViewController = ecFeedViewController;
    self.window.rootViewController = self.tabBarController;
    [self.tabBarController setSelectedIndex:0];
    
    /*
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpLoginViewController = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    self.window.rootViewController = signUpLoginViewController;
     */
}

#pragma mark - 3rd party login
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    if ([[url scheme] isEqualToString:GOOGLE_SCHEME])
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        
    if ([[url scheme] isEqualToString:FACEBOOK_SCHEME] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_P90xChat] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_EdgeTVChat] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_CoachellaChat] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_BankChat])
        return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                       annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
     return NO;
}


#pragma mark - Facebook Methods
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // pass the url to the handle deep link call
    [[Branch getInstance]
     application:application
     openURL:url
     sourceApplication:sourceApplication
     annotation:annotation];
    
    if ([[url scheme] isEqualToString:GOOGLE_SCHEME])
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    
    if ([[url scheme] isEqualToString:FACEBOOK_SCHEME] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_P90xChat] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_EdgeTVChat] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_CoachellaChat] || [[url scheme] isEqualToString:FACEBOOK_SCHEME_BankChat])
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                               openURL:url
                                                     sourceApplication:sourceApplication
                                                            annotation:annotation];
    
    return NO;
}

#pragma mark - Twitter Methods

#pragma mark - Google Methods
//- (BOOL)application:(UIApplication *)app
//            openURL:(NSURL *)url
//            options:(NSDictionary *)options {
//    return [[GIDSignIn sharedInstance] handleURL:url
//                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//}
//
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
        if(user != nil){
        // Perform any operations on signed in user here.
        NSString *userId = user.userID;                  // For client-side use only!
        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        NSString *fullName = user.profile.name;
        NSString *givenName = user.profile.givenName;
        NSString *familyName = user.profile.familyName;
        NSString *email = user.profile.email;
            NSString *tempPassword = [[[NSUUID UUID] UUIDString] componentsSeparatedByString:@"-"][0];
            NSString *username = [NSString stringWithFormat:@"GP_%@", userId];
        // ...
            
            [[ECAPI sharedManager] createUserWithSocial:email firstName:givenName lastName:familyName deviceToken:self.deviceToken facebookUserId:nil googleUserId:userId twitterUserId:nil socialConnect:@"Google" username:username password:tempPassword callback:^(NSError *error) {
                if (error) {
                    NSLog(@"Error adding user: %@", error);
                    NSLog(@"%@", error);
                    //!!!: This is a clumsy way to handle the error
                    //!!!: The "error" may just be that you have a nil status (which should actually be fine)
                    UIAlertView *alertView = [[UIAlertView alloc]
                                              initWithTitle:@"Google error"
                                              message:[NSString stringWithFormat:@"%@", error]
                                              delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
                    [alertView show];
                }
                else{
                    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"SignedInUserEmail"];
                    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"socialUserId"];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
                    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] setObject:tempPassword forKey:@"password"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[ECAuthAPI sharedClient] signInWithUsernameAndPassword:username
                                                                   password:tempPassword
                                                                    success:^(AFOAuthCredential *credential) {
                                                                        [self replaceRootViewController];
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

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}

#pragma mark - APNS Method
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"didRegisterUser");
        [application registerForRemoteNotifications];
    }
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //RegisteringforRemoteNotifications
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self setDeviceToken:newToken];
    
    NSLog(@"My token is: %@", newToken);
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    [[ECAPI sharedManager] signInUserWithEmail:self.signedInUser.email callback:
     ^(NSError *error) {
         if (error) {
         }
         else {
             self.signedInUser = [[ECAPI sharedManager] signedInUser];
             
             if(self.signedInUser.notificationCount != 0){
                 [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d", self.signedInUser.notificationCount]];
             }
         }
     }];
}

- (NSString *)getDeviceToken{
    return self.deviceToken;
}

#pragma mark - Branch.io

// Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}

@end
