//
//  DCEventTableViewController.m
//  EventChat
//
//  Created by Jigish Belani on 2/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCEventTableViewController.h"
#import "DCEventTableViewCell.h"
#import "ECAPI.h"
#import "DCFeedItemFilter.h"
#import "SVProgressHUD.h"
#import "DCFeedItem.h"
#import "ECEventTopicCommentsViewController.h"
#import "DCPlaylistsTableViewController.h"
#import "ECAttendanceDetailsViewController.h"
#import "SignUpLoginViewController.h"
#import "ECCommonClass.h"

@interface DCEventTableViewController ()
@property (nonatomic, strong) DCFeedItemFilter *currentFilter;
@property (nonatomic, strong) NSArray *feedItemFilters;
@property (nonatomic, strong) NSMutableArray *feedItemsArray;
@property (nonatomic, assign) NSString *userEmail;
@end

@implementation DCEventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //@kj_new_change
    /*
    [[ECAPI sharedManager] getFeedItemFilters:^(NSArray *results, NSError *error){
        self.feedItemFilters = [[NSMutableArray alloc] initWithArray:results];
        
        for(int x=0; x < [_feedItemFilters count]; x++){
            DCFeedItemFilter *feedItemFilter = _feedItemFilters[x];
            if([feedItemFilter.name isEqual:@"Event"]){
                _currentFilter = feedItemFilter;
            }
        }
        
        [self loadFeedItemsByFilter:_currentFilter];
    }];
     */
    
//    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInUserEmail"];
//    
//    if (_userEmail != nil && ![_userEmail isEqualToString:@""]){
//        [[ECAPI sharedManager] getFeedItemFilters:^(NSArray *results, NSError *error){
//            self.feedItemFilters = [[NSMutableArray alloc] initWithArray:results];
//            
//            for(int x=0; x < [_feedItemFilters count]; x++){
//                DCFeedItemFilter *feedItemFilter = _feedItemFilters[x];
//                if([feedItemFilter.name isEqual:@"Event"]){
//                    _currentFilter = feedItemFilter;
//                }
//            }
//            
//            [self loadFeedItemsByFilter:_currentFilter];
//        }];
//    }else{
//        ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
//        sharedInstance.isUserLogoutTap = true;
//        UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
//        SignUpLoginViewController *signUpVC = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
//        signUpVC.hidesBottomBarWhenPushed = YES;
//        signUpVC.storyboardIdentifierString = @"DCEventTableViewController";
//        [self.navigationController pushViewController:signUpVC animated:true];
//    }
}

- (void)viewWillAppear:(BOOL)animated{
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInUserEmail"];

    if (_userEmail != nil && ![_userEmail isEqualToString:@""]){
        [[ECAPI sharedManager] getFeedItemFilters:^(NSArray *results, NSError *error){
            self.feedItemFilters = [[NSMutableArray alloc] initWithArray:results];

            for(int x=0; x < [_feedItemFilters count]; x++){
                DCFeedItemFilter *feedItemFilter = _feedItemFilters[x];
                if([feedItemFilter.name isEqual:@"Event"]){
                    _currentFilter = feedItemFilter;
                }
            }

            [self loadFeedItemsByFilter:_currentFilter];
        }];
    }else{
        ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
        sharedInstance.isUserLogoutTap = true;
        
        if (sharedInstance.isFromMore == false){
            sharedInstance.isFromMore = true;
            UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
            SignUpLoginViewController *signUpVC = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
            signUpVC.hidesBottomBarWhenPushed = YES;
            //signUpVC.storyboardIdentifierString = @"DCEventTableViewController";
            [self.navigationController pushViewController:signUpVC animated:true];
        }
    }
}

- (void)loadFeedItemsByFilter:(DCFeedItemFilter *)feedItemFilter{
    [[ECAPI sharedManager] filterFeedItemsByFilterObject:feedItemFilter callback:^(NSArray *searchResult, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        }
        else{
            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    static NSString *cellIdentifier = @"DCEventTableViewCell";
    DCEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DCFeedItem *feedItem = [_feedItemsArray objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[DCEventTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    [cell configureWithFeedItem:feedItem];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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

#pragma mark - DCEventTableViewCell Delegate methods
- (void)eventFeedDidTapFeedITemThumbnail:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
}

- (void)eventFeedDidTapCommentsButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    NSLog(@"%@", dcEventTableViewCell.feedItem.feedItemId);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:dcEventTableViewCell.feedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            
            // Push to comments view controller directly
            ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
            ECTopic *topic = [topics objectAtIndex:1];
            ecEventTopicCommentsViewController.selectedFeedItem = dcEventTableViewCell.feedItem;
            ecEventTopicCommentsViewController.selectedTopic = topic;
            ecEventTopicCommentsViewController.topicId = topic.topicId;
            
            [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
        }
    }];
}

- (void)eventFeedDidTapFavoriteButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = true;
    dcPlaylistsTableViewController.isSignedInUser = true;
    dcPlaylistsTableViewController.feedItemId = dcEventTableViewCell.feedItem.feedItemId;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)eventFeedDidTapAttendanceButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
    ecAttendanceDetailsViewController.selectedFeedItem = dcEventTableViewCell.feedItem;
    
    [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
}

- (void)eventFeedDidTapShareButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
}

@end
