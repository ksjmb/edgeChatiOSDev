//
//  DCSocialEntityObject.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCSocialEntityObject : ECJSONModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *follower_count;
@property (nonatomic, copy) NSString *url;
@end
