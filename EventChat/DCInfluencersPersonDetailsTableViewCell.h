//
//  DCInfluencersPersonDetailsTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "YTPlayerView.h"

@class DCFeedItem;
@class DCInfluencersPersonDetailsTableViewCell;

@protocol DCInfluencersPersonDetailsTVCellDelegate <NSObject>

- (void)didTapCommentsButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index;
- (void)didTapFavoriteButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index;
- (void)didTapAttendanceButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index;
- (void)didTapShareButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index;
/*
 - (void)playVideoForSelectedEpisode:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index;
- (void)viewMoreButtonTapped:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell;
 */
@end

NS_ASSUME_NONNULL_BEGIN

@interface DCInfluencersPersonDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet YTPlayerView *mPlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *mVideoImageView;
@property (weak, nonatomic) IBOutlet UIButton *mVideoPlayBtn;
@property (weak, nonatomic) IBOutlet UILabel *mVideoTitle;
@property (weak, nonatomic) IBOutlet UILabel *mVideoDescription;
@property (weak, nonatomic) IBOutlet UIButton *mVideoViewMoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *mVideoCommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *mVideoLikeBtn;
@property (weak, nonatomic) IBOutlet UILabel *mVideoCommentCount;
@property (weak, nonatomic) IBOutlet UIButton *mVideoShareBtn;
@property (weak, nonatomic) IBOutlet UIButton *mVideoFavBtn;

@property (nonatomic, weak) id <DCInfluencersPersonDetailsTVCellDelegate> dcPersonDelegate;
@property (nonatomic, strong) DCFeedItem *mDCFeedItem;

- (void)configureTableViewCellWithItem:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending indexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
