//
//  DCReactionTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 22/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCReactionTableViewCell.h"

@implementation DCReactionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithAttendee:(ECAttendee *)attendee{
    [self.mNameLabel setText:[NSString stringWithFormat:@"%@ %@", attendee.user.firstName, attendee.user.lastName]];
    [self.mResponseLabel setText:[attendee.response uppercaseString]];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:attendee.user.profilePicUrl]];
    UIImage *image = [UIImage imageWithData:data];
    self.mProfileImageView.layer.cornerRadius = 20.0;
    self.mProfileImageView.clipsToBounds = YES;
    if (image != nil){
        [self.mProfileImageView setImage:image];
    }else{
    self.mProfileImageView.image = [UIImage imageNamed:@"missing-profile.png"];
    }
}

@end
