#import "ECJSONModel.h"

@interface ECTopic : ECJSONModel
@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *feedItemId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *created_at;

@end
