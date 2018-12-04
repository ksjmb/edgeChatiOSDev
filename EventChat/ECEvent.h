//
//  ECEvent.h
//  EventChat
//
//  Created by Jigish Belani on 9/17/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface ECEvent : ECJSONModel
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *topicCount;
@property (nonatomic, copy) NSString *created_at;
@end
