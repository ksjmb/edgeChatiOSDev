//
//  DCFeedItemCategory.h
//  EventChat
//
//  Created by Jigish Belani on 1/6/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCFeedItemCategory : ECJSONModel
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@end
