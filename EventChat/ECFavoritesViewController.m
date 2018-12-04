//
//  ECFavoritesViewController.m
//  EventChat
//
//  Created by Jigish Belani on 11/7/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECFavoritesViewController.h"
#import "ECAPI.h"
#import "AppDelegate.h"
#import "ECEvent.h"
#import "ECEventTopicCommentsViewController.h"
#import "ECEventDetailViewController.h"
#import "Branch.h"
#import "DCTVShowViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ECCommonClass.h"
#import "DCPersonDetailTableViewController.h"
#import "DCProfileTableViewController.h"
#import "DCPlaylist.h"

@interface ECFavoritesViewController ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *topics;

@end

@implementation ECFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!self.isSignedInUser){
    }
    NSLog(@"SignedInUser: %@", self.signedInUser);
    if(!_canShare){
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
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
    return 115.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favoriteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ECFavoritesCell";
    DCFeedItem *favoriteFeedItem = [self.favoriteList objectAtIndex:indexPath.row];
        ECFavoritesCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ECFavoritesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        cell.isSignedInUser = self.isSignedInUser;
    //Get ECEvent Comment Count
    [cell configureWithFeedItem:favoriteFeedItem commentCount:[favoriteFeedItem.commentCount intValue]];
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isSignedInUser){
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            if(self.isSignedInUser){
                    DCFeedItem *dcFeedItem = [self.favoriteList objectAtIndex:indexPath.row];
                    [[ECAPI sharedManager] deleteFavoriteFeedItem:dcFeedItem.feedItemId playlistId:_playlistId userId:self.signedInUser.userId callback:^(DCPlaylist *playlist, NSError *error) {
                        if(error){
                            NSLog(@"Error: %@", error);
                        }
                        else{
                            [self.favoriteList removeObjectAtIndex:indexPath.row];
                            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }];
            }
        }];
        
        return @[deleteAction];//@[deleteAction, moreAction, blurAction];
    }
    else{
        return @[];
    }
}

// From Master/Detail Xcode template
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isSignedInUser){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSError *eventError;
//            DCFeedItem *dcFeedItem = [self.favoriteList objectAtIndex:indexPath.row];
//            [[ECAPI sharedManager] deleteFavoriteFeedItem:dcFeedItem.feedItemId playlistId:_playlistId userId:self.signedInUser.userId callback:^(ECUser *ecUser, NSError *error) {
//                if(error){
//                    NSLog(@"Error: %@", error);
//                }
//                else{
//                    self.signedInUser = ecUser;
//                    [self.favoriteList removeObjectAtIndex:indexPath.row];
//                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                }
//            }];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if(self.isSignedInUser){
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - API Methods
- (IBAction)didTapSharePlaylist:(id)sender{
    // only canonical identifier is required
    BranchUniversalObject *buo = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:[NSString stringWithFormat:@"playlist/%@", _playlistId]];
    buo.title = @"EdgeTVChat Playlist";
    buo.contentDescription = @"EdgeTVChat Playlist";
    buo.imageUrl = @"http://www.diddychat.com/img/macbook-pro.png";
    buo.price = 12.12;
    buo.currency = @"USD";
    buo.contentIndexMode = ContentIndexModePublic;
    buo.automaticallyListOnSpotlight = YES;
    [buo addMetadataKey:@"custom" value:[[NSUUID UUID] UUIDString]];
    [buo addMetadataKey:@"anything" value:@"everything"];
    [buo addMetadataKey:@"playlistId" value:_playlistId];
    
    BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
    lp.feature = @"facebook";
    lp.channel = @"sharing";
    lp.campaign = @"Playlist sharing";
    lp.stage = @"new user";
    lp.tags = @[@"one", @"two", @"three"];
    
    [lp addControlParam:@"$desktop_url" withValue: @"http://www.diddychat.com"];
    [lp addControlParam:@"$ios_url" withValue: @"http://www.diddychat.com"];
    [lp addControlParam:@"$ipad_url" withValue: @"http://www.diddychat.com"];
    [lp addControlParam:@"$android_url" withValue: @"http://www.diddychat.com"];
    [lp addControlParam:@"$match_duration" withValue: @"2000"];
    
    [lp addControlParam:@"custom_data" withValue: @"yes"];
    [lp addControlParam:@"look_at" withValue: @"this"];
    [lp addControlParam:@"nav_to" withValue: @"over here"];
    [lp addControlParam:@"random" withValue: [[NSUUID UUID] UUIDString]];
    
    [buo getShortUrlWithLinkProperties:lp andCallback:^(NSString* url, NSError* error) {
        if (!error) {
            NSLog(@"@", url);
        }
    }];
    
    [buo showShareSheetWithLinkProperties:lp andShareText:@"Checkout my Playlist on EdgeTVChat!" fromViewController:self completion:^(NSString* activityType, BOOL completed) {
        NSLog(@"finished presenting");
    }]; 
}
- (void)didTapDeleteFavoriteButton:(NSInteger)index{
    
    
}

#pragma mark - ECFavoritesCall Delegate Methods
- (void)favoritesDidTapCommentsButton:(ECFavoritesCell *)ecFavoritesCell{
    NSLog(@"%@", ecFavoritesCell.favoriteFeedItem.feedItemId);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:ecFavoritesCell.favoriteFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            
            NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
            self.topics = [[NSMutableArray alloc] initWithArray:topics];
            
            // Push to comments view controller directly
            ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
            ECTopic *topic = [self.topics objectAtIndex:1];
            ecEventTopicCommentsViewController.selectedFeedItem = ecFavoritesCell.favoriteFeedItem;
            ecEventTopicCommentsViewController.selectedTopic = topic;
            ecEventTopicCommentsViewController.topicId = topic.topicId;
            
            [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
        }
        
    }];
}

- (void)favoritesDidTapGetEventDetails:(ECFavoritesCell *)ecFavoritesCell{
    if([ecFavoritesCell.favoriteFeedItem.entityType isEqual:EntityType_DIGITAL]){
        // Play one-off episodes or navigate to TV Show view
        if([ecFavoritesCell.favoriteFeedItem.digital.seasonNumber intValue] == 0 && [ecFavoritesCell.favoriteFeedItem.digital.seasonNumber intValue] ==0){
            NSLog(@"CID: %@", [[ecFavoritesCell.favoriteFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8]);
            [[ECAPI sharedManager] getPlaybackUrl:[[ecFavoritesCell.favoriteFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8] callback:^(NSString *aPlaybackUrl, NSError *error) {
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:aPlaybackUrl]];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                AVPlayerViewController *avvc = [AVPlayerViewController new];
                avvc.player = player;
                [player play];
                [self presentViewController:avvc animated:YES completion:nil];
            }];
        }
        else{
            [[ECAPI sharedManager] getRelatedEpisodes:ecFavoritesCell.favoriteFeedItem.digital.series callback:^(NSArray *searchResult, NSError *error) {
                if(error){
                    NSLog(@"Error: %@", error);
                }
                else{
                    DCTVShowViewController * dcTVShowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCTVShowViewController"];
                    dcTVShowViewController.selectedFeedItem = ecFavoritesCell.favoriteFeedItem;
                    dcTVShowViewController.relatedFeedItems = searchResult;
                    [self presentViewController:dcTVShowViewController animated:YES completion:nil];
                }
            }];
        }
    }
    else if ([ecFavoritesCell.favoriteFeedItem.entityType isEqual:EntityType_EVENT]){
    }
    else{
        DCPersonDetailTableViewController * dcPersonDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPersonDetailTableViewController"];
        dcPersonDetailTableViewController.selectedFeedItem = ecFavoritesCell.favoriteFeedItem;
        [self.navigationController pushViewController:dcPersonDetailTableViewController animated:YES];
    }
}
@end
