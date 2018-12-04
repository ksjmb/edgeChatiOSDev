//
//  S3UploadImage.h
//  EventChat
//
//  Created by Mindbowser on 4/12/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ResultBlock)( BOOL);

@interface S3UploadImage : NSObject
+(id)sharedManager;
// Method to upload Image on S3
-(void)uploadImageForData:(NSData *)imageData forFileName:(NSString *)fileNam FromController:(UIViewController *)controller andResult:(void (^)(bool))block;
-(void)uploadVideoForData:(NSData *)videoData forFileName:(NSString *)fileName FromController:(UIViewController *)controller andResult:(void (^)(bool))block;
@end
