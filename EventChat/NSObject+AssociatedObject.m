//
//  NSObject+AssociatedObject.m
//  EventChat
//
//  Created by Jigish Belani on 11/8/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "NSObject+AssociatedObject.h"

@implementation NSObject (AssociatedObject)
@dynamic associatedObject;

- (void)setAssociatedObject:(id)object {
    objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}
@end    
