//
//  S3UploadImage.m
//  EventChat
//
//  Created by Mindbowser on 4/12/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "S3UploadImage.h"
#import "S3UploadServices.h"
#import "ECSharedmedia.h"
#import "S3Constants.h"

@implementation S3UploadImage{
    ResultBlock _resultBlock;

}

#pragma mark - Singleton methods

+(id)sharedManager{
    static S3UploadImage * shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        shared = [[S3UploadImage alloc]init];
    });
    return shared;
}


-(void)uploadImageForData:(NSData *)imageData forFileName:(NSString *)fileNam FromController:(UIViewController *)controller andResult:(void (^)(bool))block{
   
    _resultBlock = [block copy];
   
    S3UploadServices *service = [S3UploadServices new];
    [service uploadFileWithData:imageData filePath:PHOTO_FILE_PATH fileName:fileNam fileType:@"image" progress:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    } success:^(id responseObject) {
        
        _resultBlock(true);
    } failure:^(NSError *error) {
        _resultBlock(false);
        NSLog(@"Error:%@",error.localizedDescription);
    }];

}

-(void)uploadVideoForData:(NSData *)videoData forFileName:(NSString *)fileName FromController:(UIViewController *)controller andResult:(void (^)(bool))block{
    
    _resultBlock = [block copy];
    
    S3UploadServices *service = [S3UploadServices new];
    [service uploadFileWithData:videoData filePath:VIDEO_FILE_PATH fileName:fileName fileType:@"video/mp4 " progress:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    } success:^(id responseObject) {
        
        _resultBlock(true);
    } failure:^(NSError *error) {
        _resultBlock(false);
        NSLog(@"Error:%@",error.localizedDescription);
    }];
    
}




@end
