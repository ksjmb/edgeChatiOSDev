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

NS_ASSUME_NONNULL_BEGIN

@class ECUser;

@interface ECIndividualProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DCNewPostViewControllerDelegate, DCInfluencersPersonDetailsTVCellDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mBackgroundIV;
@property (weak, nonatomic) IBOutlet UIImageView *mUserProfileIV;
@property (weak, nonatomic) IBOutlet UIButton *mFollowBtn;
@property (weak, nonatomic) IBOutlet UILabel *mUserNmLabel;
@property (weak, nonatomic) IBOutlet UILabel *mUserDespLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;

@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *selectedEcUser;

@property (nonatomic) UIBackgroundTaskIdentifier bkUptTaskId;

@end

NS_ASSUME_NONNULL_END
