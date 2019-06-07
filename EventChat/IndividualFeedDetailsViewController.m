//
//  IndividualFeedDetailsViewController.m
//  EventChat
//
//  Created by Mindbowser on 04/06/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "IndividualFeedDetailsViewController.h"
#import "IonIcons.h"
#import "ECColor.h"
#import "ECUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SVProgressHUD.h"
#import "AddToPlaylistPopUpViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"

@interface IndividualFeedDetailsViewController ()

@property (nonatomic, strong) ECUser *loginUser;
@property (nonatomic, strong) FBSDKShareDialog *mShareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *mContent;
@property (nonatomic, assign) NSString *userEmail;

@end

@implementation IndividualFeedDetailsViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Season List";
    [self initialImageDescriptionSetup];
}

- (void)viewWillAppear:(BOOL)animated{
    self.loginUser = [[ECAPI sharedManager] signedInUser];
    
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.userEmail == nil){
        self.loginUser = nil;
    }
    
    if([self.loginUser.favoritedFeedItemIds containsObject:self.mFeedItem.feedItemId]){
        [self.mFavBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:27.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }else{
        UIImage *btnImage = [UIImage imageNamed:@"heart_new"];
        [self.mFavBtn setTintColor:[UIColor darkTextColor]];
        [self.mFavBtn setImage:[self imageWithImage:btnImage scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
    }
}

#pragma mark:- Instance Methods

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)initialImageDescriptionSetup{
    [self.mVideoPlayButton setHidden:true];
    [self.mShareBtn setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor darkTextColor]] forState:UIControlStateNormal];
    
    self.mBgImgView.layer.cornerRadius = 5.0;
    self.mBgImgView.layer.masksToBounds = YES;
    self.mBgImgView.layer.borderWidth = 5;
    self.mBgImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.title = self.mFeedItem.person.name;
    self.mEpsdDecsLabel.text = self.mFeedItem.person.blurb;
    if(self.mFeedItem.person.profilePic_url != nil){
        [self showImageOnHeader:self.mFeedItem.person.profilePic_url];
    }
}

#pragma mark:- IBActins Methods

- (IBAction)actionOnVideoPlayBtn:(id)sender {
    
}

- (IBAction)actionOnShareBtn:(id)sender {
    /*
    if (self.userEmail != nil){
        NSString* title = self.mFeedItem.digital.episodeTitle;
        NSString* link = self.mFeedItem.digital.imageUrl;
        NSArray* dataToShare = @[title, link];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Facebook", @"Facebook action")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action)
                                         {
                                             NSLog(@"Facebook action");
                                             NSLog(@"Share to Facebook");
                                             self.mShareDialog = [[FBSDKShareDialog alloc] init];
                                             self.mContent = [[FBSDKShareLinkContent alloc] init];
                                             self.mContent.contentURL = [NSURL URLWithString:self.mFeedItem.digital.imageUrl];
                                             self.mContent.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                             self.mContent.contentDescription = self.mFeedItem.digital.episodeDescription;
                                             
                                             if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
                                                 [self.mShareDialog setMode:FBSDKShareDialogModeNative];
                                             }
                                             else {
                                                 [self.mShareDialog setMode:FBSDKShareDialogModeAutomatic];
                                             }
                                             //[self.shareDialog setMode:FBSDKShareDialogModeShareSheet];
                                             [self.mShareDialog setShareContent:self.mContent];
                                             [self.mShareDialog setFromViewController:self];
                                             [self.mShareDialog setDelegate:self];
                                             [self.mShareDialog show];
                                             //[FBSDKShareDialog showFromViewController:self withContent:self.content delegate:self];
                                         }];
        
        UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Twitter", @"Twitter action")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                        {
                                            [self twitterSetup:[NSURL URLWithString:self.mFeedItem.digital.imageUrl] :self.mFeedItem.digital.episodeTitle];
                                         }];
        
        UIAlertAction *moreOptionsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"More Options...", @"More Options... action")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action)
                                            {
                                                NSLog(@"More Option... action");
                                                UIActivityViewController* activityViewController =
                                                [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                                  applicationActivities:nil];
                                                
                                                
                                                // This is key for iOS 8+
                                                
                                                [self presentViewController:activityViewController
                                                                   animated:YES
                                                                 completion:^{}];
                                            }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:facebookAction];
        [alertController addAction:twitterAction];
        [alertController addAction:moreOptionsAction];
        
//        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
//        if (popover)
//        {
//            popover.sourceView = dcTVNewShowEpisodeTableViewCell;
//            popover.sourceRect = dcTVNewShowEpisodeTableViewCell.bounds;
//            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
     */
}

- (IBAction)actionOnFavBtn:(id)sender {
    /*
    if (self.userEmail != nil){
        AddToPlaylistPopUpViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToPlaylistPopUpViewController"];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFromBottom;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        self.tabBarController.tabBar.hidden = YES;
        vc.playlistDelegate = self;
        vc.isFeedMode = true;
        vc.mFeedItemId = self.mFeedItem.feedItemId;
        [self addChildViewController:vc];
        vc.view.frame = self.view.frame;
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
     */
}

#pragma mark:- Twitter Methods

- (void)twitterSetup:(NSURL *)url :(NSString *)title{
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(aQueue,^{
        NSLog(@"1. This is the global Dispatch Queue");
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"Loading..."];
    });
    
    dispatch_sync(aQueue,^{
        NSLog(@"2. %s",dispatch_queue_get_label(aQueue));
    });
    
    dispatch_async(aQueue,^{
        NSLog(@"3. %s",dispatch_queue_get_label(aQueue));
        UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        [self shareViaTwitter:mImage :title];
    });
}

- (void)shareViaTwitter:(UIImage *)image :(NSString *)title{
    TWTRComposer *composer1 = [[TWTRComposer alloc] init];
    
    //UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:mURL]];
    [composer1 setImage:image];
    [composer1 setText:title];
    [SVProgressHUD dismiss];
    
    [composer1 showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            UIAlertController* alert;
            alert = [UIAlertController alertControllerWithTitle:@"Failed" message:@"Something went wrong while sharing on Twitter, Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else {
            UIAlertController* alert;
            alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your post has been successfully shared." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

#pragma mark:- FBSDKSharing Delegate Methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

#pragma mark - SDWebImage

-(void)showImageOnHeader:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    if (inMemoryImage){
        self.mBgImgView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.mBgImgView.image = image;
        
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
                                    self.mBgImgView.image = image;
                                    self.mBgImgView.layer.borderWidth = 1.0;
                                    self.mBgImgView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image,please try again...");
                                        return;
                                    }
                                }
                            }];
    }
    
    UIView *view = [[UIView alloc] initWithFrame: self.mBgImgView.frame];
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = view.frame;
    gradient.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor] ];
    gradient.locations = @[@0.0, @0.9];
    [view.layer insertSublayer: gradient atIndex: 0];
    [self.mBgImgView addSubview: view];
    [self.mBgImgView bringSubviewToFront: view];
}

#pragma mark:- AddToPlaylist Delegate Methods

- (void)updateUI {
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tabBarController.tabBar.hidden = NO;
}

@end
