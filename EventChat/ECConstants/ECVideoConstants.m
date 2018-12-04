//
//  ECVideoConstants.m
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//


#import "ECVideoConstants.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@implementation ECVideoConstants
static ECVideoConstants *sharedAVCamConstants = nil;

+ (id)sharedInstance
{
    if (nil != sharedAVCamConstants) {
        return sharedAVCamConstants;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAVCamConstants = [[ECVideoConstants alloc] init];
    });
    return sharedAVCamConstants;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
        self.outputURL = [NSURL fileURLWithPath:pathToMovie];
    }
    return self;
}

- (UIImage *)thumbnailImageFromVideoAtURL:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(480,320);
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *currentImg = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return currentImg;
}

- (UIImage *)compressImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:[imageData length] countStyle:NSByteCountFormatterCountStyleFile]);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}

- (void)removeVideoAtECURL {
    self.ecVideoReadyForUpload = NO;
    [[NSFileManager defaultManager] removeItemAtPath:[self.outputURL absoluteString] error:NULL];
}


- (NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND at Path : %@",path);
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

- (void)listAppFiles {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *libraryDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *tmpDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    [self listFileAtPath:documentsDirectory];
    [self listFileAtPath:libraryDirectory];
    [self listFileAtPath:tmpDirectory];
}

@end
