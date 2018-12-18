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
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) DCFeedItemFilter *currentFilter;
@property (nonatomic, strong) NSArray *feedItemFilters;
@property (nonatomic, strong) NSMutableArray *feedItemsArray;
@property (nonatomic, assign) NSString *mUserEmail;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@end

@implementation DCEventTableViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.estimatedRowHeight = 70;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.mUserEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInUserEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];

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
}

#pragma mark:- Instance Methods

- (void)loadFeedItemsByFilter:(DCFeedItemFilter *)feedItemFilter{
    [[ECAPI sharedManager] filterFeedItemsByFilterObject:feedItemFilter callback:^(NSArray *searchResult, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        }
        else{
            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DCEventTableViewCell";
    DCEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DCFeedItem *feedItem = [_feedItemsArray objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[DCEventTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    int commentCount = 0;
    BOOL isFavorited = false;
    BOOL isAttending = false;
    
    commentCount = [feedItem.commentCount intValue];
    
    if([self.signedInUser.favoritedFeedItemIds containsObject:feedItem.feedItemId]){
        isFavorited = true;
    }
    else{
        isFavorited = false;
    }
    if([self.signedInUser.attendingFeedItemIds containsObject:feedItem.feedItemId]){
        isAttending = true;
    }
    else{
        isAttending = false;
    }
    
    [cell configureWithFeedItem:feedItem ecUser:self.signedInUser cellIndex:indexPath commentCount:commentCount isFavorited:isFavorited isAttending:isAttending];
//    [cell configureWithFeedItem:feedItem];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 310.0;
//    return UITableViewAutomaticDimension;
}

#pragma mark - DCEventTableViewCell Delegate methods

- (void)eventFeedDidTapFeedITemThumbnail:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
}

- (void)eventFeedDidTapCommentsButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    if (_mUserEmail != nil && ![_mUserEmail isEqualToString:@""]){
        NSLog(@"%@", dcEventTableViewCell.feedItem.feedItemId);
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:dcEventTableViewCell.feedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                /*
                 // Push to comments view controller directly
                 ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
                 ECTopic *topic = [topics objectAtIndex:1];
                 ecEventTopicCommentsViewController.selectedFeedItem = dcEventTableViewCell.feedItem;
                 ecEventTopicCommentsViewController.selectedTopic = topic;
                 ecEventTopicCommentsViewController.topicId = topic.topicId;
                 [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
                 */
                
                ECTopic *topic = [topics objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = dcEventTableViewCell.feedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                dcChat.isCommingFromEvent = true;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
    }else{
        // push to signIn vc
    }
}

- (void)eventFeedDidTapFavoriteButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    if (_mUserEmail != nil && ![_mUserEmail isEqualToString:@""]){
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = true;
        dcPlaylistsTableViewController.isSignedInUser = true;
        dcPlaylistsTableViewController.feedItemId = dcEventTableViewCell.feedItem.feedItemId;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }else{
        // push to sign in vc
    }
}

- (void)eventFeedDidTapAttendanceButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    if (_mUserEmail != nil && ![_mUserEmail isEqualToString:@""]){
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = dcEventTableViewCell.feedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }else{
        // push to sign in vc
    }
}

- (void)eventFeedDidTapShareButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    if (_mUserEmail != nil && ![_mUserEmail isEqualToString:@""]){
        NSString* title = dcEventTableViewCell.feedItem.digital.episodeTitle;
        NSString* link = dcEventTableViewCell.feedItem.digital.imageUrl;
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
                                             self.content.contentURL = [NSURL URLWithString:dcEventTableViewCell.feedItem.digital.imageUrl];
                                             self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                             self.content.contentDescription = dcEventTableViewCell.feedItem.digital.episodeDescription;
                                             
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
                                            NSLog(@"Twitter action");
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
//            popover.sourceView = ecFeedCell;
//            popover.sourceRect = ecFeedCell.bounds;
//            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        // push to sign in vc
    }
}

@end
