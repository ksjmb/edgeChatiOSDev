//
//  DCUserPostCell.m
//  EventChat
//
//  Created by Jigish Belani on 2/4/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCUserPostCell.h"
#import "DCPost.h"
#import "ECCommonClass.h"
#import "ECColor.h"
#import "CustomButton.h"
#import "NSDate+NVTimeAgo.h"

@implementation DCUserPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithPost:(DCPost *)post signedInUser:(ECUser *)signedInUser selectedSegment:(int)selectedSegment{
    _signedInUser = signedInUser;
    _dcPost = post;
    [_likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    if([signedInUser.likedPostIds containsObject:post.postId]){
        [_likeButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_likeButton imageType:ThumbsUp aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:20.0]];
    }
    else{
        [_likeButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_likeButton imageType:ThumbsUp aColor:[UIColor lightGrayColor] aSize:20.0]];
    }
    
    //[_likeButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_commentButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_commentButton imageType:DirectMessage aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:20.0]];
    //[_commentButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [_favoriteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    if(selectedSegment == 0){
        [_favoriteButton setHidden:YES];
    }
    else{
        [_favoriteButton setHidden:NO];
        if([signedInUser.favoritedPostIds containsObject:post.postId]){
            [_favoriteButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_commentButton imageType:Favorite aColor:[UIColor redColor] aSize:20.0]];
        }
        else{
            [_favoriteButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_commentButton imageType:Favorite aColor:[UIColor lightGrayColor] aSize:20.0]];
        }
    }
    
    [_nameLabel setText:post.displayName];
    
    // Format date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *created_atFromString = [[NSDate alloc] init];
    created_atFromString = [dateFormatter dateFromString:post.created_at];
    NSString *ago = [created_atFromString formattedAsTimeAgo];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    NSLog(@"Output is: \"%@\"", ago);
    NSLog(@"Output is: \"%@\"", [dateFormatter2 stringFromDate:created_atFromString]);
    
    [_timeLabel setText:ago];
    [_commentCount setText:[NSString stringWithFormat:@"%@ comments", post.commentCount]];
    [_postContentTextView setText:post.content];
    _postContentTextView.translatesAutoresizingMaskIntoConstraints = false;
}

- (IBAction)didTapLikeButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    if(![_signedInUser.likedPostIds containsObject:_dcPost.postId]){
        [_signedInUser.likedPostIds addObject:_dcPost.postId];
    }
    else{
        [_signedInUser.likedPostIds removeObject:_dcPost.postId];
    }
    
    if([self.delegate respondsToSelector:@selector(didTapLikeButton:)]){
        [self.delegate didTapLikeButton:indexPath];
    }
}

- (IBAction)didTapCommentButton:(id)sender{
    if([self.delegate respondsToSelector:@selector(didTapCommentButton:)]){
        [self.delegate didTapCommentButton:_dcPost];
    }
}

- (IBAction)didTapFavoriteButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    if(![_signedInUser.favoritedPostIds containsObject:_dcPost.postId]){
        [_signedInUser.favoritedPostIds addObject:_dcPost.postId];
    }
    else{
        [_signedInUser.favoritedPostIds removeObject:_dcPost.postId];
    }
    
    if([self.delegate respondsToSelector:@selector(didTapFavoriteButton:)]){
        [self.delegate didTapFavoriteButton:indexPath];
    }
}

@end
