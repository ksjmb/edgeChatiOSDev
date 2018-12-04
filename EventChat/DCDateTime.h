//
//  ECDateTime.h
//  EventChat
//
//  Created by Jigish Belani on 7/6/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCDateTime : ECJSONModel
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@end
