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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface DCNewTVShowViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DCNewTVShowEpisodeTableViewCellDelegate, DCSeasonSelectorTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *topDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UITableView *episodeTableView;
@property (weak, nonatomic) IBOutlet UIButton *episodePlayButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (nonatomic, strong) DCFeedItem *selectedFeedItem;
@property (nonatomic, strong) NSArray *relatedFeedItems;
@property (nonatomic) int currentSeason;

@end
