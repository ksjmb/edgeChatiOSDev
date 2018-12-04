#import "ECJSONModel.h"
#import "ECUser.h"

@interface ECNotification : ECJSONModel

@property (nonatomic, copy) NSString *notificationId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *notifierId;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *notificationType;
@property (nonatomic, assign) BOOL acknowledged;
@property (nonatomic, copy) ECUser *notifierUser;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *feedItemId;

@end
