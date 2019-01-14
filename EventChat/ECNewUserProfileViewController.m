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
#import "ECFollowViewController.h"
#import "ECFavoritesViewController.h"
#import "ECUserProfileSocialTableViewCell.h"
#import "DCNewPostViewController.h"
#import "DCPlaylistsTableViewController.h"

@interface ECNewUserProfileViewController ()
@property (nonatomic, assign) NSString *userEmailStr;
@property (nonatomic, strong) NSArray *mFollowingUsersArray;
@property (nonatomic, strong) NSArray *mFollowerUsersArray;
@property (nonatomic, strong) UIBarButtonItem *postBarButtonItem;

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
    [self loadFollowing];
    [self loadFollowers];
}

#pragma mark:- UITableView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ECUserProfileSocialTableViewCell";
    ECUserProfileSocialTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [mCell configureSocialCell:self.profileUser :self.signedInUser];
    return mCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

#pragma mark:- Instance Methods

- (void)initialSetup{
    if([self.signedInUser.followeeIds containsObject:self.profileUser.userId]){
        [self.mFollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else{
        [self.mFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
   
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
    
    //    [self showImageOnHeader:self.profileUser.profilePicUrl];
    
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
                [self.userProfileImageView setImage:image];
                
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
        [self.userProfileImageView setImage:image];
    }
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
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:dcNewPostViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark:- API Call Methods

- (void)loadFollowing{
    [[ECAPI sharedManager] getFollowing:self.profileUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowingUsersArray = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadFollowers{
    [[ECAPI sharedManager] getFollowers:self.profileUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowerUsersArray = [[NSArray alloc] initWithArray:users];
        }
    }];
}

#pragma mark:- Post Delegate Methods

- (void)refreshPostStream {
    NSLog(@"Need to call post api...");
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

@end
