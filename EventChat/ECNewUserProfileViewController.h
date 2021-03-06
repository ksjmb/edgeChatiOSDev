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
#import "AddToPlaylistPopUpViewController.h"

@class ECUser;

@interface ECNewUserProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DCNewPostViewControllerDelegate, DCInfluencersPersonDetailsTVCellDelegate, FBSDKSharingDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, AddToPlaylistDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userBGImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UIButton *mFollowButton;
@property (weak, nonatomic) IBOutlet UILabel *mUserNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *mUserProfileTableView;
@property (weak, nonatomic) IBOutlet UIButton *coverImaegButton;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mSearchBarBtnItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConst;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@property (strong, nonatomic) UIImage *fb_profile_image;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTaskId;
@property (nonatomic, assign) BOOL isCoverImage;

@property (nonatomic, retain) NSString *userIdStr;
@property (nonatomic, strong)ECUser *mLoginUser;

@property (nonatomic, retain) NSString *mLoginUId;
@property (nonatomic, retain) NSString *mfName;
@property (nonatomic, retain) NSString *mlName;
@property (nonatomic, copy) NSArray *mFolloweeIDs;
@property (nonatomic, copy) NSArray *mFollowerIDs;
@property (nonatomic, assign) int mFavCount;
@property (nonatomic, strong)ECUser *mSelectedECUser;

@end
