//
//  ECIndividualProfileViewController.m
//  EventChat
//
//  Created by Mindbowser on 11/07/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECIndividualProfileViewController.h"
#import "ECAPI.h"
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
#import "ECEventTopicCommentsViewController.h"
#import "ECAttendanceDetailsViewController.h"
#import "DCChatReactionViewController.h"
#import <Social/Social.h>
#import "SVProgressHUD.h"
#import "ECAPINames.h"

@interface ECIndividualProfileViewController ()
@property (nonatomic, strong) NSArray *mFollowingUsersArr;
@property (nonatomic, strong) NSArray *mFollowerUsersArr;
@property (nonatomic, strong) NSMutableArray *userPostArr;

@end

@implementation ECIndividualProfileViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.title = @"Profile";
    [self initialSetup];
    // After search bar functionality, please need to do height of search bar = 56 from storyboard, now it is = 0.
}

- (void)viewWillAppear:(BOOL)animated{
//    [self updateTableView];
//    [self updateUserProfile];
    [self updateUser];
}

#pragma mark:- UITableView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [self.userPostArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        static NSString *CellIdentifier = @"ECUserProfileSocialTableViewCell";
        ECUserProfileSocialTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        [mCell configureSocialCell:self.signedInUser :self.signedInUser];
        [mCell configureSocialCell:self.selectedEcUser :self.signedInUser];
        return mCell;
    }else{
        static NSString *CellIdentifierNew = @"DCInfluencersPersonDetailsTableViewCell";
        DCInfluencersPersonDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
        DCPost *post = [self.userPostArr objectAtIndex:indexPath.row - 1];
        
        if (!cell) {
            cell = [[DCInfluencersPersonDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierNew];
        }
        
        cell.dcPersonDelegate = self;
//        [cell configureWithPost:post signedInUser:self.signedInUser];
        [cell configureWithPost:post signedInUser:self.selectedEcUser];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0){
        /*
        DCPost *mDCPost = [self.userPostArr objectAtIndex:indexPath.row - 1];
        if ([mDCPost.postType  isEqual: @"image"]){
            
        }else if ([mDCPost.postType  isEqual: @"video"]){
            [self playButtonPressed:mDCPost.videoUrl];
         }
         */
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        return 50.0;
    }else{
        return UITableViewAutomaticDimension;
    }
}

#pragma mark:- Instance Methods

- (void)initialSetup{
    if([self.signedInUser.followeeIds containsObject:self.selectedEcUser.userId]){
        [self.mFollowBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else{
        [self.mFollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
    }
    
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.mUserNmLabel setText:[NSString stringWithFormat:@"%@ %@", self.selectedEcUser.firstName, self.selectedEcUser.lastName]];
    
    // Apply round mask
    self.mUserProfileIV.layer.cornerRadius = self.mUserProfileIV.frame.size.width / 2;
    self.mUserProfileIV.layer.borderWidth = 5;
    self.mUserProfileIV.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mUserProfileIV.layer.masksToBounds = YES;
    
    self.mBackgroundIV.layer.cornerRadius = 5.0;
    self.mBackgroundIV.layer.masksToBounds = YES;
    self.mBackgroundIV.layer.borderWidth = 5;
    self.mBackgroundIV.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.mFollowBtn.layer.cornerRadius = 5.0;
    
    // Register cell
    [self.mTableView registerNib:[UINib nibWithNibName:@"DCInfluencersPersonDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:@"DCInfluencersPersonDetailsTableViewCell"];
    
    if(self.selectedEcUser.profilePicUrl == nil || [self.selectedEcUser.profilePicUrl length] == 0){
        if(self.selectedEcUser.facebookUserId != nil){
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"/%@/picture?type=large&redirect=false", self.selectedEcUser.   facebookUserId]
                                          parameters:nil
                                          HTTPMethod:@"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                NSDictionary *responseDictionary = [result dictionaryOrNilValue];
                
                NSError *infoError = nil;
                ECFacebookUserData *fbUserData = [[ECFacebookUserData alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fbUserData.url]];
                UIImage *image = [UIImage imageWithData:data];
                [self.mUserProfileIV setImage:[self imageWithImage:image scaledToSize:CGSizeMake(30, 30)]];
                
                //Update profilePicUrl in User Collection
                if(self.isSignedInUser){
                    [[ECAPI sharedManager] updateProfilePicUrl:self.signedInUser.userId profilePicUrl:fbUserData.url callback:^(NSError *error) {
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
        if (self.selectedEcUser.profilePicUrl != nil){
            [self showProfilePicImage:self ForImageUrl:self.selectedEcUser.profilePicUrl];
        }
    }
    
    if (self.selectedEcUser.coverPic_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:self.selectedEcUser.coverPic_Url];
    }else{
        [self.mBackgroundIV setImage:[UIImage imageNamed:@"cover_slide"]];
    }
    self.mTableView.estimatedRowHeight = 240.0;
    self.mTableView.rowHeight = UITableViewAutomaticDimension;
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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

-(void)updateTableView {
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self loadUserPosts];
    [self loadFollowing];
    [self loadFollowers];
    [self.mTableView reloadData];
}

#pragma mark:- Handling background Image upload

- (void) beginBackgroundUpdateTask {
    self.bkUptTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.bkUptTaskId];
    self.bkUptTaskId = UIBackgroundTaskInvalid;
}

#pragma mark:- DCInfluencersPerson DetailsTVCell Delegate Methods

- (void)didTapAttendanceButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postItem = [self.userPostArr objectAtIndex:index - 1];
    if (postItem.postId != nil){
        [self setUserAttendanceResponse:postItem.postId];
    }
}

#pragma mark:- API Call Methods

- (void)loadFollowing{
    [[ECAPI sharedManager] getFollowing:self.selectedEcUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error getFollowing: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowingUsersArr = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadFollowers{
    [[ECAPI sharedManager] getFollowers:self.selectedEcUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error getFollowers: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowerUsersArr = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadUserPosts{
    [[ECAPI sharedManager] getPostByUserId:self.selectedEcUser.userId callback:^(NSArray *posts, NSError *error) {
        if (error) {
            NSLog(@"Error getPostByUserId: %@", error);
        } else {
            self.userPostArr = [[NSMutableArray alloc] initWithArray:posts];
            [self.userPostArr sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
            [self.mTableView reloadData];
        }
    }];
}

-(void)setUserAttendanceResponse:(NSString *)strFeedId{
    NSString *userResponse = @"Going";
    
    [[ECAPI sharedManager] setAttendeeResponse:self.selectedEcUser.userId feedItemId:strFeedId response:userResponse callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
        } else {
//            [self updateUserProfile];
            [self updateUser];
        }
    }];
}

-(void)updateUserProfile{
    [[ECAPI sharedManager] updateProfilePicUrl:self.selectedEcUser.userId profilePicUrl:self.selectedEcUser.profilePicUrl callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error update user profile: %@", error);
        } else {
            [self updateTableView];
        }
    }];
}

-(void)updateUser{
    [[ECAPI sharedManager] updateUser:self.selectedEcUser callback:^(ECUser *ecUser, NSError *error) {
        if (error) {
            NSLog(@"Error update user: %@", error);
        } else {
            self.selectedEcUser = ecUser;
            [self updateTableView];
        }
    }];
}

- (void)followByUserIdAPICall{
    [[ECAPI sharedManager] followUserByUserId:self.signedInUser.userId followeeId:self.selectedEcUser.userId callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error followUserByUserId: %@", error);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"New Follow"
                                      message:[NSString stringWithFormat:@"You have just started following %@ %@.", self.selectedEcUser.firstName, self.selectedEcUser.lastName]
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)unfollowByUserIdAPICall{
    [[ECAPI sharedManager] unfollowUserByUserId:self.signedInUser.userId followeeId:self.selectedEcUser.userId callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error unfollowUserByUserId: %@", error);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Unfollow"
                                      message:[NSString stringWithFormat:@"You have stopped following %@ %@.", self.selectedEcUser.firstName, self.selectedEcUser.lastName]
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnFollowButton:(id)sender {
    if ([self.mFollowBtn.titleLabel.text isEqualToString:@"Unfollow"]){
        [self unfollowByUserIdAPICall];
        [self.mFollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
    }
    else{
        [self followByUserIdAPICall];
        [self.mFollowBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
}

- (IBAction)actionOnFbBtn:(id)sender {
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = true;
    ecFollowViewController.usersArray = self.mFollowingUsersArr;
    ecFollowViewController.dcUser = self.selectedEcUser;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnTwtBtn:(id)sender {
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    ecFollowViewController.usersArray = self.mFollowerUsersArr;
    ecFollowViewController.dcUser = self.selectedEcUser;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnInstaBtn:(id)sender {
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = false;
    dcPlaylistsTableViewController.isSignedInUser = self.isSignedInUser;
    dcPlaylistsTableViewController.signedInUser = self.signedInUser;
    dcPlaylistsTableViewController.profileUser = self.selectedEcUser;
    [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(ECIndividualProfileViewController *)vc ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage) {
        self.mBackgroundIV.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.mBackgroundIV.image = image;
        
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
                                    self.mBackgroundIV.image = image;
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

-(void)showProfilePicImage:(ECIndividualProfileViewController *)vc ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage) {
        self.mUserProfileIV.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.mUserProfileIV.image = image;
        
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
                                    self.mUserProfileIV.image = image;
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
