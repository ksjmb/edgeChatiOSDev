//
//  AppDelegate.h
//  EventChat
//
//  Created by Jigish Belani on 1/28/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECAPI.h"
#import "ECAppInfo.h"
#import "ECEventBriteSearchResult.h"
#import "CLLocation+Strings.h"
#import <Google/SignIn.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@protocol ECAppDelegate <NSObject>
- (void)replaceRootViewController;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, ECAppDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, assign) BOOL requiresFeedUpdate;
@property (nonatomic) int badgeCount;

- (void)replaceRootViewController;
- (NSString *)getDeviceToken;
- (void)clearNotificationCount;
- (void)updateBadgeCounts;
- (void)didSetRequiresFeedUpdate:(BOOL )requiresFeedUpdate;
- (void)switchTabToIndex:(NSInteger)index;
- (void)signOut;
- (void)moveViewController;
- (void)showCommentViewController:(DCFeedItem *)feedItem;

@end

/*
 Target : EdgeTVChat
 com.edgetv.prod
 */
