//
//  DCPlaylist.h
//  EventChat
//
//  Created by Jigish Belani on 11/7/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "ECUser.h"

@interface DCPlaylist : ECJSONModel
@property (nonatomic, copy) NSString *playlistId;
@property (nonatomic, copy) NSString *playlistName;
@property (nonatomic) BOOL canShare;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSArray *favoritedFeedItemIds;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *sharedByUserId;
@property (nonatomic, copy) NSString *sharingPlaylistId;
@property (nonatomic, copy) ECUser *sharedByUser;
@end
