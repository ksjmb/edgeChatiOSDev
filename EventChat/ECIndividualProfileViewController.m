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
#import "ECIndividualProfileTableViewCell.h"
#import <Social/Social.h>
#import "SVProgressHUD.h"
#import "ECAPINames.h"
#import "ECCommonClass.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ECFullScreenImageViewController.h"
#import "ECNewPlaylistTableViewController.h"

@interface ECIndividualProfileViewController ()
@property (nonatomic, strong) NSArray *mFollowingUsersArr;
@property (nonatomic, strong) NSArray *mFollowerUsersArr;
@property (nonatomic, strong) NSMutableArray *userPostArr;
@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) NSMutableArray *filterResultArray;
@property (nonatomic, assign) BOOL isFiltered;
@property (nonatomic, assign) BOOL isFollowTab;

@property (nonatomic, strong) FBSDKShareDialog *mShareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *mFBContent;
@property (nonatomic, strong) NSMutableArray *mTopicsArr;
@property (strong, nonatomic) ECFullScreenImageViewController *fullScreenImgVC;
@property (nonatomic, assign) BOOL isLoginUser;

@end

@implementation ECIndividualProfileViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.loginUserIdStr = self.signedInUser.userId;
    self.title = @"Profile";
    [self initialSetup];
    [self getAllUserList];
}

- (void)viewWillAppear:(BOOL)animated{
//    [self updateTableView];
//    [self updateUserProfile];
//    [self initialSetup];
    [self updateUser];
}

#pragma mark - SearchBar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.mSearchResultTableView setHidden:false];
    if (searchText.length == 0) {
        /*
        self.isFiltered = false;
        [self.mSearchBar endEditing:YES];
        [self.mSearchResultTableView setHidden:true];
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
    [self.mSearchResultTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.mSearchResultTableView setHidden:true];
    [self.mSearchBar endEditing:YES];
    self.mSearchBar.text = @"";
    self.searchBarHeightConst.constant = 0.0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.mSearchBar endEditing:YES];
}

#pragma mark - UITableView DataSource and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mSearchResultTableView){
        return [self.filterResultArray count];
    }else{
        return 1 + [self.userPostArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.mSearchResultTableView){
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
            //        [mCell configureSocialCell:self.signedInUser :self.signedInUser];
            [mCell configureSocialCell:self.selectedEcUser :self.signedInUser];
            return mCell;
        }else{
            static NSString *CellIdentifierNew = @"DCInfluencersPersonDetailsTableViewCell";
            DCInfluencersPersonDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
            DCPost *post = [self.userPostArr objectAtIndex:indexPath.row - 1];
            //        DCPost *post_new = [self.resultArray objectAtIndex:indexPath.row - 1];
            if (!cell) {
                cell = [[DCInfluencersPersonDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierNew];
            }
            
            cell.dcPersonDelegate = self;
            //        [cell configureWithPost:post signedInUser:self.signedInUser];
//            [cell configureWithPost:post signedInUser:self.selectedEcUser];
            [cell configureWithUserProfilePost:post signedInUser:self.selectedEcUser];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.mSearchResultTableView){
        NSArray *mUser = [self.filterResultArray objectAtIndex:indexPath.row];
        
        NSError *infoError = nil;
        self.selectedEcUser = [[ECUser alloc] initWithDictionary:[self.filterResultArray objectAtIndex:indexPath.row] error:&infoError];
        
        self.selectedEcUser.userId = [mUser valueForKey:@"_id"];
        self.selectedEcUser.profilePicUrl = [mUser valueForKey:@"profilePicUrl"];
        self.selectedEcUser.firstName = [mUser valueForKey:@"firstName"];
        self.selectedEcUser.lastName = [mUser valueForKey:@"lastName"];
        /*
        self.selectedEcUser.followeeIds = [mUser valueForKey:@"followeeIds"];
        self.selectedEcUser.followerIds = [mUser valueForKey:@"followerIds"];
        self.selectedEcUser.favoriteCount = [[mUser valueForKey:@"favoriteCount"] intValue];
        */
        
        [self.mSearchResultTableView setHidden:true];
        [self.mSearchBar endEditing:YES];
        self.mSearchBar.text = @"";
        self.isFollowTab = false;
//        [self initialSetup];
//        [self updateTableView];
        [self reloadUI];
        
    }else{
        if (indexPath.row != 0){
            DCPost *mDCPost = [self.userPostArr objectAtIndex:indexPath.row - 1];
            if ([mDCPost.postType  isEqual: @"image"]){
                if (mDCPost.imageUrl != nil){
                    self.fullScreenImgVC = [[ECFullScreenImageViewController alloc] initWithNibName:@"ECFullScreenImageViewController" bundle:nil];
                    self.fullScreenImgVC.imagePath = mDCPost.imageUrl;
                    [self presentViewController:self.fullScreenImgVC animated:YES completion:nil];
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
    if (tableView == self.mSearchResultTableView){
        return 60.0;
    }else{
        if (indexPath.row == 0){
            return 50.0;
        }else{
            return UITableViewAutomaticDimension;
        }
    }
}

#pragma mark - Instance Methods

- (void)initialSetup{
    if ([self.loginUserIdStr isEqualToString:self.selectedEcUser.userId]){
        [self.mFollowBtn setHidden:true];
        self.isLoginUser = true;
    }else{
        [self.mFollowBtn setHidden:false];
        self.isLoginUser = false;
    }
    
    if (!self.isFollowTab){
        if([self.signedInUser.followeeIds containsObject:self.selectedEcUser.userId]){
            [self.mFollowBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
        else{
            [self.mFollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"updateTableView" object:nil];
    
//    self.mSearchBar.showsCancelButton = true;
    self.mSearchBar.delegate = self;
    
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
    
    if (self.selectedEcUser.profilePicUrl != nil && ![self.selectedEcUser.profilePicUrl  isEqual: @""]){
        [self showProfilePicImage:self ForImageUrl:self.selectedEcUser.profilePicUrl];
    }else{
        [self.mUserProfileIV setImage:[UIImage imageNamed:@"missing-profile.png"]];
    }
    
    if (self.selectedEcUser.coverPic_Url != nil && ![self.selectedEcUser.coverPic_Url  isEqual: @""]){
        [self showImageOnTheCell:self ForImageUrl:self.selectedEcUser.coverPic_Url];
    }else{
        [self.mBackgroundIV setImage:[UIImage imageNamed:@"cover_slide"]];
    }
    
    self.mTableView.estimatedRowHeight = 240.0;
    self.mTableView.rowHeight = UITableViewAutomaticDimension;
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mSearchResultTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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

-(void)reloadUI{
    [self initialSetup];
    [self updateUser];
}

#pragma mark - Post Notification Methods

-(void)reloadTableView {
    self.selectedEcUser = [[ECAPI sharedManager] signedInUser];
    [self.mTableView reloadData];
    [self updateUserProfile:self.signedInUser];
}

#pragma mark - AddToPlaylist Delegate Methods

- (void)updateUI{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - DCInfluencersPerson DetailsTVCell Delegate Methods

- (void)didTapShareButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index {
    DCPost *postNew = [self.userPostArr objectAtIndex:index - 1];
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
                                         self.mShareDialog = [[FBSDKShareDialog alloc] init];
                                         self.mFBContent = [[FBSDKShareLinkContent alloc] init];
                                         self.mFBContent.contentURL = [NSURL URLWithString:link];
                                         self.mFBContent.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                         self.mFBContent.contentDescription = postNew.content;
                                         
                                         if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
                                             [self.mShareDialog setMode:FBSDKShareDialogModeNative];
                                         }
                                         else {
                                             [self.mShareDialog setMode:FBSDKShareDialogModeAutomatic];
                                         }
                                         //[self.shareDialog setMode:FBSDKShareDialogModeShareSheet];
                                         [self.mShareDialog setShareContent:self.mFBContent];
                                         [self.mShareDialog setFromViewController:self];
                                         [self.mShareDialog setDelegate:self];
                                         [self.mShareDialog show];
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

- (void)didTapCommentsButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArr objectAtIndex:index - 1];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:postNew.postId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.mTopicsArr = [[NSMutableArray alloc] initWithArray:topics];
            ECTopic *topic = [self.mTopicsArr objectAtIndex:1];
            DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
            dcChat.dcPost = postNew;
            dcChat.isPost = true;
            dcChat.selectedTopic = topic;
            dcChat.topicId = topic.topicId;
            [self.navigationController pushViewController:dcChat animated:NO];
        }
    }];
}

- (void)didTapAttendanceButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postItem = [self.userPostArr objectAtIndex:index - 1];
    if (postItem.postId != nil){
        [self setUserAttendanceResponse:postItem.postId];
    }
}

- (void)didTapFavoriteButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArr objectAtIndex:index - 1];
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
    vc.isComeFromProfileVC = true;
    vc.signedInUser = self.selectedEcUser;
    [self addChildViewController:vc];
    vc.view.frame = self.view.frame;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

-(void)playVideoButtonTapped:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    DCPost *postNew = [self.userPostArr objectAtIndex:index - 1];
    [self playButtonPressed:postNew.videoUrl];
}

#pragma mark - API Call Methods

- (void)getAllUserList{
    [[ECAPI sharedManager] getAllUserListAPI:^(NSArray *searchResult, NSError *error) {
        if (error) {
            NSLog(@"Error getAllUserList: %@", error);
        } else {
            self.resultArray = [[NSMutableArray alloc] initWithArray:searchResult];
            [self.mSearchResultTableView reloadData];
        }
    }];
}

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
            [[ECAPI sharedManager] updateProfilePicUrl:self.selectedEcUser.userId profilePicUrl:self.selectedEcUser.profilePicUrl callback:^(NSError *error) {
                if (error) {
                    NSLog(@"Error update user profile: %@", error);
                } else {
                    [self reloadTableView];
                }
            }];
        }
    }];
}

-(void)updateUserProfile:(ECUser *)mUser{
    [[ECAPI sharedManager] updateProfilePicUrl:mUser.userId profilePicUrl:mUser.profilePicUrl callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error update user profile: %@", error);
        } else {
            self.signedInUser = [[ECAPI sharedManager] signedInUser];
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
            [self reloadUI];
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
            [self reloadUI];
        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)actionOnFollowButton:(id)sender {
    self.isFollowTab = true;
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
    ecFollowViewController.mSelectedLoginUserId = self.selectedEcUser.userId;
    ecFollowViewController.isComeFromProfile = true;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnTwtBtn:(id)sender {
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    ecFollowViewController.usersArray = self.mFollowerUsersArr;
    ecFollowViewController.dcUser = self.selectedEcUser;
    ecFollowViewController.mSelectedLoginUserId = self.selectedEcUser.userId;
    ecFollowViewController.isComeFromProfile = true;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)actionOnInstaBtn:(id)sender {
    ECNewPlaylistTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECNewPlaylistTableViewController"];
    vc.isFeedMode = false;
    vc.isSignedInUser = self.isLoginUser;
    vc.profileUser = self.selectedEcUser;
    [self.navigationController pushViewController:vc animated:YES];
    
    /*
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = false;
    dcPlaylistsTableViewController.isSignedInUser = self.isSignedInUser;
    dcPlaylistsTableViewController.signedInUser = self.signedInUser;
    dcPlaylistsTableViewController.profileUser = self.selectedEcUser;
    [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
    */
}

- (IBAction)actionOnSearchBtnClick:(id)sender {
    self.searchBarHeightConst.constant = 40.0;
    //If you want to enable cancel button always.
    [[self.mSearchBar valueForKey:@"_cancelButton"] setEnabled:YES];
    
    [self.mSearchResultTableView setHidden:false];
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
    [self.mSearchResultTableView reloadData];
}

#pragma mark - Handling background Image upload

- (void) beginBackgroundUpdateTask {
    self.bkUptTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.bkUptTaskId];
    self.bkUptTaskId = UIBackgroundTaskInvalid;
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

#pragma mark - Action on video tap

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

#pragma mark - Twitter Methods

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
