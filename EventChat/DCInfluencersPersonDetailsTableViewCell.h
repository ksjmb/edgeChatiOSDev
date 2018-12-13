//
//  DCInfluencersPersonDetailsTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DCFeedItem;

NS_ASSUME_NONNULL_BEGIN

@interface DCInfluencersPersonDetailsTableViewCell : UITableViewCell
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

-(void)configureTableViewCellWith:(DCFeedItem *)feedItem;

@end

NS_ASSUME_NONNULL_END
