//
//  DCSocialEntity.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "DCSocialEntityObject.h"

@interface DCSocialEntity : ECJSONModel
@property (nonatomic, copy) DCSocialEntityObject *facebook;
@property (nonatomic, copy) DCSocialEntityObject *twitter;
@property (nonatomic, copy) DCSocialEntityObject *instagram;
@end
