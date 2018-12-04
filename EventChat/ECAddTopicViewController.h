#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"

@class ECEventBriteEvent;
@class DCFeedItem;

@interface ECAddTopicViewController : UIViewController

//@property (nonatomic, strong)ECEventBriteEvent *selectedEvent;
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)NSString *eventId;
@property (nonatomic, weak) IBOutlet UITextView *topicTextView;

@end
