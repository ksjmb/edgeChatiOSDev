//
//  DCYTPlayerTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/27/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCYTPlayerTableViewCell.h"
#import "DCFeedItem.h"
#import "DCMediaEntity.h"
#import "DCMediaEntityObject.h"

@implementation DCYTPlayerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithFeedItem:(DCFeedItem *)feedItem{
    // Load Video
    if([feedItem.media.youtube.videoUrl rangeOfString:@"watch"].location == NSNotFound){
        [self.playerView loadWithVideoId:@"tPWtOzOynAQ"];
    }
    else{
        [self.playerView loadWithVideoId:[feedItem.media.youtube.videoUrl componentsSeparatedByString:@"="][1]];
        [self.playerView playVideo];
    }
}

@end
