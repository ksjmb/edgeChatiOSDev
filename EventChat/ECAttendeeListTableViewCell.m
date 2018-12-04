//
//  ECAttendeeListTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECAttendeeListTableViewCell.h"

@implementation ECAttendeeListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithAttendee:(ECAttendee *)attendee{
    [self.attendeeName setText:[NSString stringWithFormat:@"%@ %@", attendee.user.firstName, attendee.user.lastName]];
    [self.response setText:[attendee.response uppercaseString]];
    
    // Set profile pic
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:attendee.user.profilePicUrl]];
    UIImage *image = [UIImage imageWithData:data];
    [self.profilePic setImage:image];
}

@end
