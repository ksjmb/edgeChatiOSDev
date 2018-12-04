//
//  DCFollowOrMessageCell.m
//  EventChat
//
//  Created by Jigish Belani on 2/2/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCFollowOrMessageCell.h"
#import "ECColor.h"
#import "ECUser.h"
#import "DCFeedItem.h"
#import "ECCommonClass.h"

@implementation DCFollowOrMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithUser:(ECUser *)aProfileUser signedInUser:(ECUser *)signedInUser isSignedInUser:(BOOL)isSignedInUser{
    _isSignedInUser = isSignedInUser;
    [_followUnfollowButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    if([signedInUser.followeeIds containsObject:aProfileUser.userId]){
        [_followUnfollowButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_followUnfollowButton imageType:CheckMark aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
        [_followUnfollowButton setTitle:@"Following" forState:UIControlStateNormal];
    }
    else{
        [_followUnfollowButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_followUnfollowButton imageType:Follow aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
        [_followUnfollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    [_followUnfollowButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [_messageButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_messageButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_messageButton imageType:DirectMessage aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
}

- (IBAction)followOrUnfollow:(id)sender{
    if([self.delegate respondsToSelector:@selector(didTapFollowUnfollowButton)]){
        [self.delegate didTapFollowUnfollowButton];
    }
}

- (IBAction)messageUser:(id)sender{
    if([self.delegate respondsToSelector:@selector(didTapMessageButton)]){
        [self.delegate didTapMessageButton];
    }
}

@end
