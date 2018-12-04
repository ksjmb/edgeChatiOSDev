//
//  ECNavigationController.m
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECNavigationController.h"
//#import "ECVideoEditorViewController.h"
#import <Foundation/Foundation.h>
#import "ECConstants.h"

static NSString *const kIsFirstTimeOnEditVideoScreen = @"firstTimeOnEditVideoScreen";
static NSString *const kIsFirstTimeOnVideoGalleryScreen = @"firstTimeOnVideoGalleryScreen";
static NSString *const kIsFirstTimeOnPhotoGalleryScreen = @"firstTimeOnPhotoGalleryScreen";
static NSString *const kIsFirstTimeOnPhotoCaptureScreen = @"firstTimeOnPhotoCaptureScreen";
static NSString *const kIsFirstTimeOnVideoCaptureScreen = @"firstTimeOnVideoCaptureScreen";
static NSString *const kIsFirstTimeOnMenuScreen = @"firstTimeOnMenuScreen";
static NSString *const kIsFirstTimeOnOthersProfileScreen = @"firstTimeOnOthersProfileScreen";
static NSString *const kIsFirstTimeOnOwnProfileScreen = @"firstTimeOnOwnProfileScreen";
static NSString *const kIsFirstTimeOnPhotoCompetitionsScreen = @"firstTimeOnPhotoCompetitionsScreen";
static NSString *const kIsFirstTimeOnVideoCompetitionsScreen = @"firstTimeOnVideoCompetitionsScreen";
static NSString *const kIsFirstTimeOnPhotoCropScreen = @"firstTimeOnPhotoCropScreen";
static NSString *const kIsFirstTimeOnPhotoDetailsScreen = @"firstTimeOnPhotoDetailsScreen";
static NSString *const kIsFirstTimeOnVideoDetailsScreen = @"firstTimeOnVideoDetailsScreen";
static NSString *const kIsFirstTimeOnRevoteScreen = @"firstTimeOnRevoteScreen";
static NSString *const kIsFirstTimeOnPlayingVideoScreen = @"firstTimeOnPlayingVideoScreen";

@interface ECNavigationController () <UINavigationControllerDelegate>
{
    BOOL isLandingImageOnShowcase;
}
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ECNavigationController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstTimeOn",nil]];
    if ([userDefaults boolForKey:@"firstTimeOn"]) {
        [userDefaults setBool:NO forKey:@"firstTimeOn"];
        [self setFlagsForEachCoachmarkScreen];
    }
}

- (void)setFlagsForEachCoachmarkScreen {
    // To check first time ever on each page
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnEditVideoScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnVideoGalleryScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnPhotoGalleryScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnPhotoCaptureScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnVideoCaptureScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnMenuScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnOthersProfileScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnOwnProfileScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnPhotoCompetitionsScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnVideoCompetitionsScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnPhotoDetailsScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnVideoDetailsScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnRevoteScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnPlayingVideoScreen];
    [userDefaults setBool:YES forKey:kIsFirstTimeOnPhotoCropScreen];
    
//    NSInteger userId = [[AppUserData sharedInstance] userId];
//    [userDefaults setInteger:userId forKey:MGVPreviousUserId];
//    
//    [userDefaults synchronize];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    navigationController.navigationBar.hidden = YES;
    UIImage *coachMarkImage;
    CGRect closeButtonFrame;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([viewController isKindOfClass:[YGVVideoEditorController class]]) {
    //        if ([userDefaults boolForKey:kIsFirstTimeOnEditVideoScreen]) {
    //            [userDefaults setBool:NO forKey:kIsFirstTimeOnEditVideoScreen];
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkEditVideo"];
    //            closeButtonFrame = CGRectMake(125, 68, 70, 70);
    //            if (SCREEN_HEIGHT == 480) {
    //                coachMarkImage = [UIImage imageNamed:@"coachMarkEditVideo35"];
    //                closeButtonFrame = CGRectMake(125, 22, 70, 70);
    //            }
    //        }
    //    }
    //    else if ([viewController isKindOfClass:[MediaDetailController class]]) {
    //        if ([[GlobalConstants sharedInstance] sectionType] == SectionVideos) {
    //            if ([userDefaults boolForKey:kIsFirstTimeOnVideoDetailsScreen]) {
    //                [userDefaults setBool:NO forKey:kIsFirstTimeOnVideoDetailsScreen];
    //                coachMarkImage = [UIImage imageNamed:@"coachMarkVideoDetails"];
    //                closeButtonFrame = CGRectMake(125, 350, 70, 70);
    //                if (SCREEN_HEIGHT == 480) {
    //                    coachMarkImage = [UIImage imageNamed:@"coachMarkVideoDetails35"];
    //                    closeButtonFrame = CGRectMake(125, 285, 70, 70);
    //                }
    //            }
    //        } else {
    //            if ([userDefaults boolForKey:kIsFirstTimeOnPhotoDetailsScreen]) {
    //                [userDefaults setBool:NO forKey:kIsFirstTimeOnPhotoDetailsScreen];
    //                closeButtonFrame = CGRectMake(125, 350, 70, 70);
    //                coachMarkImage = [UIImage imageNamed:@"coachMarkPhotoDetails"];
    //                if (SCREEN_HEIGHT == 480) {
    //                    closeButtonFrame = CGRectMake(125, 285, 70, 70);
    //                    coachMarkImage = [UIImage imageNamed:@"coachMarkPhotoDetails35"];
    //                }
    //            }
    //        }
    //    }
    
    [userDefaults synchronize];
    if (coachMarkImage) {
        [self showCoachMarkImage:coachMarkImage closeButtonFrame:closeButtonFrame];
    }
}

- (void)showPhotoCropCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnPhotoCropScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnPhotoCropScreen];
    //        [userDefaults synchronize];
    //        CGRect frame = CGRectMake(125, 55, 70, 70);
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkPhotoCrop"];
    //        if (SCREEN_HEIGHT == 480) {
    //            frame = CGRectMake(125, 22, 70, 70);
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkPhotoCrop35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}

- (void)showVideoCompetitionCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnVideoCompetitionsScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnVideoCompetitionsScreen];
    //        [userDefaults synchronize];
    //        CGRect frame = CGRectMake(125, 355, 70, 70);
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkVideoCompetitions"];
    //        if (SCREEN_HEIGHT == 480) {
    //            frame = CGRectMake(125, 278, 70, 70);
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkVideoCompetitions35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}

- (void)showPhotoCompetitionCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnPhotoCompetitionsScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnPhotoCompetitionsScreen];
    //        [userDefaults synchronize];
    //        CGRect frame = CGRectMake(125, 355, 70, 70);
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkPhotoCompetitions"];
    //        if (SCREEN_HEIGHT == 480) {
    //            frame = CGRectMake(125, 278, 70, 70);
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkPhotoCompetitions35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}

- (void)showMyProfileCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnOwnProfileScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnOwnProfileScreen];
    //        [userDefaults synchronize];
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkOwnProfile"];
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkOwnProfile35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:CGRectMake(SCREEN_WIDTH/2-35, SCREEN_HEIGHT/2-35, 70, 70)];
    //    }
}

- (void)showOtherProfileCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnOthersProfileScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnOthersProfileScreen];
    //        [userDefaults synchronize];
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkOthersProfile"];
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkOthersProfile35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:CGRectMake(125, 248,70, 70)];
    //    }
}

- (void)showMenuCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnMenuScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnMenuScreen];
    //        [userDefaults synchronize];
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkMenu"];
    //        CGRect frame = CGRectMake(236, 489, 70, 70);
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkMenu35"];
    //            frame = CGRectMake(234, 390, 70, 70);
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}
- (void)showLandingImageOnShowcase {
    UIImage *coachMarkImage = [UIImage imageNamed:@"Pre-showcase-screen"];
    CGRect frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (SCREEN_HEIGHT == 480) {
        coachMarkImage = [UIImage imageNamed:@"Pre-showcase-screen35"];
    }
    isLandingImageOnShowcase = YES;
    [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
}
- (void)showSpinWheelCoachMarkImageOnCompetitionScreen{
    //    UIImage *coachMarkImage = [UIImage imageNamed:@"SpinWheelLarge"];
    //    CGRect frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //    if (SCREEN_HEIGHT == 480) {
    //        coachMarkImage = [UIImage imageNamed:@"SpinWheelSmall"];
    //    }
    //    isLandingImageOnShowcase = YES;
    //    [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
}
- (void)showAfterUploadCoachMarkOnUploadScreen{
    UIImage *coachMarkImage = [UIImage imageNamed:@"Share_Large"];
    CGRect frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (SCREEN_HEIGHT == 480) {
        coachMarkImage = [UIImage imageNamed:@"Share_Small"];
    }
    isLandingImageOnShowcase = YES;
    [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    
}
- (void)showPlayingVideoCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnPlayingVideoScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnPlayingVideoScreen];
    //        [userDefaults synchronize];
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkVideoPlaying"];
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkVideoPlaying35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:CGRectMake(125, 22, 70, 70)];
    //    }
}

- (void)showPhotoCaptureCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnPhotoCaptureScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnPhotoCaptureScreen];
    //        [userDefaults synchronize];
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkCapturePhoto"];
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkCapturePhoto35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:CGRectMake(125, 170, 70, 70)];
    //    }
}

- (void)showVideoCaptureCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnVideoCaptureScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnVideoCaptureScreen];
    //        [userDefaults synchronize];
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkCaptureVideo"];
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkCaptureVideo35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:CGRectMake(125, 170, 70, 70)];
    //    }
}

- (void)showVideoGalleryCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnVideoGalleryScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnVideoGalleryScreen];
    //        [userDefaults synchronize];
    //        CGRect frame = CGRectMake(125, 320, 70, 70);
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkVideoHome"];
    //        if (SCREEN_HEIGHT == 480) {
    //            frame = CGRectMake(125, 267, 70, 70);
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkVideoHome35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}

- (void)showPhotoGalleryCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnPhotoGalleryScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnPhotoGalleryScreen];
    //        [userDefaults synchronize];
    //        CGRect frame = CGRectMake(125, 320, 70, 70);
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkVideoHome"];
    //        if (SCREEN_HEIGHT == 480) {
    //            frame = CGRectMake(125, 267, 70, 70);
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkVideoHome35"];
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}

- (void)showRevoteCoachMarkImage {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults boolForKey:kIsFirstTimeOnRevoteScreen]) {
    //        [userDefaults setBool:NO forKey:kIsFirstTimeOnRevoteScreen];
    //        [userDefaults synchronize];
    //        CGRect frame = CGRectMake(125, 475, 70, 70);
    //        UIImage *coachMarkImage = [UIImage imageNamed:@"coachMarkRevote"];
    //        if (SCREEN_HEIGHT == 480) {
    //            coachMarkImage = [UIImage imageNamed:@"coachMarkRevote35"];
    //            frame = CGRectMake(125, 402, 70, 70);
    //        }
    //        [self showCoachMarkImage:coachMarkImage closeButtonFrame:frame];
    //    }
}

- (void)showCoachMarkImage:(UIImage *)coachMarkImage closeButtonFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:coachMarkImage];
    [imageView setUserInteractionEnabled:YES];
    self.imageView = imageView;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = frame;
    [closeButton setImage:[UIImage imageNamed:@"coachMarkCloseIcon"] forState:UIControlStateNormal];
    if (SCREEN_HEIGHT == 480) {
        coachMarkImage = [UIImage imageNamed:@"coachMarkCloseIcon35"];
    }
    if (isLandingImageOnShowcase) {
        isLandingImageOnShowcase = NO;
        [closeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        coachMarkImage = [UIImage imageNamed:@""];
    }
    [closeButton addTarget:self action:@selector(closeCoachMark) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageView addSubview:closeButton];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.imageView];
}

- (void)closeCoachMark {
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

@end

