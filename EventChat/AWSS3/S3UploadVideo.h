//
//  S3UploadVideo.h
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ResultBlock)( BOOL);
@interface S3UploadVideo : NSObject
+(id)sharedManager;
// Method to upload Image on S3
-(void)uploadVideoForData:(NSData *)videoData forFileName:(NSString *)fileNam FromController:(UIViewController *)controller andResult:(void (^)(bool))block;
-(void)uploadImageForData:(NSData *)imageData forFileName:(NSString *)fileNam FromController:(UIViewController *)controller andResult:(void (^)(bool))block;
@end
