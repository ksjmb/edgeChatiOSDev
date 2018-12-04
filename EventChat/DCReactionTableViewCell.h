//
//  DCReactionTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 22/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECAttendee.h"

@interface DCReactionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mResponseLabel;

- (void)configureWithAttendee:(ECAttendee *)attendee;

@end
