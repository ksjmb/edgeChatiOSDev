//
//  ECNewUserProfileViewController.h
//  EventChat
//
//  Created by Mindbowser on 14/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"
#import "DCNewPostViewController.h"
#import "DCInfluencersPersonDetailsTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@class ECUser;

@interface ECNewUserProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DCNewPostViewControllerDelegate, DCInfluencersPersonDetailsTVCellDelegate, FBSDKSharingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userBGImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UIButton *mFollowButton;
@property (weak, nonatomic) IBOutlet UILabel *mUserNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *mUserProfileTableView;

@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;

@end
