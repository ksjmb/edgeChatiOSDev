//
//  DCNewTVShowViewController.h
//  EventChat
//
//  Created by Mindbowser on 14/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "ECAPI.h"
#import "DCSeasonSelectorTableViewController.h"
#import "DCNewTVShowEpisodeTableViewCell.h"
#import "SignUpLoginViewController.h"
#import "RegisterViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface DCNewTVShowViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DCNewTVShowEpisodeTableViewCellDelegate, DCSeasonSelectorTableViewControllerDelegate, SignUpLoginViewControllerDelegate, RegisterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *topDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UITableView *episodeTableView;
@property (weak, nonatomic) IBOutlet UIButton *episodePlayButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDescriptionLabelHeightConstraints;

@property (nonatomic, strong) DCFeedItem *selectedFeedItem;
@property (nonatomic, strong) NSArray *relatedFeedItems;
@property (nonatomic) int currentSeason;
@property (nonatomic, assign) BOOL isLabelExpanded;
@property (nonatomic, strong) DCFeedItem *saveFeedItem;
@property (nonatomic, assign) BOOL isTopFavButtonSelected;

-(void)pushToSignInVC :(NSString*)stbIdentifier;
-(void)sendToSpecificVC:(NSString*)identifier;
@end
