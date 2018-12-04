//
//  DCMediaEntityObject.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCMediaEntityObject : ECJSONModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *views;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *channelUrl;
@end
