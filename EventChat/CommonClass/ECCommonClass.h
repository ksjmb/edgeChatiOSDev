//
//  ECCommonClass.h
//  EventChat
//
//  Created by Mindbowser on 4/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSKImageCropViewController.h"
#import "Reachability.h"
#import "ConnectionManager.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import<AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>

#define EntityType_DIGITAL      @"digital"
#define EntityType_PERSON      @"person"
#define EntityType_EVENT      @"event"

typedef enum {
    Facebook,
    Google,
    TWX,
    EMail,
    Instagram,
    Follow,
    Post,
    DirectMessage,
    CheckMark,
    ThumbsUp,
    ThumbsDown,
    Favorite
} ImageType;


typedef void (^ResultBlock)( BOOL);

@interface ECCommonClass : NSObject<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RSKImageCropViewControllerDelegate>

+(id)sharedManager;
-(BOOL)isInternetAvailabel;
@property (nonatomic,strong) UIViewController * controller;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) NSDictionary *uploadVideoInfo;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (nonatomic) BOOL isFromChatVC;
@property (nonatomic,strong) NSMutableArray *parentCommentIDs;
@property (nonatomic,strong) NSMutableArray *parentCommentIDArray;
@property (nonatomic,strong) NSMutableArray *indexPathRowArray;
@property (nonatomic) BOOL isUserLogoutTap;
@property (nonatomic) BOOL isAouthToken;

@property (nonatomic) BOOL isFromMore;

-(void)showActionSheetToSelectMediaFromGalleryOrCamFromController:(UIViewController *)controller andMediaType : (NSString*)type andResult:(void (^)(bool))block;
/*
-(void)pushToSignInVC;
*/
-(UIImage *)resizeImage:(UIImage *)captureImage toSize:(CGSize)targetSize;
- (void)alertViewTitle:(NSString *)title message:(NSString *)message;
- (CALayer *)addImageToButton:(UIButton *)button imageType:(ImageType)imageType aColor:(UIColor *)aColor aSize:(float)aSize;
@end
