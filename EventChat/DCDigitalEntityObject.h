//
//  DCDigitalEntityObject.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCDigitalEntityObject : ECJSONModel
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *series;
@property (nonatomic, copy) NSString *season;
@property (nonatomic, copy) NSString *episode;
@end
