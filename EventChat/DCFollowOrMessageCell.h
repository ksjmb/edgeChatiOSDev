//
//  DCFollowOrMessageCell.h
//  EventChat
//
//  Created by Jigish Belani on 2/2/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
@class ECUser;

@protocol DCFollowOrMessageCellDelegate <NSObject>
- (void)didTapFollowUnfollowButton;
- (void)didTapMessageButton;
@end

@interface DCFollowOrMessageCell : UITableViewCell
@property (nonatomic, strong) IBOutlet CustomButton *followUnfollowButton;
@property (nonatomic, strong) IBOutlet CustomButton *messageButton;
@property (nonatomic, weak) id <DCFollowOrMessageCellDelegate> delegate;
@property (nonatomic, assign) BOOL isSignedInUser;

- (void)configureWithUser:(ECUser *)aProfileUser signedInUser:(ECUser *)signedInUser isSignedInUser:(BOOL)isSignedInUser;

@end
