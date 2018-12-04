//
//  DCTopicCell.m
//  EventChat
//
//  Created by Jigish Belani on 7/23/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "DCTopicCell.h"

@interface DCTopicCell()
@property (nonatomic, weak) IBOutlet UILabel *topicTitle;
@property (nonatomic, weak) IBOutlet UILabel *commentCount;
@end

@implementation DCTopicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureWithEvent:(ECTopic *)topic{
    [self.topicTitle setText:topic.content];
    [self.commentCount setText:[NSString stringWithFormat:@"%@ comments", topic.commentCount]];
}

@end
