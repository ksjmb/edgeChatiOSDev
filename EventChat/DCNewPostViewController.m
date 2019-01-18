//
//  DCNewPostViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/31/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCNewPostViewController.h"
#import "AppDelegate.h"
#import "ECAPI.h"
#import "ECUser.h"
#import "DCPost.h"
#import "IonIcons.h"
#import "ECCommonClass.h"
//
#import "ECSharedmedia.h"
#import "S3UploadImage.h"
#import "SVProgressHUD.h"
#import "S3UploadVideo.h"
#import "S3Constants.h"
#import "ECFullScreenImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECVideoData.h"
#import "Reachability.h"
#import "ECAPINames.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "VideoBrowserViewController.h"
//
#import "ECConstants.h"
#import "ECAPINames.h"
#import "ECVideoConstants.h"
#import "ECSharedmedia.h"
#import "ECNewUserProfileViewController.h"
#import "VideoTrimmerViewController.h"

@interface DCNewPostViewController ()
{
    Reachability *reachabilityInfo;
    ECVideoData *videoData;
    ECVideoData *sharedData;
    NSString *newVideoUrl;
}
@end

@implementation DCNewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    // SLKTVC's configuration
    videoData = [ECVideoData sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadVideo) name:@"uploadVideo" object:nil];
    [self addPlaceHolderText];
}

- (void)addPlaceHolderText{
    _postTextView.text = NSLocalizedString(@"What's on your mind?", @"placeholder");
    _postTextView.textColor = [UIColor lightGrayColor];
    self.showPlaceHolder = YES; //we save the state so it won't disappear in case you want to re-edit it
}

- (void)textViewDidBeginEditing:(UITextView *)txtView
{
    if (self.showPlaceHolder == YES)
    {
        _postTextView.textColor = [UIColor blackColor];
        _postTextView.text = @"";
        self.showPlaceHolder = NO;
    }
}

- (IBAction)didTapCancel:(id)sender{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)actionOnCameraButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image",@"Video",nil];
    [actionSheet showInView:self.view];
}

#pragma mark:- UIActionSheet Alert Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
            if (flag) {
                NSLog(@"upload image...");
                [self uploadImage];
            }
        }];
        
    }else if(buttonIndex == 1){
        UIImagePickerController *img = [[UIImagePickerController alloc] init];
        img.delegate = self;
        img.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        img.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        [self presentViewController:img animated:true completion:nil];
        
        /*
        [[ECCommonClass sharedManager] showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Video" andResult:^(bool flag) {
            if (flag) {
                NSLog(@"upload video...");
                [self uploadVideo];
            }
        }];
         */
    }
}

#pragma mark:- ImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIStoryboard *videoProcessor = [UIStoryboard storyboardWithName:@"VideoProcessor" bundle:nil];
    VideoTrimmerViewController *vc = [videoProcessor instantiateViewControllerWithIdentifier:@"VideoTrimmerViewController"];
    // This is the NSURL of the video object
    NSURL *videoURLNew = [info objectForKey:UIImagePickerControllerMediaURL];
//    self.selectedVideoURL = videoURLNew;
    vc.movieURL = videoURLNew;
    vc.movieName = @"video_file";
    vc.isPhoneLibraryVideo = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
 
//Show Alert based on media type
-(void)showFailureAlert:(NSString *)mediaType{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Evnet Chat"
                                          message:[NSString stringWithFormat:@"%@ uploading Failed! \n Do you want to Retry?",mediaType]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Retry", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                                   // Re uploading if condition fails
                                   if ([mediaType isEqualToString:@"Image"]) {
                                       [self uploadImage];
                                   }
                                   else{
                                       [self uploadVideo];
                                   }
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark:- Handling background Image upload

- (void) beginBackgroundUpdateTask {
    self.backgroundUpdateTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTaskId];
    self.backgroundUpdateTaskId = UIBackgroundTaskInvalid;
}

#pragma mark:- Upload Image or Video

// Uploading Image On S3
-(void)uploadImage{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Uploading Image"];
    
    NSData * thumbImageData = UIImagePNGRepresentation([[ECSharedmedia sharedManager] mediaThumbImage]);
    [self beginBackgroundUpdateTask];
    
    [[S3UploadImage sharedManager] uploadImageForData:thumbImageData forFileName:[[ECSharedmedia sharedManager]mediaImageThumbURL] FromController:self andResult:^(bool flag) {
        
        if (flag) {
            NSData * imgData = [[ECSharedmedia sharedManager] imageData];
            [[S3UploadImage sharedManager]uploadImageForData:imgData forFileName:[[ECSharedmedia sharedManager] mediaImageURL] FromController:self andResult:^(bool flag) {
                
                if (flag) {
                    [self endBackgroundUpdateTask];
                    [SVProgressHUD dismiss];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    
                    NSString *imageURL = [NSString stringWithFormat:@"%@Images/%@",awsURL,[[ECSharedmedia sharedManager]mediaImageURL]];
                    NSString *thumbImageURL = [NSString stringWithFormat:@"%@Images/%@",awsURL,[[ECSharedmedia sharedManager]mediaImageThumbURL]];
                    NSLog(@"imageURL: %@", imageURL);
                    NSLog(@"thumbImageURL: %@", thumbImageURL);
                    self.mImageURL = imageURL;
                    self.mPostType = @"image";
                    if(imageURL != nil){
                        [self showImageOnTheCell:self ForImageUrl:imageURL];
                    }
                    [self.mPostImageView setHidden:false];
                    [self.playButton setHidden:true];
                    
                } else{
                    // Fail Condition ask for retry and cancel through alertView
                    [self showFailureAlert:@"Image"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];
                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
            [self showFailureAlert:@"Image"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];
        }
    }];
}

// Uploading Video On S3
- (void) uploadVideo{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Uploading Video"];
    
    NSData *thumbImageData = UIImagePNGRepresentation(videoData.mediaThumbImage);
    [self beginBackgroundUpdateTask];
    
    [[S3UploadVideo sharedManager] uploadImageForData:thumbImageData forFileName:videoData.mediaThumbImageURL FromController:self andResult:^(bool flag) {
        if (flag) {
            NSError* error = nil;
            NSData *videoDatas = [NSData dataWithContentsOfURL:videoData.videoURL options:NSDataReadingUncached error:&error];
            [[S3UploadVideo sharedManager] uploadVideoForData:videoDatas forFileName:[[ECVideoData sharedInstance] mediaURL] FromController:self andResult:^(bool flag) {
                
                if (flag) {
                    [self endBackgroundUpdateTask];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    
                    NSString *imageURL2 = [NSString stringWithFormat:@"%@Videos/%@",awsURL,videoData.mediaURL];
                    NSString *thumbImageURL = [NSString stringWithFormat:@"%@Videos/%@",awsURL,videoData.mediaThumbImageURL];
                    NSInteger videoBytes = (long)[videoDatas bytes];
                    NSLog(@"imageURL2: %@", imageURL2);
                    NSLog(@"thumbImageURL: %@", thumbImageURL);
                    NSLog(@"videoBytes: %ld", (long)videoBytes);
                    if(thumbImageURL != nil){
                        [self showImageOnTheCell:self ForImageUrl:thumbImageURL];
                    }
                    newVideoUrl = imageURL2;
                    self.mImageURL = thumbImageURL;
                    self.mPostType = @"video";
                    [self.mPostImageView setHidden:false];
                    [self.playButton setHidden:false];
                    self.playButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
                    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                    for (UIViewController *aViewController in allViewControllers) {
                        if ([aViewController isKindOfClass:[DCNewPostViewController class]]) {
                            [self.navigationController popToViewController:aViewController animated:YES];
                        }
                    }
                } else{
                    // Fail Condition ask for retry and cancel through alertView
                    [self showFailureAlert:@"Video"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];
                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
            [self showFailureAlert:@"Video"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];
        }
    }];
}

-(IBAction)didTapPost:(id)sender{
    if ([self.mPostType  isEqual: @"image"]){
        [self callToPostMsgAPIWithType:@"image" imageURLStr:self.mImageURL videoURLStr:@""];
    }else if ([self.mPostType  isEqual: @"video"]){
        [self callToPostMsgAPIWithType:@"video" imageURLStr:self.mImageURL videoURLStr:newVideoUrl];
    }else{
        [self callToPostMsgAPIWithType:@"text" imageURLStr:@"" videoURLStr:@""];
    }
}

#pragma mark:- API Call

-(void)callToPostMsgAPIWithType:(NSString *)postType imageURLStr:(NSString *)imageURL videoURLStr:(NSString *)videoURL{
    self.signedInUser.whatsOnYourMind = _postTextView.text;
    DCPost *post = [[DCPost alloc] init];
    post.userId = self.signedInUser.userId;
    post.displayName = self.signedInUser.firstName;
    post.parentId = @"0";
    self.isValid = true;
    
    if ([postType  isEqual: @"image"]){
        post.postType = @"image";
        post.imageUrl = imageURL;
        if ([self.postTextView.text  isEqual: @"What's on your mind?"]){
            post.content = @"";
        }else{
            post.content = self.postTextView.text;
        }
    }else if ([postType  isEqual: @"video"]){
        post.postType = @"video";
        post.imageUrl = imageURL;
        post.videoUrl = videoURL;
        if ([self.postTextView.text  isEqual: @"What's on your mind?"]){
            post.content = @"";
        }else{
            post.content = self.postTextView.text;
        }
    }else{
        post.postType = @"text";
        if ([self.postTextView.text  isEqual: @"What's on your mind?"]){
            [[ECCommonClass sharedManager] alertViewTitle:@"Alert" message:@"Please enter the post message"];
            self.isValid = false;
        }else{
            post.content = self.postTextView.text;
        }
    }
    
    if (self.isValid){
        [[ECAPI sharedManager] addPost:post callback:^(NSDictionary *jsonDictionary, NSError *error) {
            if (error) {
                NSLog(@"Error adding post: %@", error);
            } else {
                [self.navigationController popViewControllerAnimated:true];
                if([self.delegate respondsToSelector:@selector(refreshPostStream)]){
                    [self.delegate refreshPostStream];
                }
            }
        }];
    }
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(DCNewPostViewController *)vc ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        self.mPostImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.mPostImageView.image = image;
        
    }else{
        NSURL *urL = [NSURL URLWithString:url];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager.imageDownloader setDownloadTimeout:20];
        [manager downloadImageWithURL:urL
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    self.mPostImageView.image = image;
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again")
                                        ;
                                        return;
                                    }
                                }
                            }];
    }
}

@end
