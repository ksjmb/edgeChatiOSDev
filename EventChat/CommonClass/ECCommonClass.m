//
//  ECCommonClass.m
//  EventChat
//
//  Created by Mindbowser on 4/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECCommonClass.h"
#import <Photos/Photos.h>
#import "S3Constants.h"
#import "ECSharedmedia.h"
#import "S3UploadServices.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MediaBrowser.h"
#import "ECNavigationController.h"
#import "ECConstants.h"
#import "ECVideoData.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MBProgressHUD.h>
#import "GPUImage.h"
#import "S3UploadVideo.h"
#import "VideoBrowserViewController.h"
#import "AppDelegate.h"
#import "ECVideoConstants.h"
#import "VideoTrimmerViewController.h"
#import "IonIcons.h"
#import "SignUpLoginViewController.h"

@implementation ECCommonClass{

    ResultBlock _resultBlock;
    NSString *uniqId;
    NSString *imageUrl;
    NSURL *trimmedURL;
    
    NSData  * actualImageData;
    NSData  * largeImageData;
    NSData  * mediumImageData;
    NSData  * smallImageData;
    
    ECVideoData *videoData;
    NSUInteger selectedFilterTag;
    
    MBProgressHUD *hud;
}

#pragma mark - Singleton methods

+(id)sharedManager
{
    static ECCommonClass *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/*
- (void)pushToSignInVC{
    UITabBarController *navController = (UITabBarController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpLoginViewController = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    [navController presentViewController:signUpLoginViewController animated:true completion:nil];
}
*/
 
- (void)showActionSheetToSelectMediaFromGalleryOrCamFromController:(UIViewController *)controller andMediaType : (NSString*)type andResult:(void (^)(bool))block {
    
    _resultBlock = [block copy];
    if ([type isEqualToString:@"Image"]) {
        UIActionSheet *imageOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Gallery",nil];
        imageOptions.tag = 1;
        [imageOptions showInView:controller.view];
    }else if([type isEqualToString:@"Video"]){
        UIActionSheet *videoOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Gallery",nil];
        videoOptions.tag = 2;
        self.controller = controller;
        [videoOptions showInView:controller.view];
    }
   
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    if (buttonIndex == 0 && actionSheet.tag == 1) {
        
                // Method for asking permission for use of Camera
        
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if(authStatus == AVAuthorizationStatusAuthorized) {
                    // Allow Access
                    [self openCamera];
        
                } else if(authStatus == AVAuthorizationStatusDenied){
        
                    // denied
                    [self showAlertForAccessCameraAndGoToSettings];
        
                } else if(authStatus == AVAuthorizationStatusRestricted){
        
                    // restricted, normally won't happen
                    [self showAlertForAccessCameraAndGoToSettings];
        
                } else if(authStatus == AVAuthorizationStatusNotDetermined){
        
                    // not determined?!
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if(granted){
        
                            // Allow Access
                            [self openCamera];
                            
                        } else {
                            [self showAlertForAccessCameraAndGoToSettings];
                        }
                    }];
                }
        
    }else if(buttonIndex == 1 && actionSheet.tag == 1){
                // Method for asking permission for use fo Photo Library
        
                PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
                if (status == PHAuthorizationStatusDenied) {
                    // Access has been denied.
                    [self showAlertForAccessCameraAndGoToSettings];
                }
                else if ( status == PHAuthorizationStatusAuthorized) {
                    [self  openGallery];
                    // [self askForPermissionAndAllowToTakeImageOrVideo];
                }
                else if (status == PHAuthorizationStatusNotDetermined) {
        
                    // Access has not been determined.
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
                        if (status == PHAuthorizationStatusAuthorized) {
                            // Access has been granted.
                            [self openGallery];
                        }
                        else {
                            // Access has been denied.
                            [self showAlertForAccessCameraAndGoToSettings];
                        }
                    }];
                }

    }else if(buttonIndex == 0 && actionSheet.tag == 2){
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            
            [self takePermissionForGalleryWhileClickedOnCameraButton];
            
            // Allow Access
            //[self askForPermissionAndAllowToTakeImageOrVideo];
        } else if(authStatus == AVAuthorizationStatusDenied){
            
            // denied
            [self showAlertForAccessCameraAndGoToSettings];
            
        } else if(authStatus == AVAuthorizationStatusRestricted){
            // restricted, normally won't happen
            [self showAlertForAccessCameraAndGoToSettings];
            
        } else if(authStatus == AVAuthorizationStatusNotDetermined){
            // not determined?!
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    // Allow Access
                    NSLog(@"Granted access to %@", @"CAMERA");
                    [self takePermissionForGalleryWhileClickedOnCameraButton];
                    
                    
                } else {
                    [self showAlertForAccessCameraAndGoToSettings];
                    
                    NSLog(@"Not granted access to %@", @"CAMERA");
                }
            }];
        }

    }
    else if (buttonIndex == 1 && actionSheet.tag == 2){
        //get videos from gallary
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                
                [self showInstagramTypePickerForPhotoGalleryClicked];
            }
            
            else if (status == PHAuthorizationStatusDenied) {
                // Access has been denied.
                //[self showAlertForAccessDeniedAndGoingToSettings];
            }
            
            else if (status == PHAuthorizationStatusNotDetermined) {
                
                // Access has not been determined.
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                    if (status == PHAuthorizationStatusAuthorized) {
                        // Access has been granted.
                        [self showInstagramTypePickerForPhotoGalleryClicked];
                    }
                    
                    else {
                        // Access has been denied.
                        //[self showAlertForAccessDeniedAndGoingToSettings];
                    }
                }];
            }
            
            else if (status == PHAuthorizationStatusRestricted) {
                // Restricted access - normally won't happen.
                //[self showAlertForAccessDeniedAndGoingToSettings];
            }
            
        }else {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            if (status == ALAuthorizationStatusAuthorized) {
                // Access has been granted.
                [self showInstagramTypePickerForPhotoGalleryClicked];
                
            }
            else if (status == ALAuthorizationStatusNotDetermined) {
                ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
                [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    [self showInstagramTypePickerForPhotoGalleryClicked];
                    
                    NSLog(@"%zd", [group numberOfAssets]);
                    
                } failureBlock:^(NSError *error) {
                   // [self showAlertForAccessDeniedAndGoingToSettings];
                }];
            }
            else if (status == ALAuthorizationStatusDenied) {
                //[self showAlertForAccessDeniedAndGoingToSettings];
                
            }
            else if (status == ALAuthorizationStatusRestricted) {
                //[self showAlertForAccessDeniedAndGoingToSettings];
                
            }
            
        }
        
    }
}


-(void)showInstagramTypePickerForPhotoGalleryClicked {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *videoProcessingStoryboard = [UIStoryboard storyboardWithName:@"VideoProcessor" bundle:[NSBundle mainBundle]];
        VideoBrowserViewController *videoBrowserVC = [videoProcessingStoryboard instantiateViewControllerWithIdentifier:@"videoBrowser"];
        [self.controller.navigationController pushViewController:videoBrowserVC animated:YES];
    });
    }

//-(void) showAlertForAccessDeniedAndGoingToSettings {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//        UIAlertView * galleryAccess = [[UIAlertView alloc]initWithTitle:@"Access Required!" message:@"Please enable access to your Gallery.\nYou can enable access in Privacy Settings." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Settings",@"Not Now", nil];
//        galleryAccess.tag = 10;
//        [galleryAccess show];
//    } else {
//        [[GlobalConstants sharedInstance] alertViewTitle:@"Access Required!" message:@"Please enable access to your Gallery.\nYou can enable access in Privacy Settings."];
//    }
//}



-(void)takePermissionForGalleryWhileClickedOnCameraButton {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusDenied) {
            // Access has been denied.
            [self showAlertForAccessCameraAndGoToSettings];
        }
        else if ( status == PHAuthorizationStatusAuthorized) {
            [self  askPermissionForMicrophone];
            // [self askForPermissionAndAllowToTakeImageOrVideo];
        }
        else if (status == PHAuthorizationStatusNotDetermined) {
            
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    // [self askForPermissionAndAllowToTakeImageOrVideo];
                    [self askPermissionForMicrophone];
                }
                else {
                    // Access has been denied.
                    [self showAlertForAccessCameraAndGoToSettings];
                }
            }];
        }
        
    }
    
}

-(void)askPermissionForMicrophone {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        
        
        // Allow Access
        [self askForPermissionAndAllowToTakeImageOrVideo];
    } else if(authStatus == AVAuthorizationStatusDenied){
        
        // denied
        [self showAlertForAccessCameraAndGoToSettings];
        
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
        [self showAlertForAccessCameraAndGoToSettings];
        
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(granted){
                // Allow Access
                NSLog(@"Granted access to %@", @"CAMERA");
                [self askForPermissionAndAllowToTakeImageOrVideo];
                
                
            } else {
                [self showAlertForAccessCameraAndGoToSettings];
                
                NSLog(@"Not granted access to %@", @"CAMERA");
            }
        }];
    }
    
}

-(void)askForPermissionAndAllowToTakeImageOrVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
        NSDictionary *mediaOutputSettings = @{kMediaBrowserSourceType:@(UIImagePickerControllerSourceTypeCamera),
                                              kMediaBrowserMediaType:ECvideo,
                                              kMediaBrowserIsForProfilePic:@(NO),
                                              kMediaBrowserShouldCropImage:@(NO)};
        
        [[MediaBrowser sharedInstance] startMediaBrowserFromViewController:self.controller mediaOutputSettings:mediaOutputSettings completionHandler:^(id selectedMedia) {
            dispatch_async(dispatch_get_main_queue(), ^{
            
                NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];

                NSString *pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:[tmpDirectory objectAtIndex:0]];
                
                //Write to Documents directory
                NSData *videosData = [NSData dataWithContentsOfFile:pathToMovie];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                [videosData writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Movie.mp4"] atomically:YES];
                
                //Assigning path of video URL
                NSURL *movieURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"Movie.mp4"]];
                
                //Clear document directory
                for (NSString *file in tmpDirectory) {
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
                }
                
                //Assigning values to singleton class
                [self uploadVideoAtURL:movieURL];
                
                //Sending control to TopicCommentViewController for uploading video.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadVideoToS3" object:nil];
                
            });
        }];
    });
}

- (void)uploadVideoAtURL:(NSURL *)videoURL {
    
    uniqId = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    videoData = [ECVideoData sharedInstance];
    
    videoData.mediaURL            = kS3VideoURLPath(uniqId, uniqId);
    videoData.mediaThumbImageURL  = kS3VideoTImageURLPath(uniqId, uniqId);
    videoData.mediaDataFilePath   = videoURL;
    videoData.mediaUniqueId       = uniqId;
    videoData.videoURL            = videoURL;
    
    UIImage *thumbnailImage = [[ECVideoConstants sharedInstance] thumbnailImageFromVideoAtURL:videoURL];
    thumbnailImage = [[ECVideoConstants sharedInstance] compressImage:thumbnailImage];
    
    videoData.mediaThumbImage = thumbnailImage;

}

-(void)openGallery{
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window makeKeyAndVisible];
        [appDelegate.window.rootViewController presentViewController:self.imagePickerController animated:YES completion:NULL];
//        [self.controller presentViewController:self.imagePickerController animated:YES completion:NULL];
    });
    
}

-(void)openCamera{
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    //     [[UIApplication sharedApplication] setStatusBarHidden:YES];
   // });
   BOOL isCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCamera) {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window makeKeyAndVisible];
        [appDelegate.window.rootViewController presentViewController:self.imagePickerController animated:YES completion:NULL];

//    [self.controller presentViewController:self.imagePickerController animated:YES completion:NULL];
    }
    else{
        [self alertViewTitle:@"Error" message:@"Camara is not available on your device"];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:chosenImage cropMode:RSKImageCropModeSquare];
    imageCropVC.delegate = self;
    [picker pushViewController:imageCropVC animated:YES];
    
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];

    _resultBlock(false);

}


-(void) showAlertForAccessCameraAndGoToSettings {
   
    UIAlertView * galleryAccess = [[UIAlertView alloc]initWithTitle:@"Access Required!" message:@"Please enable access to Camera and Gallery.\nYou can enable access in Privacy Settings." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Settings",@"Not Now", nil];
    galleryAccess.tag = 10;
    [galleryAccess show];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 10) {
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
   }
    
}
// Common alert function
- (void)alertViewTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (UIImage *)resizeImage:(UIImage *)captureImage toSize:(CGSize)targetSize{
   
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
    
}
#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    _resultBlock(false);
}

// Method to get Human readable values for size of Image.
- (id)transformedValue:(id)value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB"];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, tokens[multiplyFactor]];
}
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        
        // Create actual value
        NSData * dataOfImage = UIImageJPEGRepresentation (croppedImage,1.0);
        actualImageData = dataOfImage;
        float sizeOfImage = dataOfImage.length;
        
        NSString * actualTitle = [self transformedValue:[NSNumber numberWithFloat:sizeOfImage]];
        
        
        //create the large value
        
        NSData * largeDataOfImage = UIImageJPEGRepresentation (croppedImage,0.75);
        largeImageData = largeDataOfImage;
        
        float largeImageSize  = largeDataOfImage.length;
        NSString * largeTitle = [self transformedValue:[NSNumber numberWithFloat:largeImageSize]];
        
        //create the medium value
        
        NSData * mediumDataOfImage = UIImageJPEGRepresentation (croppedImage,0.5);
        mediumImageData = mediumDataOfImage;
        float mediumImageSize = mediumDataOfImage.length;
        NSString * mediumTitle = [self transformedValue:[NSNumber numberWithFloat:mediumImageSize]];
        
        
        //create the small value
        
        NSData * smallDataOfImage = UIImageJPEGRepresentation (croppedImage,0.25);
        smallImageData = smallDataOfImage;
        
        float smallImageSize = smallDataOfImage.length;
        NSString * smallTitle = [self transformedValue:[NSNumber numberWithFloat:smallImageSize]];
        
        
        NSString * alertTitle = [NSString stringWithFormat:@"This message is %@. You can reduce message size by scalling the image to one of the size below.",actualTitle];
        
        actualTitle     = [NSString stringWithFormat:@"Actual Size (%@)",actualTitle];
        largeTitle      = [NSString stringWithFormat:@"Large (%@)",largeTitle];
        mediumTitle     = [NSString stringWithFormat:@"Medium (%@)",mediumTitle];
        smallTitle      = [NSString stringWithFormat:@"Small (%@)",smallTitle];
        
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [self.controller dismissViewControllerAnimated:YES completion:^{
            }];
            _resultBlock(false);
            
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:smallTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // Small button tapped.
            [self commonMethodToSaveDataSizeOfImage:smallImageSize withOriginalImage:croppedImage withImageData:smallImageData];
            [self.controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:mediumTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // Medium button tapped.
            [self commonMethodToSaveDataSizeOfImage:mediumImageSize withOriginalImage:croppedImage withImageData:mediumImageData];
            [self.controller dismissViewControllerAnimated:YES completion:nil];            }]];
        
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:largeTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // Large button tapped.
            [self commonMethodToSaveDataSizeOfImage:largeImageSize withOriginalImage:croppedImage withImageData:largeImageData];
            [self.controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:actualTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // Actual button tapped.
            [self commonMethodToSaveDataSizeOfImage:sizeOfImage withOriginalImage:croppedImage withImageData:actualImageData];
            [self.controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        
        // Present action sheet.
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window makeKeyAndVisible];
        [appDelegate.window.rootViewController presentViewController:actionSheet animated:YES completion:NULL];

//        [self.controller presentViewController:actionSheet animated:YES completion:nil];
        
    }];
}
-(void)commonMethodToSaveDataSizeOfImage:(float)imageSize withOriginalImage:(UIImage *)croppedImage withImageData:(NSData *)data{
    
    // Assigning values for S3 to upload image.
    UIImage * thumbImage = [self resizeImage:croppedImage toSize:CGSizeMake(100, 100)];
    uniqId = TIME_IN_SECS;
    imageUrl = kS3PhotoURLPath(uniqId,uniqId);
    NSString *imageThumbURL = kS3PhotoThumbnailURLPath(uniqId,uniqId);
    
    
            [[ECSharedmedia sharedManager] setMediaImageURL:imageUrl];
            [[ECSharedmedia sharedManager] setMediaImageThumbURL:imageThumbURL];
            [[ECSharedmedia sharedManager] setMediaThumbImage:thumbImage];
            [[ECSharedmedia sharedManager] setImageSizeInBytes:imageSize ];
            [[ECSharedmedia sharedManager] setImageData:data];
    
    
    
    _resultBlock(true);
}


-(void)commonMethodToSaveDataSizeOfVideo:(float)videoSize withImageData:(NSData *)data{
    
    // Assigning values for S3 to upload video.
//    UIImage * thumbImage = [self resizeImage:croppedImage toSize:CGSizeMake(100, 100)];
    uniqId = TIME_IN_SECS;
    imageUrl = kS3PhotoURLPath(uniqId,uniqId);
    //NSString *imageThumbURL = kS3PhotoThumbnailURLPath(uniqId);
    
    
    //[[ECVideoData sharedInstance] setmediaURL:imageUrl];
    //[[ECVideoData sharedInstance] setMediaImageThumbURL:imageThumbURL];
    //[[ECVideoData sharedInstance] setMediaThumbImage:thumbImage];
    //[[ECVideoData sharedInstance] setImageSizeInBytes:imageSize ];
    [[ECVideoData sharedInstance] setImageData:data];
    
    _resultBlock(true);
   
}

// Checking net avavilability.
-(BOOL)isInternetAvailabel {
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        
    } else
        return YES;
    
    return NO;
}

- (CALayer *)addImageToButton:(UIButton *)button imageType:(ImageType)imageType aColor:(UIColor *)aColor aSize:(float)aSize{
    UIImage *image;
    
    switch (imageType) {
        case Facebook:
            image = [IonIcons imageWithIcon:ion_social_facebook size:aSize color:aColor];;
            break;
        case Google:
            image = [IonIcons imageWithIcon:ion_social_google size:aSize color:aColor];
            break;
        case TWX:
            image = [IonIcons imageWithIcon:ion_social_twitter size:aSize color:aColor];
            break;
        case Instagram:
            image = [IonIcons imageWithIcon:ion_social_instagram size:aSize color:aColor];
            break;
        case Follow:
            image = [IonIcons imageWithIcon:ion_person_add size:aSize color:aColor];
            break;
        case Post:
            image = [IonIcons imageWithIcon:ion_compose size:aSize color:aColor];
            break;
        case DirectMessage:
            image = [IonIcons imageWithIcon:ion_chatboxes size:aSize color:aColor];
            break;
        case CheckMark:
            image = [IonIcons imageWithIcon:ion_android_checkbox_outline size:aSize color:aColor];
            break;
        case ThumbsUp:
            image = [IonIcons imageWithIcon:ion_thumbsup size:aSize color:aColor];
            break;
        case ThumbsDown:
            image = [IonIcons imageWithIcon:ion_thumbsdown size:aSize color:aColor];
            break;
        case Favorite:
            image = [IonIcons imageWithIcon:ion_heart size:aSize color:aColor];
            break;
        default:
            break;
    }
    CGSize imageSize = image.size;
    CGFloat offsetY = floor((button.layer.bounds.size.height - imageSize.height) / 2.0);
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (__bridge id) image.CGImage;
    imageLayer.contentsGravity = kCAGravityBottom;
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    imageLayer.frame = CGRectMake(offsetY, offsetY, imageSize.width, imageSize.height);
    return imageLayer;
}
@end
