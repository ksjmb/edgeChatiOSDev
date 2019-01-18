//
//  DCNewPostViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/31/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@class ECUser;

@protocol DCNewPostViewControllerDelegate <NSObject>
- (void)refreshPostStream;
@end

@interface DCNewPostViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) IBOutlet UITextView *postTextView;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, weak) id <DCNewPostViewControllerDelegate> delegate;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTaskId;
//@property (strong, nonatomic) NSURL *selectedVideoURL;
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, assign) NSString *mPostType;
@property (nonatomic, assign) NSString *mImageURL;
//
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIImageView *mPostImageView;
@property (weak, nonatomic) IBOutlet YTPlayerView *mPostPlayerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;


@end
