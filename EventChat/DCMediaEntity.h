//
//  DCMediaEntity.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "DCMediaEntityObject.h"
@class DCMediaEntityObject;

@interface DCMediaEntity : ECJSONModel
@property (nonatomic, copy) DCMediaEntityObject *youtube;
@end
