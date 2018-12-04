//
//  DCCommentOrPostCell.h
//  EventChat
//
//  Created by Jigish Belani on 2/2/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
@class ECUser;

@protocol DCCommentOrPostCellDelegate <NSObject>
- (void)didTapPostButton;
- (void)didTapCommentsButton;
@end

@interface DCCommentOrPostCell : UITableViewCell
@property (nonatomic, strong) IBOutlet CustomButton *commentsButton;
@property (nonatomic, strong) IBOutlet CustomButton *postButton;
@property (nonatomic, weak) id <DCCommentOrPostCellDelegate> delegate;
@property (nonatomic, assign) BOOL isSignedInUser;

- (void)configureWithUser:(ECUser *)aProfileUser isSignedInUser:(BOOL)isSignedInUser;
@end
