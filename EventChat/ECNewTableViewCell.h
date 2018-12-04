//
//  ECNewTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 26/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
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

@class ECNewTableViewCell;
@protocol ECNewTableViewCellDelegate <NSObject>
- (void)mainFeedDidTapFeedITemThumbnail:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapCommentsButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapFavoriteButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapAttendanceButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index;
- (void)mainFeedDidTapShareButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index;
@end

@interface ECNewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *episodeImageView;
@property (weak, nonatomic) IBOutlet UIButton *playSelectedEpisodeButton;
@property (weak, nonatomic) IBOutlet UILabel *nameDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;

@property (nonatomic, weak) id <ECNewTableViewCellDelegate> delegate;
@property (nonatomic, strong) DCFeedItem *feedItem;

- (void)configureWithFeedItem:(DCFeedItem *)feedItem ecUser:(ECUser *)ecUser cellIndex:(NSIndexPath *)indexPath commentCount:(int)commentCount isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending;

@end
