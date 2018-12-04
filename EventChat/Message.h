//
//  Message.h
//  Messenger
//
//  Created by Ignacio Romero Z. on 1/16/15.
//  Copyright (c) 2015 Slack Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ECUser.h"

@interface Message : NSObject
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *likeCount;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) ECUser *user;
@property (nonatomic, strong) NSArray *likedByIds;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *parantId;
@property (nonatomic, copy) NSString *commentType;
@property (nonatomic)       NSInteger imageSizeInBytes;

@end

