//
//  MessageTableViewCell.h
//  Messenger
//
//  Created by Ignacio Romero Zurbuchen on 9/1/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECAPI.h"
#import "DCChatReactionViewController.h"

static CGFloat kMessageTableViewCellMinimumHeight = 60.0;
static CGFloat kMessageTableViewCellAvatarHeight = 30.0;

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";
static NSString *messengerMediaCellIdentifier = @"MessengerMediaCell";

@class MessageTableViewCell;
@protocol MessageTableViewCellDelegate <NSObject>
-(void)didTapLikeComment:(MessageTableViewCell *)messageTableViewCell;
-(void)downloadButtonClickedForImage:(NSInteger)imageIndex forCell:(MessageTableViewCell *)cell;
-(void)playButtonPressed:(Message *)message;
-(void)hideAllCommentsByUser:(Message *)message;
-(void)viewReplyByUser:(Message *)message;
-(void)didTapFavImageViewByUser:(MessageTableViewCell *)messageTableViewCell;
-(void)didTapTitleLabel:(Message *)message;
@end

@interface MessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *downloadButton1;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayName;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageToDisplay;
@property (weak, nonatomic) IBOutlet UILabel *createdDateAndLikeLabel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UILabel *reportLabel;
@property (nonatomic, strong) UILabel *replyLabel;
//
@property (nonatomic, strong) UIImageView *favImageView;
@property (nonatomic, strong) UILabel *viewReplyLabel;

@property (nonatomic, strong) UIImageView * mediaImageView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIButton * downloadButton;
@property (nonatomic) BOOL usedForMessage;
@property (nonatomic, weak) id <MessageTableViewCellDelegate> delegate;
@property (nonatomic, strong) Message *message;
@property (nonatomic, strong) NSIndexPath *cellIndexPath;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) ECUser *signedInUser;
@property (atomic, strong) NSMutableArray *parentCommentIdArray;

+ (CGFloat)defaultFontSize;
+ (CGFloat)smallFontSize;
- (void)configureSubviews;
- (void)configureSubviewsForMediaCell;
- (void)configureSubviewsForChatReaction;
- (void)configureNewCell;

@end
