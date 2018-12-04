//
//  ECSharedmedia.m
//  EventChat
//
//  Created by Mindbowser on 4/10/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECSharedmedia.h"


@implementation ECSharedmedia
+(id)sharedManager{
    static ECSharedmedia *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;

}
@end
