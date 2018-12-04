//
//  S3UploadServices.m
//  EventChat
//
//  Created by Mindbowser on 4/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "S3UploadServices.h"
#import <AWSS3/AWSS3.h>

@implementation S3UploadServices {
    ProgressCallback progress;
    SuccessCallback success;
    FailureCallback failure;
}

-(void)uploadFileWithData:(NSData *)uploadData
                 filePath:(NSString *)bucketName
                 fileName:(NSString *)keyName
                 fileType:(NSString *)contentType
                 progress:(void (^)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressCallback
                  success:(void (^)(id responseObject))successCallback
                  failure:(void (^)(NSError *error))failureCallback
{
    
    
    progress = progressCallback;
    success = successCallback;
    failure = failureCallback;
    
    _doneUploadingToS3 = NO;
    
    
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    AWSS3PutObjectRequest *putObjectRequest = [AWSS3PutObjectRequest new];
    putObjectRequest.bucket = bucketName;
    putObjectRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    putObjectRequest.key = keyName;
    putObjectRequest.body = uploadData;
    putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[uploadData length]];
    putObjectRequest.contentType = contentType;
    
    
    putObjectRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(progress)
            {
                progress((int)bytesSent,totalBytesSent,totalBytesExpectedToSend);
            }
            
        });
    };
    
    [[s3 putObject:putObjectRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        
        NSLog(@"Error %@",task.error.description);
        
        if (task.error != nil) {
            
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
               task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                _doneUploadingToS3 = YES;
                failure(task.error);
            }
        } else {
            _doneUploadingToS3 = YES;
            success(task);
        }
        return nil;
    }];
}


@end
