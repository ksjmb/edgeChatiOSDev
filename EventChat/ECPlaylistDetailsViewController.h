//
//  ECPlaylistDetailsViewController.h
//  EventChat
//
//  Created by Mindbowser on 23/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "ECAPI.h"
#import "DCSeasonSelectorTableViewController.h"
#import "ECPlaylistDetailsTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
//
#import "ECEventBriteEvent.h"
#import "DCTime.h"

@class ECEventBriteEvent;
@class ECPlaylistDetailsTableViewCell;

@interface ECPlaylistDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ECPlaylistDetailsTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *playlistViewMoreBtn;
@property (weak, nonatomic) IBOutlet UIView *horizontalItemView;
@property (weak, nonatomic) IBOutlet UITableView *playDetailsTableView;
//
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *mSignedInUser;
@property (nonatomic, strong)ECUser *mProfileUser;
@property (nonatomic, strong) NSMutableArray *favListArray;
@property (nonatomic, copy) NSString *mPlaylistId;
@property (nonatomic, copy) NSString *mPlaylistName;
@property (nonatomic, assign) BOOL isCanShare;

@end
