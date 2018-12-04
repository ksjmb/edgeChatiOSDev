//
//  DCCategorySortCriteria.h
//  EventChat
//
//  Created by Jigish Belani on 6/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCCategorySortCriteria : ECJSONModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *order;
@end
