//
//  ECTime.h
//  EventChat
//
//  Created by Jigish Belani on 7/6/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"
#import "DCDateTime.h"

@interface DCTime : ECJSONModel
@property (nonatomic, copy) DCDateTime *start;
@property (nonatomic, copy) DCDateTime *end;
@property (nonatomic, copy) NSString *duration;
@end
