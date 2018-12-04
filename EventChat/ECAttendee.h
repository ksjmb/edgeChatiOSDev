//
//  ECAttendee.h
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "ECUser.h"

@interface ECAttendee : ECJSONModel

@property (nonatomic, copy) NSString *attendeeId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) ECUser *user;
@property (nonatomic, copy) NSString *response;
@property (nonatomic, copy) NSString *created_at;
@end
