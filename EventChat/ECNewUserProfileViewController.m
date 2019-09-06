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
//
#import "ECSharedmedia.h"
#import "S3UploadImage.h"
#import "SVProgressHUD.h"
#import "S3Constants.h"
#import "Reachability.h"
#import "ECAPINames.h"
#import "ECIndividualProfileTableViewCell.h"

@interface ECNewUserProfileViewController ()
@property (nonatomic, assign) NSString *userEmailStr;
@property (nonatomic, strong) NSArray *mFollowingUsersArray;
@property (nonatomic, strong) NSArray *mFollowerUsersArray;
@property (nonatomic, strong) NSMutableArray *userPostArray;
@property (nonatomic, strong) UIBarButtonItem *postBarButtonItem;
@property (strong, nonatomic) ECFullScreenImageViewController *fullScreenImageVC;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, strong) NSMutableArray *topics;

@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *filterResultArray;
@property (nonatomic, assign) BOOL isFiltered;

@property (nonatomic, assign) BOOL isProfileChanges;
@property (nonatomic, strong) NSArray *mFollowingArr;

@end

@implementation ECNewUserProfileViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mLoginUser = [[ECAPI sharedManager] signedInUser];
    self.mSelectedECUser = self.mLoginUser;
    self.mFollowingArr = self.mLoginUser.followeeIds;
    self.userIdStr = self.mLoginUser.userId;
    self.mLoginUId = self.mLoginUser.userId;
    self.isProfileChanges = false;
    [self.navigationItem setTitle:@"Profile"];
    [self initialSetup];
    
    [self getAllUserList];
    [self loadUserPosts:self.mLoginUser.userId];
    [self loadFollowers:self.mLoginUser.userId];
    [self loadFollowing:self.mLoginUser.userId];
    
    /*
    //LongPressGestureToUpload_ProfileImage_CoverImage
    [self setupGestureForProfileImageView];
    [self setupGestureForCoverImageView];
     */
}

#pragma mark:- SearchBar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.mTableView setHidden:false];
    if (searchText.length == 0) {
        /*
        self.isFiltered = false;
        [self.mSearchBar endEditing:YES];
        [self.mTableView setHidden:true];
        */
    }
    else {
        self.isFiltered = true;
        self.filterResultArray = [[NSMutableArray alloc]init];
        for (NSArray *userObjet in _resultArray) {
            if ([userObjet valueForKey:@"firstName"] && [userObjet valueForKey:@"lastName"]){
                NSRange range = [[userObjet valueForKey:@"firstName"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (range.length > 0) {
                    [self.filterResultArray addObject:userObjet];
                }
            }
        }
    }
    [self.mTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.mTableView setHidden:true];
    [self.mSearchBar endEditing:YES];
    self.mSearchBar.text = @"";
    self.searchBarHeightConst.constant = 0.0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.mSearchBar endEditing:YES];
}

#pragma mark:- UITableView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mTableView){
        return [self.filterResultArray count];
    }else{
        return 1 + [self.userPostArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.mTableView){
        static NSString *CellIdentifier = @"ECIndividualProfileTableViewCell";
        ECIndividualProfileTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        mCell.mProfileImageView.layer.cornerRadius = mCell.mProfileImageView.frame.size.width / 2;
        mCell.mProfileImageView.layer.borderWidth = 5;
        mCell.mProfileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        mCell.mProfileImageView.layer.masksToBounds = YES;
        
        NSArray *mUser = [self.filterResultArray objectAtIndex:indexPath.row];
        
        NSString *fName = [mUser valueForKey:@"firstName"];
        NSString *lName = [mUser valueForKey:@"lastName"];
        NSString *fullName = [NSString stringWithFormat: @"%@ ", fName];
        fullName = [fullName stringByAppendingString:lName];
        
        [mCell configureCellWithUserItem:fullName profileURL:[mUser valueForKey:@"profilePicUrl"] cellIndex:indexPath];
        
        return mCell;
        
    }else{
        if (indexPath.row == 0){
            static NSString *CellIdentifier = @"ECUserProfileSocialTableViewCell";
            ECUserProfileSocialTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (self.isProfileChanges){
                [mCell configureSocialCell:self.mSelectedECUser :self.mSelectedECUser];
            }else{
                [mCell configureSocialCell:self.profileUser :self.signedInUser];
            }
            
            return mCell;
        }else{
            static NSString *CellIdentifierNew = @"DCInfluencersPersonDetailsTableViewCell";
            DCInfluencersPersonDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
            DCPost *post = [self.userPostArray objectAtIndex:indexPath.row - 1];
            
            if (!cell) {
                cell = [[DCInfluencersPersonDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierNew];
            }
            
            cell.dcPersonDelegate = self;
            if (self.isProfileChanges){
                [cell configureWithPost:post signedInUser:self.mSelectedECUser];
                return cell;
            }else{
                [cell configureWithPost:post signedInUser:self.signedInUser];
                return cell;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.mTableView){
        NSError *infoError = nil;
        self.mSelectedECUser = [[ECUser alloc] initWithDictionary:[self.filterResultArray objectAtIndex:indexPath.row] error:&infoError];
        
        self.mLoginUId = self.mSelectedECUser.userId;
        if ([self.userIdStr isEqualToString:self.mSelectedECUser.userId]){
            [self.mFollowButton setHidden:true];
            [self.coverImaegButton setHidden:false];
            [self.profileImageButton setHidden:false];
            self.isSignedInUser = true;
        }else{
            [self.mFollowButton setHidden:false];
            [self.coverImaegButton setHidden:true];
            [self.profileImageButton setHidden:true];
            self.isSignedInUser = false;
        }
        if([self.mFollowingArr containsObject:self.mSelectedECUser.userId]){
            [self.mFollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
        else{
            [self.mFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", self.mSelectedECUser.firstName, self.mSelectedECUser.lastName];
        [self.mUserNameLabel setText: fullName];
        
        if (self.mSelectedECUser.profilePicUrl != nil && ![self.mSelectedECUser.profilePicUrl  isEqual: @""]){
            [self showProfilePicImage:self ForImageUrl:self.mSelectedECUser.profilePicUrl];
        }else{
            [self.userProfileImageView setImage:[UIImage imageNamed:@"missing-profile.png"]];
        }
        if (self.mSelectedECUser.coverPic_Url != nil && ![self.mSelectedECUser.coverPic_Url  isEqual: @""]){
            [self showImageOnTheCell:self ForImageUrl:self.mSelectedECUser.coverPic_Url];
        }else{
            [self.userBGImageView setImage:[UIImage imageNamed:@"cover_slide"]];
        }
        
        self.mfName = self.mSelectedECUser.firstName;
        self.mlName = self.mSelectedECUser.lastName;
        
        self.isProfileChanges = true;
        [self.mTableView setHidden:true];
        [self.mSearchBar endEditing:YES];
        self.mSearchBar.text = @"";
//        [self updateTableView];
        [self refreshTableView];
    }else{
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.mTableView){
        return 60.0;
    }else{
        if (indexPath.row == 0){
            return 50.0;
        }else{
            return UITableViewAutomaticDimension;
        }
    }
}

#pragma mark:- Instance Methods

- (void)initialSetup{
    [self.mFollowButton setHidden:true];
    /*
    if([self.mLoginUser.followeeIds containsObject:self.mLoginUser.userId]){
        [self.mFollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else{
        [self.mFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"updateTableView" object:nil];
    
    self.postBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(didTapPostButton:)];
    
    self.mSearchBar.delegate = self;
    
    //    self.postBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self  action:@selector(didTapPostButton:)];
//    [self.navigationItem setRightBarButtonItem:self.postBarButtonItem];
    self.navigationItem.rightBarButtonItems=@[self.postBarButtonItem, self.mSearchBarBtnItem];
    
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.mUserNameLabel setText:[NSString stringWithFormat:@"%@ %@", self.mLoginUser.firstName, self.mLoginUser.lastName]];
    
    [self.coverImaegButton setImage:[IonIcons imageWithIcon:ion_ios_camera_outline  size:27.0 color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
    [self.profileImageButton setImage:[IonIcons imageWithIcon:ion_ios_camera_outline  size:27.0 color:[UIColor darkGrayColor]] forState:UIControlStateNormal];
    
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
    
    if(self.mLoginUser.profilePicUrl == nil || [self.mLoginUser.profilePicUrl length] == 0){
        if(self.mLoginUser.facebookUserId != nil){
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath:[NSString stringWithFormat:@"/%@/picture?type=large&redirect=false", self.mLoginUser.facebookUserId]
                                          parameters:nil
                                          HTTPMethod:@"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                // Handle the result
//                NSLog(@"Results: %@", result);
                NSDictionary *responseDictionary = [result dictionaryOrNilValue];
                
                NSError *infoError = nil;
                ECFacebookUserData *fbUserData = [[ECFacebookUserData alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fbUserData.url]];
                UIImage *image = [UIImage imageWithData:data];
                [self.userProfileImageView setImage:[self imageWithImage:image scaledToSize:CGSizeMake(30, 30)]];
                
                //Update profilePicUrl in User Collection
                if(self.isSignedInUser){
//                    NSLog(@"ProfilePicUrl: %@", fbUserData.url);
                    [[ECAPI sharedManager] updateProfilePicUrl:self.mLoginUser.userId profilePicUrl:fbUserData.url callback:^(NSError *error) {
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
        if (self.mLoginUser.profilePicUrl != nil){
            [self showProfilePicImage:self ForImageUrl:self.mLoginUser.profilePicUrl];
        }
    }
    
    if (self.mLoginUser.coverPic_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:self.mLoginUser.coverPic_Url];
    }else{
       [self.userBGImageView setImage:[UIImage imageNamed:@"cover_slide"]];
    }
    self.mUserProfileTableView.estimatedRowHeight = 240.0;
    self.mUserProfileTableView.rowHeight = UITableViewAutomaticDimension;
    self.mUserProfileTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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

-(void) setupGestureForProfileImageView {
    UILongPressGestureRecognizer *lpHandler = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHoldGesture:)];
    lpHandler.minimumPressDuration = 1; //seconds
    lpHandler.delegate = self;
    [self.userProfileImageView addGestureRecognizer:lpHandler];
}

-(void) setupGestureForCoverImageView {
    UILongPressGestureRecognizer *lpHandler2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHoldGestureTwo:)];
    lpHandler2.minimumPressDuration = 1; //seconds
    lpHandler2.delegate = self;
    [self.userBGImageView addGestureRecognizer:lpHandler2];
}

- (void) handleHoldGesture:(UILongPressGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan == gesture.state) {
        // Called on start of gesture, do work here
        NSLog(@"start of gesture");
        self.isCoverImage = false;
        [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
            if (flag) {
                [self uploadImage];
            }
        }];
    }
    /*
    if(UIGestureRecognizerStateChanged == gesture.state) {
        // Do repeated work here (repeats continuously) while finger is down
        NSLog(@"repeats continuously");
    }
     */
    if(UIGestureRecognizerStateEnded == gesture.state) {
        // Do end work here when finger is lifted
        NSLog(@"finger is lifted.");
    }
}

- (void) handleHoldGestureTwo:(UILongPressGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan == gesture.state) {
        NSLog(@"start of gesture");
        self.isCoverImage = true;
        [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
            if (flag) {
                [self uploadImage];
            }
        }];
    }
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnFollowButton:(id)sender {
    if ([self.mFollowButton.titleLabel.text isEqualToString:@"Unfollow"]){
        [self unfollowByUserIdAPICall];
        [self.mFollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    else{
        [self followByUserIdAPICall];
        [self.mFollowButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
}

- (IBAction)actionOnFacebookButton:(id)sender {
    ECFollowViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    vc.showFollowing = true;
    vc.usersArray = self.mFollowingUsersArray;
    vc.dcUser = self.profileUser;
    vc.mSelectedLoginUserId = self.mLoginUId;
    vc.isComeFromProfile = true;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionOnTwitterButton:(id)sender {
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    ecFollowViewController.usersArray = self.mFollowerUsersArray;
    ecFollowViewController.dcUser = self.profileUser;
    ecFollowViewController.mSelectedLoginUserId = self.mLoginUId;
    ecFollowViewController.isComeFromProfile = true;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnInstagramButton:(id)sender {
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = false;
    dcPlaylistsTableViewController.isSignedInUser = self.isSignedInUser;
    dcPlaylistsTableViewController.signedInUser = self.signedInUser;
//    dcPlaylistsTableViewController.profileUser = self.profileUser;
    dcPlaylistsTableViewController.profileUser = self.mSelectedECUser;
    [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
}

- (IBAction)didTapPostButton:(id)sender{
    DCNewPostViewController *dcNewPostViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCNewPostViewController"];
    dcNewPostViewController.delegate = self;
    [self.navigationController pushViewController:dcNewPostViewController animated:true];
}

- (IBAction)actionOnCoverImageButton:(id)sender {
    self.isCoverImage = true;
    [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
        if (flag) {
            [self uploadImage];
        }
    }];
}

- (IBAction)actionOnProfileImageButton:(id)sender {
    self.isCoverImage = false;
    [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
        if (flag) {
            [self uploadImage];
        }
    }];
}

- (IBAction)actionOnSearchBarBtnClick:(id)sender {
    self.searchBarHeightConst.constant = 40.0;
    //If you want to enable cancel button always.
    [[self.mSearchBar valueForKey:@"_cancelButton"] setEnabled:YES];
    [self.mTableView setHidden:false];
    
    self.isFiltered = true;
    self.filterResultArray = [[NSMutableArray alloc]init];
    for (NSArray *userObjet in _resultArray) {
        if ([userObjet valueForKey:@"firstName"] && [userObjet valueForKey:@"lastName"]){
            NSRange range = [[userObjet valueForKey:@"firstName"] rangeOfString:@"a" options:NSCaseInsensitiveSearch];
            if (range.length > 0) {
                [self.filterResultArray addObject:userObjet];
            }
        }
    }
    [self.mTableView reloadData];
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
                    if(imageURL != nil){
                        ECCommonClass *instance = [ECCommonClass sharedManager];
                        if (self.isCoverImage){
                            instance.isProfilePicUpdated = false;
                            self.signedInUser.coverPic_Url = imageURL;
                            [self showImageOnTheCell:self ForImageUrl:imageURL];
//                            [self updateUser];
                        }else{
                            instance.isProfilePicUpdated = true;
                            self.signedInUser.profilePicUrl = imageURL;
                            [self showProfilePicImage:self ForImageUrl:imageURL];
                        }
                    }
                    
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
//                                       [self uploadVideo];
                                   }
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark:- API Call Methods

- (void)loadFollowing:(NSString *)userId{
    NSLog(@"userId loadFollowing: \(userId)");
    [[ECAPI sharedManager] getFollowing:userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error getFollowing: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowingUsersArray = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadFollowers:(NSString *)userId{
    NSLog(@"userId loadFollowers: \(userId)");
    [[ECAPI sharedManager] getFollowers:userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error getFollowers: %@", error);
        } else {
            NSLog(@"%@", users);
            self.mFollowerUsersArray = [[NSArray alloc] initWithArray:users];
        }
    }];
}

- (void)loadUserPosts:(NSString *)userId{
    [[ECAPI sharedManager] getPostByUserId:userId callback:^(NSArray *posts, NSError *error) {
        if (error) {
            NSLog(@"Error getPostByUserId: %@", error);
        } else {
            self.userPostArray = [[NSMutableArray alloc] initWithArray:posts];
            [self.userPostArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
            [self.mUserProfileTableView reloadData];
        }
    }];
}

-(void)updateUser{
    [[ECAPI sharedManager] updateUser:self.mSelectedECUser callback:^(ECUser *ecUser, NSError *error) {
        if (error) {
            NSLog(@"Error update user: %@", error);
        } else {
            self.mSelectedECUser = ecUser;
            [self updateTableView];
        }
    }];
}

- (void)getAllUserList{
    [[ECAPI sharedManager] getAllUserListAPI:^(NSArray *searchResult, NSError *error) {
        if (error) {
            NSLog(@"Error getAllUserList: %@", error);
        } else {
            self.resultArray = [[NSMutableArray alloc] initWithArray:searchResult];
            [self.mTableView reloadData];
        }
    }];
}

- (void)followByUserIdAPICall{
    [[ECAPI sharedManager] followUserByUserId:self.mLoginUser.userId followeeId:self.mLoginUId callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error followUserByUserId: %@", error);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"New Follow"
                                      message:[NSString stringWithFormat:@"You have just started following %@ %@.", self.mfName, self.mlName]
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
            [self refreshTableView];
        }
    }];
}

- (void)unfollowByUserIdAPICall{
    [[ECAPI sharedManager] unfollowUserByUserId:self.mLoginUser.userId followeeId:self.mLoginUId callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error unfollowUserByUserId: %@", error);
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Unfollow"
                                      message:[NSString stringWithFormat:@"You have stopped following %@ %@.", self.mfName, self.mlName]
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
            [self refreshTableView];
        }
    }];
}

#pragma mark:- Post Notification Methods

-(void)updateTableView {
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self loadUserPosts:self.mLoginUId];
    [self loadFollowers:self.mLoginUId];
    [self loadFollowing:self.mLoginUId];
    [self.mUserProfileTableView reloadData];
}

-(void)refreshTableView {
    [self updateUser];
}

#pragma mark:- Post Delegate Methods

- (void)refreshPostStream {
    [self loadUserPosts:self.profileUser.userId];
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

#pragma mark:- AddToPlaylist Delegate Methods

- (void)updateUI{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark:- DCInfluencersPerson DetailsTVCell Delegate Methods

-(void)playVideoButtonTapped:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    [self playButtonPressed:postNew.videoUrl];
}

- (void)didTapCommentsButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:postNew.postId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.topics = [[NSMutableArray alloc] initWithArray:topics];
            ECTopic *topic = [self.topics objectAtIndex:1];
            DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
            dcChat.dcPost = postNew;
            dcChat.isPost = true;
            dcChat.selectedTopic = topic;
            dcChat.topicId = topic.topicId;
            [self.navigationController pushViewController:dcChat animated:NO];
        }
    }];
}

- (void)didTapFavoriteButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
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
    vc.mFeedItemId = postNew.postId;
    [self addChildViewController:vc];
    vc.view.frame = self.view.frame;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    /*
    DCPlaylistsTableViewController *dcPlaylistsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTVC.isFeedMode = true;
    dcPlaylistsTVC.isSignedInUser = true;
    dcPlaylistsTVC.feedItemId = postNew.postId;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTVC];
    [self presentViewController:navigationController animated:YES completion:nil];
     */
}

- (void)didTapAttendanceButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postItem = [self.userPostArray objectAtIndex:index - 1];
    if (postItem.postId != nil){
        [self setUserAttendanceResponse:postItem.postId];
    }
    
    /*
    DCPost *postNew = [self.userPostArray objectAtIndex:index - 1];
    ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
    ecAttendanceDetailsViewController.selectedPostItem = postNew;
    ecAttendanceDetailsViewController.isPost = true;
    [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
     */
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

#pragma mark:- API Call Methods

-(void)setUserAttendanceResponse:(NSString *)strFeedId{
    NSString *userResponse = @"Going";
    
    [[ECAPI sharedManager] setAttendeeResponse:self.signedInUser.userId feedItemId:strFeedId response:userResponse callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
        } else {
            [self updateUserProfile];
        }
    }];
}

-(void)updateUserProfile{
    [[ECAPI sharedManager] updateProfilePicUrl:self.signedInUser.userId profilePicUrl:self.signedInUser.profilePicUrl callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error update user profile: %@", error);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableView" object:nil];
        }
    }];
}

#pragma mark:- Action on video tap Methods

-(void)playButtonPressed:(NSString *)videoURLStr {
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

-(void)showProfilePicImage:(ECNewUserProfileViewController *)vc ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        self.userProfileImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.userProfileImageView.image = image;
        
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
                                    self.userProfileImageView.image = image;
                                    //API Call
                                    [[ECAPI sharedManager] updateProfilePicUrl:self.mSelectedECUser.userId profilePicUrl:imageURL callback:^(NSError *error) {
                                        if (error) {
                                            NSLog(@"Error update user profile: %@", error);
                                        } else {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableView" object:nil];
                                        }
                                    }];
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
    NSLog(@"FB: didCompleteWithResults=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: didFailWithError=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: sharerDidCancel=%@\n",[sharer debugDescription]);
}

@end
