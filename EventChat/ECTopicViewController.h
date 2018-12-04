#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECTopicCell.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"


@class ECEventBriteEvent;
@class ECTopic;
@class DCFeedItem;

@interface ECTopicViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ECTopicCellDelegate>

//@property (nonatomic, strong)ECEventBriteEvent *selectedEvent;
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)NSString *eventId;

@end
