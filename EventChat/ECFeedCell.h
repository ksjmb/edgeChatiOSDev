//
//  ECFeedCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/31/16.
//  Copyright © 2016 Apex Ventures, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECEventBriteName.h"
#import "ECEventBriteLogo.h"
#import "ECEventBriteStart.h"
#import "ECEventBriteVenue.h"
#import "ECEventBriteVenueAddress.h"
#import "AppDelegate.h"
#import "ECUser.h"
#import "DCFeedItem.h"
#import "DCDigitalEntityObject.h"
#import "DCTime.h"
#import "DCLocationEntityObject.h"
#import "DCDigital.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"

@class ECFeedCell;
@protocol ECFeedCellDelegate <NSObject>
- (void)mainFeedDidTapFeedITemThumbnail:(ECFeedCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapCommentsButton:(ECFeedCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapFavoriteButton:(ECFeedCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapAttendanceButton:(ECFeedCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapShareButton:(ECFeedCell *)ecFeedCell index:(NSInteger)index;
@end

@interface ECFeedCell : UITableViewCell
//@property (nonatomic, readonly) ECEventBriteEvent *event;
@property (nonatomic, weak) IBOutlet UIImageView *feedItemThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTitle;
@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTopSubText;
@property (nonatomic, weak) IBOutlet UILabel *feedItemBottomSubText;
@property (nonatomic, weak) IBOutlet UILabel *sponseredEvent;
@property (nonatomic, weak) id <ECFeedCellDelegate> delegate;
@property (nonatomic, strong) DCFeedItem *feedItem;

- (void)configureWithFeedItem:(DCFeedItem *)feedItem ecUser:(ECUser *)ecUser cellIndex:(NSIndexPath *)indexPath commentCount:(int)commentCount isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending;

@end
