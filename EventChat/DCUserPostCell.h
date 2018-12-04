//
//  DCUserPostCell.h
//  EventChat
//
//  Created by Jigish Belani on 2/4/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCPost;
@class CustomButton;
@class ECUser;

@protocol DCUserPostCellDelegate <NSObject>
- (void)didTapLikeButton:(NSIndexPath *)indexPath;
- (void)didTapCommentButton:(DCPost *)dcPost;
- (void)didTapFavoriteButton:(NSIndexPath *)indexPath;
@end

@interface DCUserPostCell : UITableViewCell
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentCount;
@property (nonatomic, strong) IBOutlet UITextView *postContentTextView;
@property (nonatomic, weak) IBOutlet CustomButton *likeButton;
@property (nonatomic, weak) IBOutlet CustomButton *commentButton;
@property (nonatomic, weak) IBOutlet CustomButton *favoriteButton;
@property (nonatomic, strong) DCPost *dcPost;
@property (nonatomic, weak) id <DCUserPostCellDelegate> delegate;

- (void)configureWithPost:(DCPost *)post signedInUser:(ECUser *)signedInUser selectedSegment:(int)selectedSegment;
@end
