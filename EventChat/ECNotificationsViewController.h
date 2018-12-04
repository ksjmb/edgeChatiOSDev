#import <UIKit/UIKit.h>
#import "ECNotificationCell.h"
#import "ECComment.h"
#import "ECTopic.h"
#import "ECEventBriteEvent.h"

@class ECNotification;

@interface ECNotificationsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ECNotificationCellDelegate>

@end
