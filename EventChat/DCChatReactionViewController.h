//
//  DCChatReactionViewController.h
//  EventChat
//
//  Created by Mindbowser on 19/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "ECEventBriteEvent.h"
#import "ECTopicViewController.h"
#import "ECTopic.h"
#import "ECEventBriteName.h"
#import "ECComment.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "FCAlertView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "DCReactionTableViewCell.h"
#import "MessageTableViewCell.h"

@class ECEventBriteEvent;
@class ECTopicViewController;
@class ECTopic;
@class DCFeedItem;
@class MessageTableViewCell;

@interface DCChatReactionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FCAlertViewDelegate, UITextViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UILabel *monthNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *reactionsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsBottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *reactionBottomLabel;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet IQTextView *mTextView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *noDataAvailableLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *postCommentView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthNameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthDayLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelHeightConstraint;

@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)DCPost *dcPost;
@property (nonatomic, retain)ECTopic *selectedTopic;
@property (nonatomic, assign) BOOL isPost;
@property (nonatomic, assign) int viewReplyCounter;
@property (nonatomic, retain)NSString *topicId;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) Message *blockedMessage;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTaskId;

@property (nonatomic, strong) NSArray *attendeeList;
@property (weak, nonatomic) IBOutlet UITableView *attendeeListTableView;
//@property (nonatomic, strong) NSMutableArray *mainParentIdArray;
@property (nonatomic, strong) NSMutableArray *childParentIdArray;
@property (nonatomic, assign) BOOL isCommingFromEvent;

@end
