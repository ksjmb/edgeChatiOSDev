//
//  DCNewTVShowEpisodeTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 15/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"

@class DCNewTVShowEpisodeTableViewCell;

@protocol DCNewTVShowEpisodeTableViewCellDelegate <NSObject>
- (void)playVideoForSelectedEpisode:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index;
- (void)didTapCommentsButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index;
- (void)mainFeedDidTapFavoriteButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index;
- (void)mainFeedDidTapAttendanceButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index;
- (void)mainFeedDidTapShareButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index;
//- (void)didTapCommentsButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index;
- (void)viewMoreButtonTapped:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell;
@end

@interface DCNewTVShowEpisodeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *episodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *episodeTitle;
@property (weak, nonatomic) IBOutlet UILabel *episodeDescription;
@property (weak, nonatomic) IBOutlet UIButton *playSelectedEpisodeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *episodeDescriptionLabelHeightConstraint;

@property (nonatomic, weak) id <DCNewTVShowEpisodeTableViewCellDelegate> delegate;
@property (nonatomic, strong) DCFeedItem *feedItem;
@property (nonatomic, assign) BOOL isExpanded;

/*
- (void)configureWithFeedItem:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending;
*/
- (void)configureWithFeedItemWith:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending indexPath:(NSIndexPath*)indexPath;

@end
