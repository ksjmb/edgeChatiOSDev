//
//  ECIndividualProfileViewController.h
//  EventChat
//
//  Created by Mindbowser on 11/07/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"
#import "DCNewPostViewController.h"
#import "DCInfluencersPersonDetailsTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "AddToPlaylistPopUpViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ECUser;

@interface ECIndividualProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DCNewPostViewControllerDelegate, DCInfluencersPersonDetailsTVCellDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UISearchBarDelegate, AddToPlaylistDelegate, FBSDKSharingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mBackgroundIV;
@property (weak, nonatomic) IBOutlet UIImageView *mUserProfileIV;
@property (weak, nonatomic) IBOutlet UIButton *mFollowBtn;
@property (weak, nonatomic) IBOutlet UILabel *mUserNmLabel;
@property (weak, nonatomic) IBOutlet UILabel *mUserDespLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *mSearchResultTableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *mSearchBarBtnItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bkImageViewToSearchBarTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeightConst;


@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *selectedEcUser;
@property (nonatomic, strong)ECUser *searchResultUser;

@property (nonatomic) UIBackgroundTaskIdentifier bkUptTaskId;
@property (nonatomic, retain) NSString *loginUserIdStr;

@end

NS_ASSUME_NONNULL_END
