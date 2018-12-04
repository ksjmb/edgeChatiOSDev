//
//  MediaBrowser.m
//  WhoTree
//
//  Created by Mindbowser on 15/11/13.
//  Copyright (c) 2013 Bhushan Biniwale. All rights reserved.
//

#import "MediaBrowser.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RSKImageCropViewController.h"
#import "ECConstants.h"
#import <AVFoundation/AVFoundation.h>

NSString *const kMediaBrowserMediaType = @"mediaType";
NSString *const kMediaBrowserSourceType = @"sourceType";
NSString *const kMediaBrowserIsForProfilePic = @"isForProfilePic";
NSString *const kMediaBrowserShouldCropImage = @"shouldCropImage";

@interface MediaBrowser () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate>
@property (nonatomic, strong) MediaBrowserCompletionHandler completionHandler;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (assign) BOOL forProfilePic;
@property (assign) BOOL shouldCropImage;
@property (nonatomic) SectionType sectionType;
@end

@implementation MediaBrowser

static MediaBrowser *sharedMediaBrowser = nil;

+ (id)sharedInstance
{
    if (nil != sharedMediaBrowser) {
        return sharedMediaBrowser;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMediaBrowser = [[MediaBrowser alloc] init];
    });
    return sharedMediaBrowser;
}

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller mediaOutputSettings:(NSDictionary *)outputSettings completionHandler:(MediaBrowserCompletionHandler)completion
{
    NSInteger sourceType = [[outputSettings objectForKey:kMediaBrowserSourceType] integerValue];
    NSString *aMediaType = [outputSettings objectForKey:kMediaBrowserMediaType];
    BOOL isForProfilePic = [[outputSettings objectForKey:kMediaBrowserIsForProfilePic] boolValue];
    BOOL shouldCropImage = [[outputSettings objectForKey:kMediaBrowserShouldCropImage] boolValue];
    
    self.shouldCropImage = shouldCropImage;
    
    if (([UIImagePickerController isSourceTypeAvailable:sourceType] == NO)
        || (controller == nil)) {
        return NO;
    }
    
    // If media type is movie and we do not have enought space to record video, return NO
    NSInteger videoMaxDuration = kMaximumVideoDuration; // Seconds
    if ([aMediaType isEqualToString:ECvideo]) {
        videoMaxDuration = 10 * ((NSInteger)[self getFreeDiskspace]/100);
        videoMaxDuration = videoMaxDuration > kMaximumVideoDuration ? kMaximumVideoDuration : videoMaxDuration;
        if (videoMaxDuration < 10) {
           // [[GlobalConstants sharedInstance] alertViewTitle:ECAppName message:@"You do not have enough memory to record a video"];
            return NO;
        }
    }
    
    self.completionHandler = nil;
    self.completionHandler = [completion copy];
    
    self.forProfilePic = isForProfilePic;
        
    // Remove any previous instance
    self.imagePickerController = nil;
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    NSString *mediaType = (NSString *) kUTTypeImage;
    if ([aMediaType isEqualToString:ECvideo]) {
        mediaType = (NSString *) kUTTypeMovie;
        self.imagePickerController.videoMaximumDuration = videoMaxDuration; // Seconds
    }
    self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:mediaType, nil];
    self.imagePickerController.allowsEditing = NO;
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = sourceType;
    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && !isForProfilePic) {
        self.imagePickerController.cameraOverlayView = [self cameraOverlayView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil];
    }
    
    [controller presentViewController:self.imagePickerController animated:YES completion:nil];
    return YES;
}

-(void)handleNotification:(NSNotification *)message {
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidCaptureItem"]) {
        // Remove overlay, so that it is not available on the preview view;
        self.imagePickerController.cameraOverlayView = nil;
    }
    if ([[message name] isEqualToString:@"_UIImagePickerControllerUserDidRejectItem"]) {
        // Retake button pressed on preview. Add overlay, so that is available on the camera again
        self.imagePickerController.cameraOverlayView = [self cameraOverlayView];
    }
}

- (UIView *)cameraOverlayView {
    
    UIImageView *customCameraButton = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.imagePickerController.view.frame)/2-26, CGRectGetHeight(self.imagePickerController.view.frame)-62.5, 52, 52)];
    
    customCameraButton.image = [UIImage imageNamed:@"GOviCamAddVideoIcon"];
   // SectionType sectionType = [[GlobalConstants sharedInstance] sectionType];
    if (_sectionType == SectionPhotos) {
        customCameraButton.image = [UIImage imageNamed:@"GOviPhotoAddPhotoIcon"];
    }
    
    return customCameraButton;
}

// This method will return available memory space space
- (uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return ((totalFreeSpace/1024ll)/1024ll);
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        imageToUse = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        // If image selected for profile pic - show cropping option
        if (self.forProfilePic) {
            RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:imageToUse cropMode:RSKImageCropModeCircle];
            imageCropVC.delegate = self;
            [picker pushViewController:imageCropVC animated:YES];
        } else {
            // Compress the image
            if (self.shouldCropImage) {
                imageToUse = [self imageWithImage:imageToUse scaledToSize:CGSizeMake(300, 300)];
            }
            
            if (self.completionHandler) {
                self.completionHandler(imageToUse);
            }
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *movieURL = info[UIImagePickerControllerMediaURL];
        NSLog(@"movieURL : %@",movieURL.absoluteString);
        if (self.completionHandler) {
//            NSURL *recordedTmpFile = [info objectForKey:UIImagePickerControllerMediaURL];
//            
//            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:recordedTmpFile];
//            
//            CMTime duration = playerItem.duration;
//            float seconds = CMTimeGetSeconds(duration);
            
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
            
            NSTimeInterval durationInSeconds = 0.0;
            if (asset)
                durationInSeconds = CMTimeGetSeconds(asset.duration);
            NSLog(@"Duration = %f",durationInSeconds);
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:durationInSeconds] forKey:ECMediaLength];
            [[NSUserDefaults standardUserDefaults]synchronize];
            self.completionHandler(movieURL);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
   // [self generatePhotoThumbnail:image];
    float oldWidth = image.size.width;
    float scaleFactor = newSize.width / oldWidth;
    
    float newHeight = image.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    newSize = CGSizeMake(newWidth, newHeight);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    return newImage;
 
    }
-(UIImage *)generatePhotoThumbnail:(UIImage *)image {
    // Create a thumbnail version of the image for the event object.
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio = 64.0;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, 110, 76);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    // Done Resizing
    NSLog(@"Resized Image = %lu",(unsigned long)[UIImageJPEGRepresentation(thumbnail, 1) length] );
    UIImageWriteToSavedPhotosAlbum(thumbnail, nil, nil, nil);
    return thumbnail;
}


- (UIImage *)resizeImage:(UIImage *)captureImage ToSize:(CGSize)targetSize
{
    UIImage *sourceImage = captureImage;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // make image center aligned
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor > heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    return newImage ;
    
//    float width = targetSize.width;
//    float height = targetSize.height;
//    
//    UIGraphicsBeginImageContext(targetSize);
//    CGRect rect = CGRectMake(0, 0, width, height);
//    
//    float widthRatio = captureImage.size.width / width;
//    float heightRatio = captureImage.size.height / height;
//    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
//    
//    width = captureImage.size.width / divisor;
//    height = captureImage.size.height / divisor;
//    
//    rect.size.width  = width;
//    rect.size.height = height;
//    
//    //indent in case of width or height difference
//    float offset = (width - height) / 2;
//    if (offset > 0) {
//        rect.origin.y = offset;
//    }
//    else {
//        rect.origin.x = -offset;
//    }
//    
//    [captureImage drawInRect: rect];
//    
//    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return smallImage;

}


#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    if (self.completionHandler) {
        croppedImage = [self imageWithImage:croppedImage scaledToSize:CGSizeMake(300, 300)];
        self.completionHandler(croppedImage);
    }
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

@end
