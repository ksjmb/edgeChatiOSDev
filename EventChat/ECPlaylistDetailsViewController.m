//
//  ECPlaylistDetailsViewController.m
//  EventChat
//
//  Created by Mindbowser on 23/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECPlaylistDetailsViewController.h"
#import "IonIcons.h"
#import "ECColor.h"
#import "ECUser.h"
//#import "ECCommonClass.h"
#import "DCNewTVShowEpisodeTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "DCStreamingPlayerViewController.h"
#import "DCSeasonSelectorTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECEventTopicCommentsViewController.h"
#import "DCPlaylistsTableViewController.h"
#import "ECAttendanceDetailsViewController.h"
#import "DCChatReactionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SVProgressHUD.h"
//
#import "ECAPI.h"
#import "AppDelegate.h"
#import "ECEvent.h"
#import "Branch.h"
#import "DCPlaylist.h"
#import <Social/Social.h>
#import "ECAttendanceDetailsViewController.h"

@interface ECPlaylistDetailsViewController () <HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>

@property (nonatomic, strong) HTHorizontalSelectionList *filterSeasonList;
@property (nonatomic, strong) NSArray *horizontalItemArray;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) NSMutableArray *episodesInSeason;
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, strong) NSString* topEpisodeTitle;
@property (nonatomic, strong) NSString* topEpisodeDescription;
@property (nonatomic, strong) NSString* topEpisodeImageURL;
@property (nonatomic, strong) NSString* selectedFeedItemId;
@property (nonatomic, assign) NSString *userEmail;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *topicsArray;

@end

@implementation ECPlaylistDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mSignedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    self.horizontalItemArray = [NSArray arrayWithObjects:@"All", @"Video", @"Image", nil];
    if(!self.isCanShare){
        [self.shareBtn setHidden:true];
    }
    // Register cell
    [self.playDetailsTableView registerNib:[UINib nibWithNibName:@"ECPlaylistDetailsTableViewCell" bundle:nil]
                    forCellReuseIdentifier:@"ECPlaylistDetailsTableViewCell"];
    [self initialSetup];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationItem setTitle:self.mPlaylistName];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.userEmail == nil){
        self.signedInUser = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ECPlaylistDetailsTableViewCell";
    ECPlaylistDetailsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    DCFeedItem *dcFeedItem = [self.favListArray objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[ECPlaylistDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.mPlaylistDelegate = self;
    BOOL isFavorited = false;
    BOOL isAttending = false;
    
    if([self.signedInUser.favoritedFeedItemIds containsObject:dcFeedItem.feedItemId]){
        isFavorited = true;
    }
    else{
        isFavorited = false;
    }
    
    if([self.signedInUser.attendingFeedItemIds containsObject:dcFeedItem.feedItemId]){
        isAttending = true;
    }
    else{
        isAttending = false;
    }
    
    [cell configureCellFeedItemWith:dcFeedItem isFavorited:isFavorited isAttending:isAttending indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300.0;
}

#pragma mark:- HTHorizontalSelectionList DataSource Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return self.horizontalItemArray.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return [self.horizontalItemArray[index] uppercaseString];
}

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    int mSelectedSeason = [self.horizontalItemArray[index] intValue];
    [self loadSelectedSeason:mSelectedSeason];
}

- (void)loadSelectedSeason:(int)selectedSeason{
    [self.playDetailsTableView reloadData];
    //    _currentSeason = selectedSeason;
    //    [self loadEpisodesInSelectedSeasion:[NSString stringWithFormat:@"%d", _currentSeason]];
}

/*
 - (void)loadEpisodesInSelectedSeasion:(NSString *)seasonNumber{
 _episodesInSeason = [[NSMutableArray alloc] initWithArray:[_relatedFeedItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(digital.seasonNumber LIKE[cd] %@)", seasonNumber]]];
 NSSortDescriptor *aSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"digital.episodeNumber" ascending:YES comparator:^(id obj1, id obj2) {
 
 if ([obj1 integerValue] > [obj2 integerValue]) {
 return (NSComparisonResult)NSOrderedDescending;
 }
 if ([obj1 integerValue] < [obj2 integerValue]) {
 return (NSComparisonResult)NSOrderedAscending;
 }
 return (NSComparisonResult)NSOrderedSame;
 }];
 _episodesInSeason = [NSMutableArray arrayWithArray:[_episodesInSeason sortedArrayUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]]];
 [self.episodeTableView reloadData];
 }
 */

#pragma mark:- Instance Methods

- (void) initialSetup{    
    //** Uncomment below code when it is required in app, also unselect(Hidden) self.horizontalItemView from stroboard **//
    /*
     self.filterSeasonList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, 40)];
     self.filterSeasonList.delegate = self;
     self.filterSeasonList.dataSource = self;
     [self.horizontalItemView addSubview:self.filterSeasonList];
     
     [self loadSelectedSeason:[_selectedFeedItem.digital.seasonNumber intValue]];
     */
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.layer.borderWidth = 3;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.masksToBounds = YES;
    
    self.coverImageView.layer.cornerRadius = 5.0;
    self.coverImageView.layer.masksToBounds = YES;
    self.coverImageView.layer.borderWidth = 5;
    self.coverImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.shareBtn setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    
    if( self.mCoverImageURL != nil){
        [self showImageOnHeader:self.mCoverImageURL];
    }
    //Also set the profile image i.e. self.mProfileImageURL
    //    self.profileNameLabel.text = self.mProfileName;
    self.topEpisodeDescription =  @""; // set description value comming in API
    //    self.playlistDescriptionLabel.text = self.topEpisodeDescription;
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnShareBtn:(id)sender {
    [self openShareSheet];
}

- (IBAction)actionOnPlaylistViewMoreBtn:(id)sender {
    NSLog(@"View More button click...");
}

#pragma mark:- Delegate Methods

- (void)playVideoForSelectedEpisode:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index{
    NSLog(@"Play Button: index: %ld", (long)index);
}

- (void)didTapCommentsButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index{
    NSLog(@"comment: index: %ld", (long)index);
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:ecTableViewCell.feedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.topics = [[NSMutableArray alloc] initWithArray:topics];
            ECTopic *topic = [self.topics objectAtIndex:1];
            
            DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
            dcChat.selectedFeedItem = ecTableViewCell.feedItem;
            dcChat.selectedTopic = topic;
            dcChat.topicId = topic.topicId;
            [self.navigationController pushViewController:dcChat animated:NO];
        }
    }];
}

// change to Like button
- (void)mainFeedDidTapFavoriteButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index{
    NSLog(@"Fav (Like): index: %ld", (long)index);
    ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
    ecAttendanceDetailsViewController.selectedFeedItem = ecTableViewCell.feedItem;
    [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
}

// change to Share button
- (void)mainFeedDidTapAttendanceButton:(ECPlaylistDetailsTableViewCell *)ecTableViewCell index:(NSInteger)index{
    NSLog(@"Like (Share): index: %ld", (long)index);
    NSString* title = ecTableViewCell.feedItem.person.profession.title;
    NSString* link = ecTableViewCell.feedItem.person.profilePic_url;
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
                                         self.content.contentURL = [NSURL URLWithString:ecTableViewCell.feedItem.person.profilePic_url];
                                         self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                         self.content.contentDescription = ecTableViewCell.feedItem.person.blurb;
                                         
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
                                        [self twitterSetup:[NSURL URLWithString:ecTableViewCell.feedItem.person.profilePic_url] :ecTableViewCell.feedItem.person.name];
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

#pragma mark - ActionSheet Methods

-(void)openShareSheet{
    NSArray* dataToShare = @[self.topEpisodeDescription, self.mCoverImageURL];
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
                                         NSLog(@"Share to Facebook");
                                         self.shareDialog = [[FBSDKShareDialog alloc] init];
                                         self.content = [[FBSDKShareLinkContent alloc] init];
                                         self.content.contentURL = [NSURL URLWithString:self.mCoverImageURL];
                                         self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                         self.content.contentDescription = self.topEpisodeDescription;
                                         
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
                                        [self twitterSetup:[NSURL URLWithString:self.mCoverImageURL] :self.topEpisodeDescription];
                                    }];
    
    UIAlertAction *moreOptionsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"More Options...", @"More Options... action")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                        {
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
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

#pragma mark - SDWebImage

-(void)showImageOnHeader:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        self.coverImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.coverImageView.image = image;
        
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
                                    self.coverImageView.image = image;
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
