//
//  ECSharedmedia.h
//  EventChat
//
//  Created by Mindbowser on 4/10/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ECSharedmedia : NSObject
+(id)sharedManager;


@property (nonatomic, strong) NSString *    mediaImageThumbURL;
@property (nonatomic, strong) NSString *    mediaImageURL;
@property (nonatomic, strong) UIImage  *    mediaImage;
@property (nonatomic, strong) UIImage  *    mediaThumbImage;
@property (nonatomic)         NSInteger     imageSizeInBytes;
@property (nonatomic,strong)  NSData   *    imageData;


@end
