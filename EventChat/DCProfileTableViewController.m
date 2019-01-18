//
//  DCProfileTableViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCProfileTableViewController.h"
#import "ECAPI.h"
#import "ECUser.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NSObject+TypeValidation.h"
#import "ECFacebookUserData.h"
#import "ECColor.h"
#import "DCWhatsOnYourMindTextCell.h"
#import "DCFollowFavoriteButtonCell.h"
#import "ECProfileCell.h"
#import "ECFollowViewController.h"
#import "ECFavoritesViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "IonIcons.h"
#import "DCNewPostViewController.h"
#import "DCUserListTableViewController.h"
#import "FCAlertView.h"
#import "DCUserPostCell.h"
#import "DCPlaylistsTableViewController.h"
#import "DCPost.h"
#import "ECEventTopicCommentsViewController.h"

@interface DCProfileTableViewController ()
@property (nonatomic, strong) UIBarButtonItem *searchBarButtonItem;
@end

@implementation DCProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Profile"];
    self.tableView.estimatedRowHeight = 50;
    
    _selectedSegment = 0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    if(self.isSignedInUser){
        self.searchBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_search_strong  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSearchUsers:)];
        [self.navigationItem setRightBarButtonItem:self.searchBarButtonItem];
    }
    else{
    }
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    [self.givenName setText:[NSString stringWithFormat:@"%@ %@", self.profileUser.firstName, self.profileUser.lastName]];
    // Apply round mask
    self.profilePic.layer.cornerRadius = 6.0f;
    self.profilePic.layer.borderWidth = 2.0f;
    self.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    //    self.profilePicImageView.image = [UIImage imageNamed:@"missing-profile.png"];
    self.profilePic.layer.masksToBounds = YES;
    
    
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
                [self.profilePic setImage:image];
                
                //Update profilePicUrl in User Collection
                if(self.isSignedInUser){
                    NSLog(@"ProfilePicUrl: %@", fbUserData.url);
                    [[ECAPI sharedManager] updateProfilePicUrl:self.profileUser.userId profilePicUrl:fbUserData.url callback:^(NSError *error) {
                        if (error) {
                            NSLog(@"Error adding user: %@", error);
                            NSLog(@"%@", error);
                        } else {
                            // code
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
        [self.profilePic setImage:image];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    if(_selectedSegment == 0){
        [self loadUserPosts];
    }
    else{
        [self loadOtherUserPosts];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    //Sync user to DB
    [[ECAPI sharedManager] updateUser:self.signedInUser callback:^(ECUser *ecUser, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        }
        //self.signedInUser = ecUser;
    }];
}

- (IBAction)didTapSearchUsers:(id)sender{
    DCUserListTableViewController *dcUserListTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCUserListTableViewController"];
    
    [self.navigationController pushViewController:dcUserListTableViewController animated:YES];
}

- (IBAction)didTapTogglePosts:(id)sender{
    UISegmentedControl *toggle = (UISegmentedControl *)sender;
    _selectedSegment = (int)toggle.selectedSegmentIndex;
    if(toggle.selectedSegmentIndex == 0){
        [self loadUserPosts];
    }
    else{
        [self loadOtherUserPosts];
    }
}

#pragma mark - API calls
- (void)loadUserPosts{
    [[ECAPI sharedManager] getPostByUserId:self.profileUser.userId callback:^(NSArray *posts, NSError *error) {
        if (error) {
            NSLog(@"Error getting posts for user: %@", error);
            NSLog(@"%@", error);
        } else {
            _userPostsArray = [[NSMutableArray alloc] initWithArray:posts];
            [_userPostsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
            [self.tableView reloadData];
        }
    }];
}

- (void)loadOtherUserPosts{
    [[ECAPI sharedManager] getOthersPostByUserId:self.profileUser.userId callback:^(NSArray *posts, NSError *error) {
        if (error) {
            NSLog(@"Error getting posts for user: %@", error);
            NSLog(@"%@", error);
        } else {
            _userPostsArray = [[NSMutableArray alloc] initWithArray:posts];
            [_userPostsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Follow/Favorite actions
- (IBAction)didTapShowFollowers:(id)sender{
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    //ecFollowViewController.usersArray = self.followerUsersArray;
    
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)didTapShowFollowing:(id)sender{
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = true;
    //ecFollowViewController.usersArray = self.followingUsersArray;
    
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (void)didTapShowPlaylists{
    ECFavoritesViewController *ecFavoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFavoritesViewController"];
    ecFavoritesViewController.isSignedInUser = self.isSignedInUser;
    ecFavoritesViewController.profileUser = self.profileUser;
    [self.navigationController pushViewController:ecFavoritesViewController animated:YES];
}

#pragma mark - Table view data source
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.row == 1){
//        return UITableViewAutomaticDimension;
//    }
//    else{
//        return 50.0;
//    }
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(self.isSignedInUser){
            if (indexPath.row == 1){
                return 0;
            }
            else{
                return UITableViewAutomaticDimension;
            }
        }
        else{
            if (indexPath.row == 0){
                return 0;
            }
            else{
                return UITableViewAutomaticDimension;
            }
        }
    }
    else{
        return UITableViewAutomaticDimension;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 1){
        return @" ";
    }
    else{
        return @"";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = tableView.frame;
    if(section == 1){
        UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"You",@"Friends"]];
        segmentControl.frame = CGRectMake((frame.size.width - 120) / 2, 10, 120, 30);
        [segmentControl addTarget:self action:@selector(didTapTogglePosts:) forControlEvents:UIControlEventValueChanged];
        [segmentControl setSelectedSegmentIndex:_selectedSegment];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40.0)];
        [headerView setBackgroundColor:[ECColor colorFromHexString:@"#d7d9dc"]];
        [headerView addSubview:segmentControl];
        
        return headerView;
    }
    else{
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        
        return headerView;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1){
        return 50.0;
    }
    else{
        return 0.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 1){
        return [_userPostsArray count];
    }
    else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            static NSString *CellIdentifier = @"DCCommentOrPostCell";
            DCCommentOrPostCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            // Configure the cell...
            cell.delegate = self;
            [cell configureWithUser:self.profileUser isSignedInUser:self.isSignedInUser];
            return cell;
        }
        else if(indexPath.row == 1){
            static NSString *CellIdentifier = @"DCFollowOrMessageCell";
            DCFollowOrMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            // Configure the cell...
            cell.delegate = self;
            [cell configureWithUser:self.profileUser signedInUser:self.signedInUser isSignedInUser:self.isSignedInUser];
            return cell;
        }
        else{
            static NSString *CellIdentifier = @"DCFollowFavoriteButtonCell";
            DCFollowFavoriteButtonCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            // Configure the cell...
            [cell configureWithUser:self.profileUser signedInUser:self.signedInUser isSignedInUser:self.isSignedInUser];
            return cell;
        }
        
    }
    else{
        static NSString *cellIdentifier = @"DCUserPostCell";
        DCUserPostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        DCPost *post = [_userPostsArray objectAtIndex:indexPath.row];
        if (!cell) {
            cell = [[DCUserPostCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        [cell configureWithPost:post signedInUser:self.signedInUser selectedSegment:_selectedSegment];
        
        return cell;
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if(indexPath.section > 0){
        if(_selectedSegment == 0){
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return YES;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section > 0){
        if(_selectedSegment == 0){
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                // Delete the row from the data source
                DCPost *post = [_userPostsArray objectAtIndex:indexPath.row];
                [[ECAPI sharedManager] deletePostById:post.postId callback:^(NSArray *posts, NSError *error) {
                    if (error) {
                        NSLog(@"Error adding user: %@", error);
                        NSLog(@"%@", error);
                    } else {
                        [_userPostsArray removeObjectAtIndex:indexPath.row];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        _userPostsArray = [[NSMutableArray alloc] initWithArray:posts];
                        [_userPostsArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
                        [self.tableView reloadData];
                    }
                }];
                
            } else if (editingStyle == UITableViewCellEditingStyleInsert) {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
    }
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - DCCommentOrPostCellDelegate methods
- (void)didTapPostButton{
    DCNewPostViewController *dcNewPostViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCNewPostViewController"];
    dcNewPostViewController.delegate = self;
//    UINavigationController *navigationController =
//    [[UINavigationController alloc] initWithRootViewController:dcNewPostViewController];
//    [self presentViewController:navigationController animated:YES completion:nil];
    [self.navigationController pushViewController:dcNewPostViewController animated:true];
}

- (void)didTapCommentsButton{
    
}

#pragma mark - DCFollowOrMessageCellDelegate methods
- (void)didTapFollowUnfollowButton{
    if([self.signedInUser.followeeIds containsObject:self.profileUser.userId]){
        [[ECAPI sharedManager] unfollowUserByUserId:self.signedInUser.userId followeeId:self.profileUser.userId callback:^(NSError *error) {
            if (error) {
                NSLog(@"Error adding user: %@", error);
                NSLog(@"%@", error);
            } else {
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:[NSString stringWithFormat:@"You have stopped following %@ %@.", self.profileUser.firstName, self.profileUser.lastName]
                       withCustomImage:nil
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }];
    }
    else{
        [[ECAPI sharedManager] followUserByUserId:self.signedInUser.userId followeeId:self.profileUser.userId callback:^(NSError *error) {
            if (error) {
                NSLog(@"Error adding user: %@", error);
                NSLog(@"%@", error);
            } else {
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:[NSString stringWithFormat:@"You have just started following %@ %@.", self.profileUser.firstName, self.profileUser.lastName]
                       withCustomImage:nil
                   withDoneButtonTitle:nil
                            andButtons:nil];
            }
        }];
    }
}

-(void)didTapMessageButton{
    
}

#pragma mark - DCFollowFavoriteButtonCellDelegate methods
- (IBAction)didTapViewFollowing:(id)sender{
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = true;
    ecFollowViewController.usersArray = self.followingUsersArray;
    ecFollowViewController.dcUser = self.profileUser;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)didTapViewFollowers:(id)sender{
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    ecFollowViewController.usersArray = self.followerUsersArray;
    ecFollowViewController.dcUser = self.profileUser;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)didTapViewFavorites:(id)sender{
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = false;
    dcPlaylistsTableViewController.isSignedInUser = _isSignedInUser;
    dcPlaylistsTableViewController.signedInUser = _signedInUser;
    dcPlaylistsTableViewController.profileUser = _profileUser;
    [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
}

#pragma mark - DCNewPostViewControllerDelegate methods
- (void)refreshPostStream{
    _selectedSegment = 0;
    [self loadUserPosts];
}

#pragma mark - DCUserPostCellDelegate methods
- (void)didTapLikeButton:(NSIndexPath *)indexPath{
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}
- (void)didTapCommentButton:(DCPost *)dcPost{
    // Push to comments view controller directly
    ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
    ecEventTopicCommentsViewController.isPost = true;
    ecEventTopicCommentsViewController.dcPost = dcPost;
    
    [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
}
- (void)didTapFavoriteButton:(NSIndexPath *)indexPath{
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}
@end
