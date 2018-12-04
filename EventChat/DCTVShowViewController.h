//
//  DCTVShowViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/7/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "ECAPI.h"
#import "DCSeasonSelectorTableViewController.h"
#import "DCTVShowEpisodeTableViewCell.h"

@interface DCTVShowViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, DCSeasonSelectorTableViewControllerDelegate, DCTVShowEpisodeTableViewCellDelegate>

@property (nonatomic, strong) DCFeedItem *selectedFeedItem;
@property (nonatomic, strong) NSArray *relatedFeedItems;
@property (nonatomic) int currentSeason;

@end
