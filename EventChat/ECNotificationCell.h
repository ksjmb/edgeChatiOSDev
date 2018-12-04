#import <UIKit/UIKit.h>
#import "ECNotification.h"

@class ECNotificationCell;
@protocol ECNotificationCellDelegate <NSObject>
// delegate calls
@end

@interface ECNotificationCell : UITableViewCell

@property (nonatomic, weak) id <ECNotificationCellDelegate> delegate;

- (void)configureWithNotification:(ECNotification *)notification;

@end
