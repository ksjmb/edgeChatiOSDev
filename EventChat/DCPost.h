//
//  DCPost.h
//  EventChat
//
//  Created by Jigish Belani on 2/4/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "ECUser.h"

@interface DCPost : ECJSONModel
@property (nonatomic, copy) NSString *postId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *likeCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSMutableArray *likedByUserIds;
@property (nonatomic, copy) NSMutableArray *reportedByUserIds;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *postType;
@property (nonatomic)       NSInteger imageSizeInBytes;
@property (nonatomic, copy) ECUser *user;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, assign) BOOL hasChildren;
@property (nonatomic, copy) NSArray  *childPostIds;
@property (nonatomic, copy) NSArray  *taggedUserIds;
@property (nonatomic, copy) NSArray  *mentionedUserId;
@end
