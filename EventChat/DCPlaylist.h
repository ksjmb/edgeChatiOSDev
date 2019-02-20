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
//
@property (nonatomic, copy) NSString *thumbnailImageUrl;
@property (nonatomic, copy) NSString *coverImageUrl;
@property (nonatomic, copy) NSString *playlistDescription;
@property (nonatomic) BOOL isDeleted;
@end

/*
 {
 "_id": "5c08c11a81f0dc0f627c2748",
 "playlistName": "Default Playlist",
 "userId": "5c08c11a81f0dc0f627c2747",
 "__v": 18,
 "isDeleted": false,
 "updated_at": "2018-12-06T06:26:34.886Z",
 "created_at": "2018-12-06T06:26:34.886Z",
 "favoritedFeedItemIds": [
 "5c40835003b8b9204297ea90",
 "5c40832503b8b9204297ea8f",
 "5b32f95c3fa5b10b07f4fb58",
 "5b32f95c3fa5b10b07f4fb50",
 "5c41a0a075d5e440e47a4c98",
 "5b32f95c3fa5b10b07f4fb5a",
 "5b32f95d3fa5b10b07f4fdff",
 "5b3d812d5301b2464a81eebd",
 "5c408c7903b8b9204297ea9c",
 "5c41b79e8f1d0c489862735c",
 "5c41bb148f1d0c48986273b3",
 "5c408c5303b8b9204297ea9b",
 "5c41ddce42ff69535d9f0ba8",
 "5c41b1558f1d0c4898627309",
 "5c408d2f03b8b9204297ea9f",
 "5b3d812c5301b2464a81ee97",
 "5b3d812c5301b2464a81ee9b",
 "5b3d812d5301b2464a81ee9e"
 ],
 "canShare": true,
 "thumbnailImageUrl": "",
 "coverImageUrl": ""
 }
 */
