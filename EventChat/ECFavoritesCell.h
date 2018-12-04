//
//  ECFavoritesCell.h
//  EventChat
//
//  Created by Jigish Belani on 11/7/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECEventBriteStart.h"
#import "ECEventBriteLogo.h"
#import "ECEventBriteName.h"
#import "ECUser.h"
#import "ECAttendee.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"

@class ECAttendee;

@class ECEventBriteEvent;


@class ECFavoritesCell;
@protocol ECFavoritesCellDelegate <NSObject>
- (void)favoritesDidTapCommentsButton:(ECFavoritesCell *)ecFavoritesCell;
- (void)favoritesDidTapGetEventDetails:(ECFavoritesCell *)ecFavoritesCell;
@end

@interface ECFavoritesCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *feedItemThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTitle;
@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UILabel *feedItemStartTime;
@property (nonatomic, weak) IBOutlet UILabel *feedItemDetails;
@property (nonatomic, weak) IBOutlet UISegmentedControl *attendanceResponse;
//@property (nonatomic, strong) ECEventBriteEvent *favoriteEvent;
@property (nonatomic, strong)DCFeedItem *favoriteFeedItem;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, weak) id <ECFavoritesCellDelegate> delegate;
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, weak) NSArray *questionOptions;

- (void)configureWithFeedItem:(DCFeedItem *)favoriteFeedItem commentCount:(int)commentCount;

@end
