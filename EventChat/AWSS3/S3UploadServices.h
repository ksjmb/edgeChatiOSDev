//
//  S3UploadServices.h
//  EventChat
//
//  Created by Mindbowser on 4/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ProgressCallback)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void(^SuccessCallback)(id responseObject);
typedef void(^FailureCallback)(NSError *error);

@interface S3UploadServices : NSOperation {
@private BOOL        _doneUploadingToS3;
    
}
// Method to upload Image on S3

-(void)uploadFileWithData:(NSData *)uploadData
                 filePath:(NSString *)bucketName
                 fileName:(NSString *)keyName
                 fileType:(NSString *)contentType
                 progress:(void (^)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressCallback
                  success:(void (^)(id responseObject))successCallback
                  failure:(void (^)(NSError *error))failureCallback;


@end
