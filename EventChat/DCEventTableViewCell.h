//
//  DCEventTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 2/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"

@class DCFeedItem;
@class DCEventTableViewCell;

@protocol DCEventTableViewCellDelegate <NSObject>
- (void)eventFeedDidTapFeedITemThumbnail:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index;
- (void)eventFeedDidTapCommentsButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index;
- (void)eventFeedDidTapFavoriteButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index;
- (void)eventFeedDidTapAttendanceButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index;
- (void)eventFeedDidTapShareButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index;
@end

@interface DCEventTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UIImageView *feedItemThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTitle;
@property (nonatomic, weak) IBOutlet UILabel *feedItemBottomSubText;
//@property (nonatomic, weak) IBOutlet UILabel *feedItemLeftTop;
//@property (nonatomic, weak) IBOutlet UILabel *feedItemLeftBottom;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *eventCommentCount;

@property (nonatomic, weak) id <DCEventTableViewCellDelegate> delegate;
@property (nonatomic, strong) DCFeedItem *feedItem;

- (void)configureWithFeedItem:(DCFeedItem *)feedItem ecUser:(ECUser *)ecUser cellIndex:(NSIndexPath *)indexPath commentCount:(int)commentCount isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending;

@end
