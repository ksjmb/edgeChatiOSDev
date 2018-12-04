//
//  NSObject+AssociatedObject.h
//  EventChat
//
//  Created by Jigish Belani on 11/8/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end
