//
//  ECNewUserProfileViewController.m
//  EventChat
//
//  Created by Mindbowser on 14/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECNewUserProfileViewController.h"
#import "ECAPI.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "IonIcons.h"
#import "SVProgressHUD.h"
#import "NSObject+TypeValidation.h"
#import "ECFacebookUserData.h"
#import "ECColor.h"
#import "ECProfileCell.h"
#import "NSDate+NVTimeAgo.h"
#import "ECUserListCell.h"
#import "ECUser.h"
#import "DCPost.h"
#import "ECFollowViewController.h"
#import "ECFavoritesViewController.h"
#import "ECUserProfileSocialTableViewCell.h"
#import "DCNewPostViewController.h"
#import "DCPlaylistsTableViewController.h"
#import "DCInfluencersPersonDetailsTableViewCell.h"
//
#import "ECCommonClass.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ECFullScreenImageViewController.h"
#import "ECEventTopicCommentsViewController.h"
#import "ECAttendanceDetailsViewController.h"
#import "DCChatReactionViewController.h"
#import <Social/Social.h>

@interface ECNewUserProfileViewController ()
@property (nonatomic, assign) NSString *userEmailStr;
@property (nonatomic, strong) NSArray *mFollowingUsersArray;
@property (nonatomic, strong) NSArray *mFollowerUsersArray;
@property (nonatomic, strong) NSMutableArray *userPostArray;
@property (nonatomic, strong) UIBarButtonItem *postBarButtonItem;
@property (strong, nonatomic) ECFullScreenImageViewController *fullScreenImageVC;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;

@end

@implementation ECNewUserProfileViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self.navigationItem setTitle:@"Profile"];
    [self initialSetup];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadUserPosts];
    [self loadFollowing];
    [self loadFollowers];
}

#pragma mark:- UITableView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [self.userPostArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        static NSString *CellIdentifier = @"ECUserProfileSocialTableViewCell";
        ECUserProfileSocialTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [mCell configureSocialCell:self.profileUser :self.signedInUser];
        return mCell;
    }else{
        static NSString *CellIdentifierNew = @"DCInfluencersPersonDetailsTableViewCell";
        DCInfluencersPersonDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
        DCPost *post = [self.userPostArray objectAtIndex:indexPath.row - 1];
        
        if (!cell) {
            cell = [[DCInfluencersPersonDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierNew];
        }
        
        cell.dcPersonDelegate = self;
        [cell configureWithPost:post signedInUser:self.signedInUser];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0){
        DCPost *mDCPost = [self.userPostArray objectAtIndex:indexPath.row - 1];
        if ([mDCPost.postType  isEqual: @"image"]){
            if (mDCPost.imageUrl != nil){
                self.fullScreenImageVC = [[ECFullScreenImageViewController alloc] initWithNibName:@"ECFullScreenImageViewController" bundle:nil];
                self.fullScreenImageVC.imagePath = mDCPost.imageUrl;
                [self presentViewController:self.fullScreenImageVC animated:YES completion:nil];
            }
        }
        /*
         else if ([mDCPost.postType  isEqual: @"video"]){
         [self playButtonPressed:mDCPost.videoUrl];
         }
         */
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        return 50.0;
    }else{
        return UITableViewAutomaticDimension;
    }
}

#pragma mark:- Instance Methods

- (void)initialSetup{
    [self.mFollowButton setHidden:true];
    
    if([self.signedInUser.followeeIds containsObject:self.profileUser.userId]){
        [self.mFollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else{
        [self.mFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"updateTableView" object:nil];
    
    self.postBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(didTapPostButton:)];
    //    self.postBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapPostButton:)];
    [self.navigationItem setRightBarButtonItem:self.postBarButtonItem];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.mUserNameLabel setText:[NSString stringWithFormat:@"%@ %@", self.profileUser.firstName, self.profileUser.lastName]];
    
    // Apply round mask
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.width / 2;
    self.userProfileImageView.layer.borderWidth = 5;
    self.userProfileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userProfileImageView.layer.masksToBounds = YES;
    
    self.userBGImageView.layer.cornerRadius = 5.0;
    self.userBGImageView.layer.masksToBounds = YES;
    self.userBGImageView.layer.borderWidth = 5;
    self.userBGImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.mFollowButton.layer.cornerRadius = 5.0;
    // Register cell
    [self.mUserProfileTableView registerNib:[UINib nibWithNibName:@"DCInfluencersPersonDetailsTableViewCell" bundle:nil]
                     forCellReuseIdentifier:@"DCInfluencersPersonDetailsTableViewCell"];
    
    if(self.profileUser.profilePicUrl == nil || [self.profileUser.profilePicUrl length] == 0){
        if(self.profileUser.facebookUserId != nil){
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"/%@/picture?type=large&redirect=false", self.profileUser.facebookUserId]
                                          parameters:nil
                                          HTTPMethod:@"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                // Handle the result
                NSLog(@"Results: %@", result);
                NSDictionary *responseDictionary = [result dictionaryOrNilValue];
                
                NSError *infoError = nil;
                ECFacebookUserData *fbUserData = [[ECFacebookUserData alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fbUserData.url]];
                UIImage *image = [UIImage imageWithData:data];
                [self.userProfileImageView setImage:[self imageWithImage:image scaledToSize:CGSizeMake(30, 30)]];
                
                //Update profilePicUrl in User Collection
                if(self.isSignedInUser){
                    NSLog(@"ProfilePicUrl: %@", fbUserData.url);
                    [[ECAPI sharedManager] updateProfilePicUrl:self.profileUser.userId profilePicUrl:fbUserData.url callback:^(NSError *error) {
                        if (error) {
                            NSLog(@"Error adding user: %@", error);
                        } else {
                            self.signedInUser.profilePicUrl = fbUserData.url;
                        }
                    }];
                }
            }];
        }
    }
    else{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.profileUser.profilePicUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [self.userProfileImageView setImage:[self imageWithImage:image scaledToSize:CGSizeMake(30, 30)]];
    }
    
    if (self.profileUser.coverPic_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:self.profileUser.coverPic_Url];
    }
    self.mUserProfileTableView.estimatedRowHeight = 240.0;
    self.mUserProfileTableView.rowHeight = UITableViewAutomaticDimension;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
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

#pragma mark:- IBAction Methods

- (IBAction)actionOnFollowButton:(id)sender {
    NSLog(@"Comming soon...");
    /*
     if([self.signedInUser.followeeIds containsObject:self.profileUser.userId]){
     [[ECAPI sharedManager] unfollowUserByUserId:self.signedInUser.userId followeeId:self.profileUser.userId callback:^(NSError *error) {
     if (error) {
     NSLog(@"Error adding user: %@", error);
     } else {
     UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@"Unfollow"
     message:[NSString stringWithFormat:@"You have stopped following %@ %@.", self.profileUser.firstName, self.profileUser.lastName]
     delegate:nil
     cancelButtonTitle:@"Okay"
     otherButtonTitles:nil];
     [alertView show];
     [self.mFollowButton setTitle:@"+ Follow" forState:UIControlStateNormal];
     }
     }];
     }
     else{
     [[ECAPI sharedManager] followUserByUserId:self.signedInUser.userId followeeId:self.profileUser.userId callback:^(NSError *error) {
     if (error) {
     NSLog(@"Error adding user: %@", error);
     } else {
     UIAlertView *alertView = [[UIAlertView alloc]
     initWithTitle:@"New Follow"
     message:[NSString stringWithFormat:@"You have just started following %@ %@.", self.profileUser.firstName, self.profileUser.lastName]
     delegate:nil
     cancelButtonTitle:@"Okay"
     otherButtonTitles:nil];
     [alertView show];
     [self.mFollowButton setTitle:@"- Unfollow" forState:UIControlStateNormal];
     }
     }];
     }
     */
}

- (IBAction)actionOnFacebookButton:(id)sender {
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = true;
    ecFollowViewController.usersArray = self.mFollowingUsersArray;
    ecFollowViewController.dcUser = self.profileUser;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnTwitterButton:(id)sender {
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    ecFollowViewController.usersArray = self.mFollowerUsersArray;
    ecFollowViewController.dcUser = self.profileUser;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnInstagramButton:(id)sender {
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = false;
    dcPlaylistsTableViewController.isSignedInUser = self.isSignedInUser;
    dcPlaylistsTableViewController.signedInUser = self.signedInUser;
    dcPlaylistsTableViewController.profileUser = self.profileUser;
    [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
}

- (IBAction)didTapPostButton:(id)sender{
    DCNewPostViewController *dcNewPostViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCNewPostViewController"];
    dcNewPostViewController.delegate = self;
    //    UINavigationController *navigationController =
    //    [[UINavigationController alloc] initWithRootViewController:dcNewPostViewController];
    //    [self presentViewController:navigationController animated:YES completion:nil];
    [self.navigationController pushViewController:dcNewPostViewController animated:true];
}

#pragma mark:- API Call Methods

- (void)loadFollowing{
    [[ECAPI sharedManager] getFollowing:self.profileUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error getFollowing: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowingUsersArray = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadFollowers{
    [[ECAPI sharedManager] getFollowers:self.profileUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error getFollowers: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowerUsersArray = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadUserPosts{
    [[ECAPI sharedManager] getPostByUserId:self.profileUser.userId callback:^(NSArray *posts, NSError *error) {
        if (error) {
            NSLog(@"Error getPostByUserId: %@", error);
        } else {
            self.userPostArray = [[NSMutableArray alloc] initWithArray:posts];
            [self.userPostArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
            [self.mUserProfileTableView reloadData];
        }
    }];
}

#pragma mark:- Post Notification Methods

-(void)updateTableView {
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self loadUserPosts];
    [self loadFollowing];
    [self loadFollowers];
    [self.mUserProfileTableView reloadData];
}

#pragma mark:- Post Delegate Methods

- (void)refreshPostStream {
    [self loadUserPosts];
}

#pragma mark:- SDWebImage

-(void)showImageOnHeader:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    
    if (inMemoryImage)
    {
        self.userBGImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.userBGImageView.image = image;
        
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
                                    self.userBGImageView.image = image;
                                    self.userBGImageView.layer.borderWidth = 1.0;
                                    self.userBGImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again");
                                        return;
                                    }
                                }
                            }];
    }
}

#pragma mark:- DCInfluencersPerson DetailsTVCell Delegate Methods

-(void)playVideoButtonTapped:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    [self playButtonPressed:postNew.videoUrl];
}

- (void)didTapCommentsButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    /*
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
    dcChat.isPost = true;
    dcChat.dcPost = postNew;
    [self.navigationController pushViewController:dcChat animated:NO];
     
    ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
    ecEventTopicCommentsViewController.isPost = true;
    ecEventTopicCommentsViewController.dcPost = postNew;
    [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
     */
}

- (void)didTapFavoriteButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    DCPlaylistsTableViewController *dcPlaylistsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTVC.isFeedMode = true;
    dcPlaylistsTVC.isSignedInUser = true;
    dcPlaylistsTVC.feedItemId = postNew.postId;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didTapAttendanceButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
    ecAttendanceDetailsViewController.selectedPostItem = postNew;
    ecAttendanceDetailsViewController.isPost = true;
    [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
}

- (void)didTapShareButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index {
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    NSString* title = postNew.displayName;
    NSString* link = @"";
    
    if ([postNew.postType  isEqual: @"image"]){
        link = postNew.imageUrl;
    }else if ([postNew.postType  isEqual: @"video"]){
        link = postNew.videoUrl;
    }
    
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
                                         self.shareDialog = [[FBSDKShareDialog alloc] init];
                                         self.content = [[FBSDKShareLinkContent alloc] init];
                                         self.content.contentURL = [NSURL URLWithString:link];
                                         self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                         self.content.contentDescription = postNew.content;
                                         
                                         if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
                                             [self.shareDialog setMode:FBSDKShareDialogModeNative];
                                         }
                                         else {
                                             [self.shareDialog setMode:FBSDKShareDialogModeAutomatic];
                                         }
                                         //[self.shareDialog setMode:FBSDKShareDialogModeShareSheet];
                                         [self.shareDialog setShareContent:self.content];
                                         [self.shareDialog setFromViewController:self];
                                         [self.shareDialog setDelegate:self];
                                         [self.shareDialog show];
                                         //[FBSDKShareDialog showFromViewController:self withContent:self.content delegate:self];
                                     }];
    
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Twitter", @"Twitter action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        [self twitterSetup:[NSURL URLWithString:link] :postNew.content];
                                    }];
    
    UIAlertAction *moreOptionsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"More Options...", @"More Options... action")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                        {
                                            NSLog(@"More Option... action");
                                            UIActivityViewController* activityViewController =
                                            [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                              applicationActivities:nil];
                                            
                                            [self presentViewController:activityViewController
                                                               animated:YES
                                                             completion:^{}];
                                        }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:facebookAction];
    [alertController addAction:twitterAction];
    [alertController addAction:moreOptionsAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark:- Action on video tap Methods

-(void)playButtonPressed:(NSString *)videoURLStr
{
    BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
    if (isInternetAvailable) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoURLStr]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinishVideoPlay)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        [self presentViewController:avvc animated:YES completion:nil];
    } else {
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
    }
}

-(void)didFinishVideoPlay{
    [self.navigationController dismissViewControllerAnimated:false completion:nil];
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(ECNewUserProfileViewController *)vc ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        self.userBGImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.userBGImageView.image = image;
        
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
                                    self.userBGImageView.image = image;
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
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [tweetSheet addImage:image];
    [tweetSheet setTitle:title];
    [SVProgressHUD dismiss];
    
    [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        [SVProgressHUD dismiss];
        switch (result) {
            case SLComposeViewControllerResultCancelled:
            {
                NSLog(@"Post Failed");
                UIAlertController* alert;
                alert = [UIAlertController alertControllerWithTitle:@"Failed" message:@"Something went wrong while sharing on Twitter, Please try again later." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    
                }];
                [alert addAction:defaultAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
                
                break;
            }
            case SLComposeViewControllerResultDone:
            {
                NSLog(@"Post Sucessful");
                UIAlertController* alert;
                alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your post has been successfully shared." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
                break;
            }
            default:
                break;
        }
    }];
    [self presentViewController:tweetSheet animated:YES completion:Nil];
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

#pragma mark:- Handling image tap which will open image in another larger view Methods

/*
 - (void)handleImageTap:(UIGestureRecognizer *)sender {
 
 CGPoint location = [sender locationInView:self.view];
 if (CGRectContainsPoint([self.view convertRect:self.mUserProfileTableView.frame fromView:self.mUserProfileTableView.superview], location))
 {
 CGPoint locationInTableview = [self.mUserProfileTableView convertPoint:location fromView:self.view];
 NSIndexPath *indexPath = [self.mUserProfileTableView indexPathForRowAtPoint:locationInTableview];
 if (indexPath){
 DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
 BOOL imageContains = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:postNew.imageUrl]];
 if (imageContains) {
 self.fullScreenImageVC = [[ECFullScreenImageViewController alloc] initWithNibName:@"ECFullScreenImageViewController" bundle:nil];
 self.fullScreenImageVC.imagePath = postNew.imageUrl;
 [self presentViewController:self.fullScreenImageVC animated:YES completion:nil];
 }
 }
 }
 }
 */
@end
