//
//  DCPersonProfessionObject.h
//  EventChat
//
//  Created by Jigish Belani on 1/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCPersonProfessionObject : ECJSONModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *fieldOfInterest;
@end
