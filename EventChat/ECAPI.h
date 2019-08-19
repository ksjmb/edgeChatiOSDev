//
//  ECAPI.h
//  EventChat
//
//  Created by Jigish Belani on 2/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECHTTPRequestOperationManager.h"

@class AFOAuthCredential;
@class ECAppInfo;
@class ECEventBriteSearchResult;
@class ECUser;
@class ECComment;
@class ECEventBriteVenue;
@class ECTopic;
@class ECAttendee;
@class ECEventBriteEvent;
@class DCFeedItem;
@class DCPlaylist;
@class DCFeedItemCategory;
@class DCFeedItemFilter;
@class DCPost;

typedef void (^DCNodeApiClientSuccess)(AFHTTPRequestOperation *task, id responseObject);
typedef void (^DCNodeApiClientFailure)(AFHTTPRequestOperation *task, NSError *error);

@interface ECAPI : NSObject

@property (nonatomic, readonly) ECUser *signedInUser;
@property (nonatomic, readonly) ECUser *mLogInUser;

+ (id)sharedManager;
- (AFOAuthCredential *)getCurrentCredentials;
#pragma mark - API authorization

- (void)updateSignedInUser:(ECUser *)ecUser;
#pragma mark - App Info
- (void)getAppInfo:(NSString *)params failure:(DCNodeApiClientFailure)failure  callback:(void (^)(ECAppInfo *appInfo, NSError *error))callback;

#pragma mark - EventBrite calls
- (void)getEventsByLocation:(NSString *)params callback:(void (^)(ECEventBriteSearchResult *searchResult, NSError *error))callback;
- (void)getEventsByEventId:(NSString *)params callback:(void (^)(ECEventBriteEvent *searchResult, NSError *error))callback;
- (void)searchEventsByText:(NSString *)params callback:(void (^)(ECEventBriteSearchResult *searchResult, NSError *error))callback;
- (void)getEventVenueDetailsById:(NSString *)params callback:(void (^)(ECEventBriteVenue *ecEventBriteVenue, NSError *error))callback;


#pragma mark - FeedItem calls
- (void)getFeedItems:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)getFeedItemById:(NSString *)feedItemId callback:(void (^)(DCFeedItem *dcFeedItem, NSError *error))callback;
- (void)getFeedItemCategories:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)getFeedItemFilters:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)filterFeedItemsByCatagory:(NSString *)category callback:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)filterFeedItemsByEntityType:(NSString *)category callback:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)filterFeedItemsByFilterObject:(DCFeedItemFilter *)filter callback:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)searchFeedItemsByText:(NSString *)keywords callback:(void (^)(NSArray *searchResult, NSError *error))callback;
- (void)getRelatedEpisodes:(NSString *)series callback:(void (^)(NSArray *searchResult, NSError *error))callback;

#pragma mark - User calls
- (void)checkIfEmailExists:(NSString *)email callback:(void (^)(BOOL alreadyExists, NSError *error))callback;
- (void)getUserByEmail:(NSString *)email callback:(void (^)(ECUser *ecUser, NSError *error))callback;
- (void)getUserByUsername:(NSString *)username callback:(void (^)(ECUser *ecUser, NSError *error))callback;
- (void)createUserWithSocial:(NSString *)userEmail
                   firstName:(NSString *)firstName
                    lastName:(NSString *)lastName
                 deviceToken:(NSString *)deviceToken
              facebookUserId:(NSString *)facebookUserId
                googleUserId:(NSString *)googleUserId
               twitterUserId:(NSString *)twitterUserId
               socialConnect:(NSString *)socialConnect
                    username:(NSString *)username
                    password:(NSString *)password
                    callback:(void (^)(NSError *error))callback;
- (void)updateProfilePicUrl:(NSString *)userId
              profilePicUrl:(NSString *)profilePicUrl
                   callback:(void (^)(NSError *error))callback;
- (void)clearNotificationCount:(NSString *)userId
                      callback:(void (^)(NSError *error))callback;
- (void)getAllUsers:(void (^)(NSArray *users, NSError *error))callback;- (void)fetchUserByUserId:(NSString *)userId
                 callback:(void (^)(NSError *error))callback;
- (void)updateUser:(ECUser *)ecUser
          callback:(void (^)(ECUser *ecUser, NSError *error))callback;

#pragma mark - Follow feature methods
- (void)getFollowers:(NSString *)userId callback:(void (^)(NSArray *users, NSError *error))callback;
- (void)getFollowing:(NSString *)userId callback:(void (^)(NSArray *users, NSError *error))callback;
- (void)followUserByUserId:(NSString *)userId followeeId:(NSString *)followeeId callback:(void (^)(NSError *error))callback;
- (void)unfollowUserByUserId:(NSString *)userId followeeId:(NSString *)followeeId callback:(void (^)(NSError *error))callback;

#pragma mark - Comments
- (void)postComment:(NSString *)topicId
         feedItemId:(NSString *)feedItemId
             userId:(NSString *)userId
        displayName:(NSString *)displayName
            content:(NSString *)content
           parentId:(NSString *)parentId
             postId:(NSString *)postId
           callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;
- (void)likeComment:(NSString *)commentId
             userId:(NSString *)userId
           callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;
- (void)reportComment:(NSString *)commentId
               userId:(NSString *)userId
             callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;
- (void)deleteCommentById:(NSString *)playlistId
                 callback:(void (^)(ECComment *comment, NSError *error))callback;
- (void)fetchCommentsByTopicId:(NSString *)eventId callback:(void (^)(NSArray *comments, NSError *error))callback;
- (void)fetchCommentByCommentId:(NSString *)commentId callback:(void (^)(ECComment *ecComment, NSError *error))callback;
- (void)fetchCommentsByPostId:(NSString *)postId callback:(void (^)(NSArray *comments, NSError *error))callback;

-(void)postImageComment:(NSString *)topicId
             feedItemId:(NSString *)feedItemId
                 userId:(NSString *)userId
            displayName:(NSString *)displayName
       imageSizeInBytes:(NSInteger )imageSize
           thumbnailURL:(NSString *)thumbnailURL
               imageURL:(NSString *)imageURL
            commentType:(NSString *)commentType
               parentId:(NSString *)parentId
                 postId:(NSString *)postId
               callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;

#pragma mark - Posts
- (void)addPost:(DCPost *)post
       callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;
- (void)getPostByUserId:(NSString *)userId callback:(void (^)(NSArray *posts, NSError *error))callback;
- (void)deletePostById:(NSString *)postId
              callback:(void (^)(NSArray *posts, NSError *error))callback;
- (void)getOthersPostByUserId:(NSString *)userId callback:(void (^)(NSArray *posts, NSError *error))callback;

#pragma mark - Sign In / Out
- (void)signInUserWithEmail:(NSString *)email callback:(void (^)(NSError *error))callback;
- (void)signInUserWithEmail:(NSString *)email password:(NSString *)password callback:(void (^)(NSError *error))callback;
- (void)signInUserWithSocialUserId:(NSString *)socialUserId callback:(void (^)(NSError *error))callback;

#pragma mark - Topics
- (void)fetchTopicsByFeedItemId:(NSString *)feedItemId callback:(void (^)(NSArray *topics, NSError *error))callback;
- (void)addTopic:(NSString *)eventId
          userId:(NSString *)userId
         content:(NSString *)content
        parentId:(NSString *)parentId
        callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;

#pragma mark - Notifications
- (void)getNotificationsByUserId:(NSString *)userId callback:(void (^)(NSArray *notifications, NSError *error))callback;
- (void)acknowledgeNotification:(NSString *)notificationId
                       callback:(void (^)(NSError *error))callback;
- (void)archiveNotification:(NSString *)notificationId
                    callback:(void (^)(NSError *error))callback;

#pragma mark - Attendance
- (void)setAttendeeResponse:(NSString *)userId
                 feedItemId:(NSString *)feedItemId
                   response:(NSString *)response
                   callback:(void (^)(NSError *error))callback;
- (void)getAttendeeResponse:(NSString *)userId
                 feedItemId:(NSString *)feedItemId
                   callback:(void (^)(ECAttendee *attendances, NSError *error))callback;
- (void)getAttendeeList:(NSString *)feedItemId
               callback:(void (^)(NSArray *attendees, NSError *error))callback;

#pragma mark - Event Methods
- (void)getECEventByEBEventId:(NSString *)eventId
                     callback:(void (^)(NSArray *events, NSError *error))callback;
- (void)setFavoriteFeedItem:(NSString *)feedItemId
                     userId:(NSString *)userId
                   callback:(void (^)(ECUser *user, NSError *error))callback;
- (void)deleteFavoriteFeedItem:(NSString *)feedItemId
                    playlistId:(NSString *)playlistId
                        userId:(NSString *)userId
                      callback:(void (^)(DCPlaylist *playlist, NSError *error))callback;
- (void)getFavoriteFeedItemsByUserId:(NSString *)userId
                         callback:(void (^)(NSArray *favorites, NSError *error))callback;
- (void)addToPlaylist:(NSString *)playlistId
           feedItemId:(NSString *)feedItemId
               userId:(NSString *)userId
             callback:(void (^)(NSArray *playlists, NSError *error))callback;
- (void)getPlaylistsByUserId:(NSString *)userId
                    callback:(void (^)(NSArray *playlists, NSError *error))callback;
- (void)getFavoriteFeedItemsByFeedItemId:(NSArray *)feedItemIds
                                callback:(void (^)(NSArray *favorites, NSError *error))callback;
/*
- (void)createPlaylist:(NSString *)userId
          playlistName:(NSString *)playlistName
              callback:(void (^)(DCPlaylist *playlists, NSError *error))callback;
 */
- (void)createPlaylist:(NSString *)userId
          playlistName:(NSString *)playlistName
        playlistDescription:(NSString *)playlistDescription
         coverImageUrl:(NSString *)coverImageUrl
        thumbnailImageUrl:(NSString *)thumbnailImageUrl
              callback:(void (^)(NSArray *playlists, NSError *error))callback;
- (void)deletePlaylistById:(NSString *)playlistId
                  callback:(void (^)(NSArray *playlists, NSError *error))callback;
- (void)updatePlaylist:(NSString *)playlistId
          playlistName:(NSString *)playlistName
              callback:(void (^)(DCPlaylist *playlists, NSError *error))callback;
- (void)downloadSharedPlaylistById:(NSString *)playlistId
                            userId:(NSString *)userId
                          callback:(void (^)(DCPlaylist *playlists, NSError *error))callback;
- (void)cloneEventBriteEventToDB:(NSString *)eventId
                       eventJson:(NSString *)eventJson
                        callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback;


#pragma mark - Google API calls
- (void)getLongitudeLatitudeFromAddress:(NSString *)address
                               callback:(void (^)(NSString *lat, NSString *lng, NSError *error))callback;

#pragma mark - EdgeTV
- (void)getPlaybackUrl:(NSString *)cid
              callback:(void (^)(NSString *aPlaybackUrl, NSError *error))callback;
- (void)testPlaybackUrl:(NSString *)cid
               callback:(void (^)(NSString *aPlaybackUrl, NSError *error))callback;

#pragma mark - Get All User List
- (void)getAllUserListAPI:(void (^)(NSArray *searchResult, NSError *error))callback;
@end
