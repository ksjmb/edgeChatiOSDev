//
//  DCPersonEntityObject.h
//  EventChat
//
//  Created by Jigish Belani on 1/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
@class DCPersonProfessionObject;
@interface DCPersonEntityObject : ECJSONModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *blurb;
@property (nonatomic, copy) DCPersonProfessionObject *profession;
@property (nonatomic, copy) NSString *profilePic_url;
@end
