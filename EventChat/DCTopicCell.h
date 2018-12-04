//
//  DCTopicCell.h
//  EventChat
//
//  Created by Jigish Belani on 7/23/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECTopic.h"

@class DCTopicCell;
@protocol DCTopicCellDelegate <NSObject>
// delegate calls
@end

@interface DCTopicCell : UITableViewCell
@property (nonatomic, weak) id <DCTopicCellDelegate> delegate;

- (void)configureWithEvent:(ECTopic *)topic;
@end
