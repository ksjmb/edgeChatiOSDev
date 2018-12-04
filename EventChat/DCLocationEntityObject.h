//
//  DCLocationEntityObject.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCLocationEntityObject : ECJSONModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *fax;
@end
