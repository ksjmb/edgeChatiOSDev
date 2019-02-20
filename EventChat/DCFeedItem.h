//
//  ECFeedItem.h
//  EventChat
//
//  Created by Jigish Belani on 7/6/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
@class DCDigital;
@class DCTime;
@class DCSocialEntity;
@class DCDigitalEntityObject;
@class DCLocationEntityObject;
@class DCMediaEntity;
@class DCMediaEntityObject;
@class DCPersonEntityObject;
@class DCEventEntityObject;
@class DCCategorySortCriteria;

@interface DCFeedItem : ECJSONModel
@property (nonatomic, strong) NSString *feedItemId;
@property (nonatomic, copy) NSString *entityType;
@property (nonatomic, copy) DCDigital *digital;
@property (nonatomic, copy) NSString *influencer;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *subDescription;
@property (nonatomic, copy) NSString *website_url;
@property (nonatomic, copy) NSString *source_url;
@property (nonatomic) bool hasWikiSource;
@property (nonatomic, copy) NSString *mainImage_url;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *coverPic_Url;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *topicCount;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, strong) DCLocationEntityObject *location;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) DCTime *time;
@property (nonatomic, strong) DCSocialEntity *social;
@property (nonatomic, strong) DCMediaEntity *media;
@property (nonatomic, strong) DCPersonEntityObject *person;
@property (nonatomic, strong) DCEventEntityObject *event;
@property (nonatomic, strong) DCCategorySortCriteria *categorySortCriteria;
@end
