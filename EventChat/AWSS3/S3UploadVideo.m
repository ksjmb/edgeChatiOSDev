//
//  S3UploadVideo.m
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "S3UploadVideo.h"
#import "S3UploadServices.h"
#import "ECSharedmedia.h"
#import "S3Constants.h"
@implementation S3UploadVideo{
   ResultBlock _resultBlock;
}
#pragma mark - Singleton methods

+(id)sharedManager{
    static S3UploadVideo * shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        shared = [[S3UploadVideo alloc]init];
    });
    return shared;
}

-(void)uploadImageForData:(NSData *)imageData forFileName:(NSString *)fileNam FromController:(UIViewController *)controller andResult:(void (^)(bool))block{
    
    _resultBlock = [block copy];
    
    S3UploadServices *service = [S3UploadServices new];
    [service uploadFileWithData:imageData filePath:VIDEO_FILE_PATH fileName:fileNam fileType:@"image" progress:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    } success:^(id responseObject) {
        
        _resultBlock(true);
    } failure:^(NSError *error) {
        _resultBlock(false);
        NSLog(@"Error:%@",error.localizedDescription);
    }];
    
}



-(void)uploadVideoForData:(NSData *)videoData forFileName:(NSString *)fileNam FromController:(UIViewController *)controller andResult:(void (^)(bool))block{
    
    _resultBlock = [block copy];
    
    S3UploadServices *service = [S3UploadServices new];
    [service uploadFileWithData:videoData filePath:VIDEO_FILE_PATH fileName:fileNam fileType:@"video/mp4" progress:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    } success:^(id responseObject) {
        
        _resultBlock(true);
    } failure:^(NSError *error) {
        _resultBlock(false);
        NSLog(@"Error:%@",error.localizedDescription);
    }];
    
}


@end
