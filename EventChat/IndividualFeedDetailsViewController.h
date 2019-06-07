//
//  IndividualFeedDetailsViewController.h
//  EventChat
//
//  Created by Mindbowser on 04/06/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "ECAPI.h"
#import "AddToPlaylistPopUpViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndividualFeedDetailsViewController : UIViewController <AddToPlaylistDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mBgImgView;
@property (weak, nonatomic) IBOutlet UIButton *mVideoPlayButton;
@property (weak, nonatomic) IBOutlet UILabel *mEpsdDecsLabel;
@property (weak, nonatomic) IBOutlet UIButton *mShareBtn;
@property (weak, nonatomic) IBOutlet UIButton *mFavBtn;

@property (nonatomic, strong) DCFeedItem *mFeedItem;
@property (nonatomic, strong) NSArray *relatedFeedItemArr;

@end

NS_ASSUME_NONNULL_END
