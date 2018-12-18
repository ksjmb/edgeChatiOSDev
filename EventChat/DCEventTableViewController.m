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
#import "DCFeedItem.h"
#import "DCEventEntityObject.h"

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
    self.mUserEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventTV) name:@"updateEventTV" object:nil];

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

#pragma mark:- Post Notification Methods

-(void)updateEventTV {
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self.eventTableView reloadData];
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
    NSLog(@"eventFeedDidTapFeedITemThumbnail...");
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
        self.saveEventFeedItem = dcEventTableViewCell.feedItem;
        [[NSUserDefaults standardUserDefaults] setObject:dcEventTableViewCell.feedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInVC:@"DCChatReactionViewController"];
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
        [[NSUserDefaults standardUserDefaults] setObject:dcEventTableViewCell.feedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInVC:@"DCPlaylistsTableViewController"];
    }
}

- (void)eventFeedDidTapAttendanceButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    if (_mUserEmail != nil && ![_mUserEmail isEqualToString:@""]){
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = dcEventTableViewCell.feedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }else{
        self.saveEventFeedItem = dcEventTableViewCell.feedItem;
        [self pushToSignInVC:@"ECAttendanceDetailsViewController"];
    }
}

- (void)eventFeedDidTapShareButton:(DCEventTableViewCell *)dcEventTableViewCell index:(NSInteger)index{
    if (_mUserEmail != nil && ![_mUserEmail isEqualToString:@""]){
        NSString* title = dcEventTableViewCell.feedItem.event.name;
        NSString* link = dcEventTableViewCell.feedItem.event.mainImage;
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
                                             self.content.contentURL = [NSURL URLWithString:dcEventTableViewCell.feedItem.event.mainImage];
                                             self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                             NSString *strDescription = [NSString stringWithFormat:@"%@, %@", dcEventTableViewCell.feedItem.event.city, dcEventTableViewCell.feedItem.event.state];
                                             self.content.contentDescription = strDescription;
                                             
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
        [self pushToSignInVC:@"sameVC"];
    }
}

#pragma mark:- Instance Method

- (void)pushToSignInVC :(NSString*)stbIdentifier{
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpVC = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    signUpVC.delegate = self;
    signUpVC.hidesBottomBarWhenPushed = YES;
    signUpVC.storyboardIdentifierString = stbIdentifier;
    [self.navigationController pushViewController:signUpVC animated:true];
}

-(void)sendToSpecificVC:(NSString*)identifier{
    NSString *feedItemId = [[NSUserDefaults standardUserDefaults] valueForKey:@"feedItemId"];
    
    if([identifier isEqualToString:@"ECAttendanceDetailsViewController"]) {
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = self.saveEventFeedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }
    else if([identifier isEqualToString:@"DCPlaylistsTableViewController"]) {
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = true;
        dcPlaylistsTableViewController.isSignedInUser = true;
        dcPlaylistsTableViewController.feedItemId = feedItemId;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
//        [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
    }
    if([identifier isEqualToString:@"DCChatReactionViewController"]) {
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                ECTopic *topic = [topics objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = self.saveEventFeedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                dcChat.isCommingFromEvent = true;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
    }
}

#pragma mark:- SignUpLoginDelegate Methods

- (void)didTapLoginButton:(NSString *)storyboardIdentifier{
    NSLog(@"didTapLoginButton: EventTableVC: storyboardIdentifier: %@", storyboardIdentifier);
    [self sendToSpecificVC:storyboardIdentifier];
}

@end
