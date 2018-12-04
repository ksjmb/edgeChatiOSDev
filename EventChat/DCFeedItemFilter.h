//
//  DCFeedItemFilter.h
//  EventChat
//
//  Created by Jigish Belani on 1/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCFeedItemFilter : ECJSONModel
@property (nonatomic, copy) NSString *filterId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *isDisplayed;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@end
