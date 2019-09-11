//
//  AddToPlaylistPopUpViewController.m
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "AddToPlaylistPopUpViewController.h"
#import "AddToPlaylistPopUpCollectionViewCell.h"
#import "ECAPI.h"
#import "AppDelegate.h"
#import "DCPlaylist.h"
#import "DCFeedItem.h"
#import "NSMutableAttributedString+Color.h"
#import "ECCommonClass.h"
#import "ECSharedmedia.h"
#import <SDWebImage/UIImageView+WebCache.h>
//
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

@interface AddToPlaylistPopUpViewController ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *mPlaylistsArray;

@end

@implementation AddToPlaylistPopUpViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.isComeFromProfileVC){
        self.signedInUser = [[ECAPI sharedManager] signedInUser];
    }
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8f];
    
    if (self.isImageSelected){
        [self.collectionPlaylistView setHidden: YES];
        [self.vwNew setHidden: NO];
        [self initialSetup];
    }else{
        [self.vwNew setHidden: YES];
        [self.collectionPlaylistView setHidden: NO];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [[ECAPI sharedManager] getPlaylistsByUserId:self.signedInUser.userId callback:^(NSArray *playlists, NSError *error) {
        self.mPlaylistsArray = [[NSMutableArray alloc] initWithArray:playlists];
        [self.playlistCollectionView reloadData];
    }];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 0){
        [self.cancelButton setTitle:@"Save" forState:UIControlStateNormal];
    }else{
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
//    return (newLength > 1) ? NO : YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBAction Methods

- (IBAction)actionOnPlusButton:(id)sender {
    
    [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
        if (flag) {
            [self getImageFromGallery];
        }
    }];
    /*
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *pickerView =[[UIImagePickerController alloc]init];
        pickerView.allowsEditing = YES;
        pickerView.delegate = self;
        pickerView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerView animated:YES completion:nil];
    }
     */
}

- (IBAction)actionOnButtonClick:(id)sender {
    [self removeAnimation];
}

- (IBAction)actionOnVwCancelButton:(id)sender {
    if ([self.cancelButton.titleLabel.text  isEqual: @"Save"]){
        DCPlaylist *newPlaylist = [DCPlaylist alloc];
        newPlaylist.playlistName = self.playlistTextField.text;
        newPlaylist.coverImageUrl = self.selectedImageURL;
        newPlaylist.thumbnailImageUrl = @"";
        newPlaylist.playlistDescription = @"";
        
        if([self.playlistTextField.text length] > 0){
            [[ECAPI sharedManager] createPlaylist:self.signedInUser.userId playlistName:newPlaylist.playlistName playlistDescription:newPlaylist.playlistDescription coverImageUrl:newPlaylist.coverImageUrl thumbnailImageUrl:newPlaylist.coverImageUrl
                callback:^(NSArray *playlist, NSError *error) {
                if(error){
                    NSLog(@"Error while creating playlist: %@", error);
                }
                else{
                    [self.mPlaylistsArray insertObject:playlist atIndex:0];
                    [self.playlistCollectionView reloadData];
                }
            }];
            /*
            [[ECAPI sharedManager] createPlaylist:self.signedInUser.userId playlistName:newPlaylist.playlistName callback:^(DCPlaylist *playlist, NSError *error) {
                if(error){
                    NSLog(@"Error while creating playlist: %@", error);
                }
                else{
                    [self.mPlaylistsArray insertObject:playlist atIndex:0];
                    [self.playlistCollectionView reloadData];
                }
            }];
             */
        }
    }
    [self removeAnimation];
}

#pragma mark - CollectionView DataSource and Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mPlaylistsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddToPlaylistPopUpCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddToPlaylistPopUpCollectionViewCell" forIndexPath:indexPath];
    DCPlaylist *playlist = [self.mPlaylistsArray objectAtIndex:indexPath.row];
    [cell.playlistNameLabel setText:playlist.playlistName];
    if(playlist.coverImageUrl != nil){
        [self showImageOnTheCell:cell ForImageUrl:playlist.coverImageUrl];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DCPlaylist *playlistItem = [self.mPlaylistsArray objectAtIndex:indexPath.row];
    [[ECAPI sharedManager] addToPlaylist:playlistItem.playlistId feedItemId:self.mFeedItemId userId:self.signedInUser.userId callback:^(NSArray *playlists, NSError *error) {
        if(error){
            NSLog(@"Error while adding feedItem into playlist: %@", error);
        }
        else{
            self.mPlaylistsArray = [[NSMutableArray alloc] initWithArray:playlists];
            [[ECAPI sharedManager] updateProfilePicUrl:self.signedInUser.userId profilePicUrl:self.signedInUser.profilePicUrl callback:^(NSError *error) {
                if (error) {
                    NSLog(@"Error while updating profile picURL: %@", error);
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdated" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdatedNew" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateEventTV" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatReaction" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableView" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateInflurenceTableView" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfileTableView" object:nil];
                    [self removeAnimation];
                }
            }];
        };
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

#pragma mark - Instance Methods

-(void)removeAnimation{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFromTop;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.view removeFromSuperview];
    [self.view setAlpha:0.0];
    [self.playlistDelegate updateUI];
}

-(void)initialSetup{
    self.vwNew.layer.cornerRadius = 5.0;
    self.vwNew.layer.masksToBounds = YES;
    self.vwNew.layer.borderWidth = 5;
    self.vwNew.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(void)getImageFromGallery{
    [self.collectionPlaylistView setHidden: YES];
    [self.vwNew setHidden: NO];
    [self initialSetup];
    [self uploadImage];
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

#pragma mark - PickerDelegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.collectionPlaylistView setHidden: YES];
    [self.vwNew setHidden: NO];
    [self initialSetup];
    UIImage *img = [info valueForKey:UIImagePickerControllerEditedImage];
    self.coverImageView.image = img;
    if (@available(iOS 11.0, *)) {
        self.selectedImageURL = [info valueForKey:UIImagePickerControllerImageURL];
    } else {
        self.selectedImageURL = [info valueForKey:UIImagePickerControllerImageURL];
    }
    /*
    (lldb) po [info valueForKey:UIImagePickerControllerImageURL]
file:///Users/sanjaybalaji/Library/Developer/CoreSimulator/Devices/6E4BB862-6386-42D3-A78B-B838159197DA/data/Containers/Data/Application/72ADCA0C-AAFB-4468-B9B8-E2C3FDD99B32/tmp/87B438D1-B5F6-4B5D-9A1E-A24311A4A84A.jpeg
     
    NSURL* localUrl = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    NSLog(@"localUrl: %@", localUrl);
     */
}

#pragma mark:- Image upload

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
                    self.selectedImageURL = imageURL;
                    NSLog(@"thumbImageURL: %@", thumbImageURL);
                    NSURL *aURL = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
                    UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]];
                    self.coverImageView.image = mImage;
                    
                } else{
                    // Fail Condition ask for retry and cancel through alertView
//                    [self showFailureAlert:@"Image"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];
                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
//            [self showFailureAlert:@"Image"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];
        }
    }];
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(AddToPlaylistPopUpCollectionViewCell *)cell ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.playlistImageView.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.playlistImageView.image = image;
        
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
                                    cell.playlistImageView.image = image;
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

/*
 
 func showAnimate()
 {
 self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
 self.view.alpha = 0.0;
 UIView.animate(withDuration: 0.25, animations: {
 self.view.alpha = 1.0
 self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
 });
 }
 
 func removeAnimate()
 {
 UIView.animate(withDuration: 0.25, animations: {
 self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
 self.view.alpha = 0.0;
 }, completion:{(finished : Bool)  in
 if (finished)
 {
 self.view.removeFromSuperview()
 }
 });
 }
 
 */
 
@end
