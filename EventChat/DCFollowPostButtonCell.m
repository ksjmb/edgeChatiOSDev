//
//  DCFollowPostButtonCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCFollowPostButtonCell.h"
#import "ECColor.h"
#import "ECUser.h"
#import "DCFeedItem.h"
#import "ECCommonClass.h"

@implementation DCFollowPostButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithUser:(ECUser *)aProfileUser isSignedInUser:(BOOL)isSignedInUser {
    _isSignedInUser = isSignedInUser;
    [_followButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_followButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_followButton imageType:Follow aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [_followButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [_postMessageDualButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    if(isSignedInUser){
        [_postMessageDualButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_postMessageDualButton imageType:Post aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
        [_postMessageDualButton setTitle:@"Post" forState:UIControlStateNormal];
    }
    else{
        [_postMessageDualButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_postMessageDualButton imageType:DirectMessage aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
        [_postMessageDualButton setTitle:@"Message" forState:UIControlStateNormal];
    }
    
    
}

- (IBAction)didTapPostMessageDualButton:(id)sender{
    if(_isSignedInUser){
        if([self.delegate respondsToSelector:@selector(didTapNewPostButton)]){
            [self.delegate didTapNewPostButton];
        }
    }
    else{
        if([self.delegate respondsToSelector:@selector(didTapNewDirectMessage)]){
            [self.delegate didTapNewDirectMessage];
        }
    }
}

@end
