//
//  AddToPlaylistPopUpViewController.h
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddToPlaylistDelegate <NSObject>
- (void)updateUI;
@end

@interface AddToPlaylistPopUpViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *collectionPlaylistView;
@property (weak, nonatomic) IBOutlet UICollectionView *playlistCollectionView;
@property (nonatomic, weak) id <AddToPlaylistDelegate> playlistDelegate;
//
@property (weak, nonatomic) IBOutlet UIView *vwNew;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UITextField *playlistTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


@property (assign) BOOL isImageSelected;

@end
