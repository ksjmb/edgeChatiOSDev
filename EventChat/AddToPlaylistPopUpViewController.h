//
//  AddToPlaylistPopUpViewController.h
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"
#import "ECEventBriteEvent.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"

@protocol AddToPlaylistDelegate <NSObject>
- (void)updateUI;
@end

@interface AddToPlaylistPopUpViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *collectionPlaylistView;
@property (weak, nonatomic) IBOutlet UICollectionView *playlistCollectionView;
@property (nonatomic, weak) id <AddToPlaylistDelegate> playlistDelegate;
//
@property (weak, nonatomic) IBOutlet UIView *vwNew;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UITextField *playlistTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTaskId;
//
@property (nonatomic) BOOL isFeedMode;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, copy) NSString *mFeedItemId;
@property (assign) BOOL isImageSelected;
@property (nonatomic, copy) NSString *selectedImageURL;

@end
