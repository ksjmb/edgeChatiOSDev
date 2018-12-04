//
//  DCSeasonSelectorTableViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/9/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCSeasonSelectorTableViewController;
@protocol DCSeasonSelectorTableViewControllerDelegate <NSObject>
- (void)loadSelectedSeason:(int)selectedSeason;
@end

@interface DCSeasonSelectorTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *seasons;
@property (nonatomic) int currentSeason;
@property (nonatomic, weak) id <DCSeasonSelectorTableViewControllerDelegate> delegate;
@end
