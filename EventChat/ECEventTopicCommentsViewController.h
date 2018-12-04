#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "ECEventBriteEvent.h"
#import "ECTopicViewController.h"
#import "ECTopic.h"
#import "MessageTableViewCell.h"
#import "ECEventBriteName.h"
#import "ECComment.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "FCAlertView.h"

@class ECEventBriteEvent;
@class ECTopicViewController;
@class ECTopic;
@class MessageTableViewCell;
@class DCFeedItem;

@interface ECEventTopicCommentsViewController : SLKTextViewController<MessageTableViewCellDelegate,UIActionSheetDelegate, FCAlertViewDelegate>
//@property (nonatomic, retain)ECEventBriteEvent *selectedEvent;
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)DCPost *dcPost;
@property (nonatomic, retain)ECTopic *selectedTopic;
@property (nonatomic, assign) BOOL isPost;
@property (nonatomic, retain)NSString *topicId;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) Message *blockedMessage;
@end
