//
//  DCRelatedFeedItems.h
//  EventChat
//
//  Created by Jigish Belani on 1/9/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "DCFeedItem.h"

@interface DCRelatedFeedItems : NSMutableArray
@property (nonatomic, strong) DCFeedItem *relatedFeedItems;
@end
