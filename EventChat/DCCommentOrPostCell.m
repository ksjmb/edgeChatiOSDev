//
//  DCCommentOrPostCell.m
//  EventChat
//
//  Created by Jigish Belani on 2/2/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCCommentOrPostCell.h"
#import "ECColor.h"
#import "ECUser.h"
#import "DCFeedItem.h"
#import "ECCommonClass.h"

@implementation DCCommentOrPostCell

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
    [_commentsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_commentsButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_commentsButton imageType:DirectMessage aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [_commentsButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [_postButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_postButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_postButton imageType:Post aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [_postButton setTitle:@"Post" forState:UIControlStateNormal];
}

- (IBAction)createNewPost:(id)sender{
    if([self.delegate respondsToSelector:@selector(didTapPostButton)]){
        [self.delegate didTapPostButton];
    }
}

- (IBAction)viewComments:(id)sender{
    if([self.delegate respondsToSelector:@selector(didTapCommentsButton)]){
        [self.delegate didTapCommentsButton];
    }
}

@end
