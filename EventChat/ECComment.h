#import "ECJSONModel.h"
#import "ECUser.h"

@interface ECComment : ECJSONModel

@property (nonatomic, copy) NSString *commentId;
//@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *postId;
@property (nonatomic, copy) NSString *feedItemId;
@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *likeCount;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *commentType;
@property (nonatomic, copy) NSArray  *likedByIds;
@property (nonatomic, copy) NSArray  *childCommentIds;
@property (nonatomic)       NSInteger imageSizeInBytes;
@property (nonatomic, copy) ECUser *user;
@end
