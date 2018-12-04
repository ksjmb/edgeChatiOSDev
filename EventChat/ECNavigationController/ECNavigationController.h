//
//  ECNavigationController.h
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECNavigationController : UINavigationController
- (void)showVideoGalleryCoachMarkImage;
- (void)showPhotoGalleryCoachMarkImage;
- (void)showRevoteCoachMarkImage;
- (void)showPlayingVideoCoachMarkImage;
- (void)showPhotoCaptureCoachMarkImage;
- (void)showVideoCaptureCoachMarkImage;
- (void)showMenuCoachMarkImage;
- (void)showMyProfileCoachMarkImage;
- (void)showOtherProfileCoachMarkImage;
- (void)showPhotoCompetitionCoachMarkImage;
- (void)showVideoCompetitionCoachMarkImage;
- (void)showPhotoCropCoachMarkImage;

- (void)setFlagsForEachCoachmarkScreen;
- (void)showLandingImageOnShowcase;
- (void)showSpinWheelCoachMarkImageOnCompetitionScreen;
- (void)showAfterUploadCoachMarkOnUploadScreen;
@end
