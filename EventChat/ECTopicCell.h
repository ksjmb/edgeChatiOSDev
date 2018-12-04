#import <UIKit/UIKit.h>
#import "ECTopic.h"

@class ECTopicCell;
@protocol ECTopicCellDelegate <NSObject>
// delegate calls
@end

@interface ECTopicCell : UITableViewCell

@property (nonatomic, weak) id <ECTopicCellDelegate> delegate;

- (void)configureWithEvent:(ECTopic *)topic;

@end
