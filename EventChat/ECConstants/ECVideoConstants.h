//
//  ECVideoConstants.h
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//static const NSInteger kMaximumVideoDuration = 20; // In seconds
//static const NSInteger kMinimumVideoDuration = 5; // In seconds

@interface ECVideoConstants : NSObject
+ (id)sharedInstance;
- (UIImage *)thumbnailImageFromVideoAtURL:(NSURL *)videoURL;
- (UIImage *)compressImage:(UIImage *)image;

// Used these properties to save video filter
// processing if user selects same video with same filter & trim range
@property (strong, nonatomic) NSString *selectedVideoName;
@property (strong, nonatomic) NSString *selectedFilterName;
@property (assign) CMTimeRange trimRange;

// Final youGOvi video url after applying video filters
@property (strong, nonatomic) NSURL *outputURL;

@property (assign, getter=isecVideoReadyForUpload) BOOL ecVideoReadyForUpload;

// After successfully video uploaded or user changed the video or
// user cancelled video upload, remove video from local path
- (void)removeVideoAtECURL;
-(NSArray *)listFileAtPath:(NSString *)path;
- (void)listAppFiles;
@end
