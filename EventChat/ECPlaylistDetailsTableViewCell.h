//
//  ECPlaylistDetailsTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 23/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YTPlayerView.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "ECUser.h"
#import "DCPersonEntityObject.h"

@class DCPersonEntityObject;
@class ECPlaylistDetailsTableViewCell;

@protocol ECPlaylistDetailsTableViewCellDelegate <NSObject>

- (void)playVideoForSelectedEpisode:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index;
- (void)didTapCommentsButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index;
- (void)mainFeedDidTapFavoriteButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index;
- (void)mainFeedDidTapAttendanceButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index;
- (void)mainFeedDidTapShareButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index;
//- (void)viewMoreButtonTapped:(ECPlaylistDetailsTableViewCell *)ecTableViewCell;
@end

@interface ECPlaylistDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet YTPlayerView *playlistPlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *playlistImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentCountButton;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@property (nonatomic, weak) id <ECPlaylistDetailsTableViewCellDelegate> mPlaylistDelegate;
@property (nonatomic, strong) DCFeedItem *feedItem;

- (void)configureCellFeedItemWith:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending indexPath:(NSIndexPath*)indexPath;

@end
