//
//  DCTVShowEpisodeTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/8/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"

@class DCTVShowEpisodeTableViewCell;
@protocol DCTVShowEpisodeTableViewCellDelegate <NSObject>
- (void)playVideoForSelectedEpisode:(DCTVShowEpisodeTableViewCell *)dcTVShowEpisodeTableViewCell index:(NSInteger)index;
- (void)didTapCommentsButton:(DCTVShowEpisodeTableViewCell *)dcTVShowEpisodeTableViewCell index:(NSInteger)index;
@end

@interface DCTVShowEpisodeTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *episodeImageView;
@property (nonatomic, weak) IBOutlet UILabel *episodeTitle;
@property (nonatomic, weak) IBOutlet UILabel *episodeDescription;
@property (nonatomic, weak) IBOutlet UIButton *commentsButton;
@property (nonatomic, strong) IBOutlet UIButton *playSelectedEpisodeButton;
@property (nonatomic, weak) id <DCTVShowEpisodeTableViewCellDelegate> delegate;

- (void)configureWithFeedItem:(DCFeedItem *)feedItem;
@end
