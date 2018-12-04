//
//  DCFollowPostButtonCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
@class ECUser;

@protocol DCFollowPostButtonCellDelegate <NSObject>
- (void)didTapNewPostButton;
- (void)didTapNewDirectMessage;
@end

@interface DCFollowPostButtonCell : UITableViewCell
@property (nonatomic, strong) IBOutlet CustomButton *followButton;
@property (nonatomic, strong) IBOutlet CustomButton *postMessageDualButton;
@property (nonatomic, weak) id <DCFollowPostButtonCellDelegate> delegate;
@property (nonatomic, assign) BOOL isSignedInUser;

- (void)configureWithUser:(ECUser *)aProfileUser isSignedInUser:(BOOL)isSignedInUser;
@end
