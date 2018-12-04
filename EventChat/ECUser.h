#import "ECJSONModel.h"

@interface ECUser : ECJSONModel

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, copy) NSString *whatsOnYourMind;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *facebookUserId;
@property (nonatomic, copy) NSString *googleUserId;
@property (nonatomic, copy) NSString *twitterUserId;
@property (nonatomic, copy) NSString *socialConnect;
@property (nonatomic, copy) NSString *generalPush;
@property (nonatomic, copy) NSString *commentPush;
@property (nonatomic, copy) NSString *likePush;
@property (nonatomic, copy) NSString *followPush;
@property (nonatomic, copy) NSString *profilePicUrl;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, copy) NSArray *likedCommentIds;
@property (nonatomic, assign) int favoriteCount;
@property (nonatomic, copy) NSArray *favoritedEventIds;
@property (nonatomic, assign) int notificationCount;
@property (nonatomic, copy) NSArray *followeeIds;
@property (nonatomic, copy) NSArray *followerIds;
@property (nonatomic, copy) NSString *isAdmin;
@property (nonatomic, copy) NSArray *favoritedFeedItemIds;
@property (nonatomic, copy) NSArray *attendingEventIds;
@property (nonatomic, copy) NSArray *attendingFeedItemIds;
@property (nonatomic, copy) NSArray *playlistIds;
@property (nonatomic, retain) NSMutableArray *likedPostIds;
@property (nonatomic, retain) NSMutableArray *favoritedPostIds;
@property (nonatomic, retain) NSMutableArray *blockedPostByUserId;
@end
