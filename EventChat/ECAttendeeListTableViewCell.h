//
//  ECAttendeeListTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECAttendee.h"

@interface ECAttendeeListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *attendeeName;
@property (nonatomic, weak) IBOutlet UILabel *response;
@property (nonatomic, weak) IBOutlet UIImageView *profilePic;

- (void)configureWithAttendee:(ECAttendee *)attendee;
@end
