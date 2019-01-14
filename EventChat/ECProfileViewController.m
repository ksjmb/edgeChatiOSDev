#import "ECProfileViewController.h"
#import "ECAPI.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NSObject+TypeValidation.h"
#import "ECFacebookUserData.h"
#import "ECColor.h"
#import "ECProfileCell.h"
#import "NSDate+NVTimeAgo.h"
#import "ECUserListCell.h"
#import "ECUser.h"
#import "ECFollowViewController.h"
#import "ECFavoritesViewController.h"

@interface ECProfileViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *profilePic;
@property (nonatomic, weak) IBOutlet UILabel *givenName;
@property (nonatomic, weak) IBOutlet UITableView *profileDetailTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *userSearchBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelSearchButton;
@property (nonatomic, weak) IBOutlet UIView *userListView;
@property (nonatomic, weak) IBOutlet UITableView *userListTableView;
@property (nonatomic, strong) NSArray *usersArray;
@property (nonatomic, weak) IBOutlet UIButton *followingButton;
@property (nonatomic, weak) IBOutlet UIButton *followerButton;
@property (nonatomic, weak) IBOutlet UIButton *favoritesButton;
@property (nonatomic, weak) IBOutlet UIView *searchBarView;
@property (nonatomic, strong) NSArray *followingUsersArray;
@property (nonatomic, strong) NSArray *followerUsersArray;
@property (nonatomic, weak) IBOutlet UIView *followButtonContainer;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

@end

@implementation ECProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    if(self.isSignedInUser){
        [self.searchBarView setHidden:NO];
    }
    else{
        [self.searchBarView setHidden:YES];
        [self.navigationItem setTitle:@"Profile"];
        [self.followButtonContainer setHidden:NO];
        if([self.signedInUser.followeeIds containsObject:self.profileUser.userId]){
            [self.followButton setTitle:@"- Unfollow" forState:UIControlStateNormal];
        }
        else{
            [self.followButton setTitle:@"+ Follow" forState:UIControlStateNormal];
        }
    }
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.cancelSearchButton setTitle:@""];
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
                        } else {
                            // code
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

- (void)viewDidAppear:(BOOL)animated{
//    [self loadFollowing];
//    [self loadFollowers];
//    [self loadFavorites];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserProfileData{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView.tag == 1){
        return 4;
    }
    else{
        return [self.usersArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag == 1){
        static NSString *cellIdentifier = @"ECProfileCell";
        ECProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[ECProfileCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        if(indexPath.row == 0){
            [cell configureWithData:@"Email" value:self.profileUser.email];
        }
        else if(indexPath.row == 1){
            [cell configureWithData:@"Status" value:self.profileUser.status];
        }
        else if(indexPath.row == 2){
            [cell configureWithData:@"Social Connect" value:self.profileUser.socialConnect];
        }
        else{
            // Format date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSDate *created_atFromString = [[NSDate alloc] init];
            created_atFromString = [dateFormatter dateFromString:self.profileUser.created_at];
            NSString *ago = [created_atFromString formattedAsTimeAgo];
            NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
            NSLog(@"Output is: \"%@\"", ago);
            NSLog(@"Output is: \"%@\"", [dateFormatter2 stringFromDate:created_atFromString]);
            [cell configureWithData:@"Joined On" value:ago];
        }
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"ECUserListCell";
        ECUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSError *infoError = nil;
        ECUser *ecUser = [[ECUser alloc] initWithDictionary:[self.usersArray objectAtIndex:indexPath.row] error:&infoError];
        if (!cell) {
            cell = [[ECUserListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        [cell configureWithUser:ecUser];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag == 2){
        NSError *infoError = nil;
        ECUser *ecUser = [[ECUser alloc] initWithDictionary:[self.usersArray objectAtIndex:indexPath.row] error:&infoError];
        ECProfileViewController *ecProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECProfileViewController"];
        ecProfileViewController.isSignedInUser = false;
        ecProfileViewController.profileUser = ecUser;
        
        [self.navigationController pushViewController:ecProfileViewController animated:YES];
        [self didTapCancelSearch:nil];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
     [self.cancelSearchButton setTitle:@""];
    [self.userListView setHidden:YES];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar {
    [[ECAPI sharedManager] getAllUsers:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // code
            [self.userListView setHidden:NO];
            NSLog(@"%@", users);
            self.usersArray = [[NSArray alloc] initWithArray:users];
            NSLog(@"self.usersArray count: %d", (int)[self.usersArray count]);
            [self.userListTableView reloadData];
            [self.cancelSearchButton setTitle:@"Cancel"];
        }
    }];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
     [self.cancelSearchButton setTitle:@""];
    [self.userListView setHidden:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        [searchBar resignFirstResponder];
    }
}

- (IBAction)didTapCancelSearch:(id)sender{
     [self.cancelSearchButton setTitle:@""];
    [self.userListView setHidden:YES];
    [self.userSearchBar resignFirstResponder];
}

- (IBAction)didTapShowFollowers:(id)sender{
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = false;
    ecFollowViewController.usersArray = self.followerUsersArray;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)didTapShowFollowing:(id)sender{
    ECFollowViewController *ecFollowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFollowViewController"];
    ecFollowViewController.showFollowing = true;
    ecFollowViewController.usersArray = self.followingUsersArray;
    [self.navigationController pushViewController:ecFollowViewController animated:YES];
}

- (IBAction)didTapShowFavorites:(id)sender{
    ECFavoritesViewController *ecFavoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFavoritesViewController"];
    ecFavoritesViewController.isSignedInUser = self.isSignedInUser;
    ecFavoritesViewController.profileUser = self.profileUser;
    [self.navigationController pushViewController:ecFavoritesViewController animated:YES];
}

- (IBAction)didTapFollowUnfollowUser:(id)sender{
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
                [self.followButton setTitle:@"+ Follow" forState:UIControlStateNormal];
            }
        }];
    }
    else{
        [[ECAPI sharedManager] followUserByUserId:self.signedInUser.userId followeeId:self.profileUser.userId callback:^(NSError *error) {
            if (error) {
                NSLog(@"Error adding user: %@", error);
                NSLog(@"%@", error);
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"New Follow"
                                          message:[NSString stringWithFormat:@"You have just started following %@ %@.", self.profileUser.firstName, self.profileUser.lastName]
                                          delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
                [alertView show];
                [self.followButton setTitle:@"- Unfollow" forState:UIControlStateNormal];
            }
        }];
    }
}

- (UIColor *)colorWithDecimalRed:(float)red green:(float)green blue:(float)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

#pragma mark - API Delegate
- (void)loadFollowing{
    [[ECAPI sharedManager] getFollowing:self.profileUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            // code
            NSLog(@"%@", users);
            self.followingUsersArray = [[NSArray alloc] initWithArray:users];
            NSString *followingCount = [NSString stringWithFormat:@"%lu", [self.followingUsersArray count]];
            // Setup the string
            NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWING", followingCount]];
            [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followingCount length])];
            [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecMagentaColor] range:NSMakeRange(0, [followingCount length])];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followingCount length])];
            
            // Normal font for the rest of the text
            [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followingCount length], 10)];
            [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followingCount length], 10)];
            [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followingCount length], 10)];
            [self.followingButton setAttributedTitle:titleText forState:UIControlStateNormal];
        }
    }];
}

- (void)loadFollowers{
    [[ECAPI sharedManager] getFollowers:self.profileUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            // code
            NSLog(@"%@", users);
            self.followerUsersArray = [[NSArray alloc] initWithArray:users];
            NSString *followersCount = [NSString stringWithFormat:@"%lu", [self.followerUsersArray count]];
            // Setup the string
            NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWERS", followersCount]];
            [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followersCount length])];
            [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecMagentaColor] range:NSMakeRange(0, [followersCount length])];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followersCount length])];
            
            // Normal font for the rest of the text
            [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followersCount length], 10)];
            [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followersCount length], 10)];
            [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followersCount length], 10)];
            [self.followerButton setAttributedTitle:titleText forState:UIControlStateNormal];
        }
    }];
}

- (void)loadFavorites{
    NSString *favoritesCount;
    if(self.isSignedInUser){
        favoritesCount = [NSString stringWithFormat:@"%d", self.signedInUser.favoriteCount];
    }
    else{
        favoritesCount = [NSString stringWithFormat:@"%d", self.profileUser.favoriteCount];
    }
    
    // Setup the string
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFAVORITES", favoritesCount]];
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [favoritesCount length])];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecMagentaColor] range:NSMakeRange(0, [favoritesCount length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [favoritesCount length])];
    
    // Normal font for the rest of the text
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([favoritesCount length], 10)];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([favoritesCount length], 10)];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([favoritesCount length], 10)];
    [self.favoritesButton setAttributedTitle:titleText forState:UIControlStateNormal];
}

@end
