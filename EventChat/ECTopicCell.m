#import "ECTopicCell.h"

@interface ECTopicCell()
@property (nonatomic, weak) IBOutlet UILabel *topicTitle;
@property (nonatomic, weak) IBOutlet UILabel *commentCount;
@end

@implementation ECTopicCell

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
