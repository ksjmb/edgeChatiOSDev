//
//  DCNewTVShowViewController.m
//  EventChat
//
//  Created by Mindbowser on 14/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCNewTVShowViewController.h"
#import "IonIcons.h"
#import "ECColor.h"
#import "ECUser.h"
#import "ECCommonClass.h"
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
#import "SignUpLoginViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface DCNewTVShowViewController () <HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>

@property (nonatomic, strong) HTHorizontalSelectionList *filterSeasonList;
@property (nonatomic, strong) NSArray *feedItemSeasonArray;

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) NSMutableArray *episodesInSeason;
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, strong) NSString* topEpisodeTitle;
@property (nonatomic, strong) NSString* topEpisodeDescription;
@property (nonatomic, strong) NSString* topEpisodeImageURL;
@property (nonatomic, strong) NSMutableArray *topics;
//
@property (nonatomic, assign) NSString *userEmail;

@end

@implementation DCNewTVShowViewController

#pragma mark:- UIViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Season List";
    [self initialSetup];
}

- (void)viewWillAppear:(BOOL)animated{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    _userEmail = [defaults objectForKey:@"SignedInUserEmail"];
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInUserEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_episodesInSeason count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DCNewTVShowEpisodeTableViewCell";
    DCNewTVShowEpisodeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DCFeedItem *dcFeedItem = [_episodesInSeason objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[DCNewTVShowEpisodeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the tableview cell...
    cell.delegate = self;
    BOOL isFavorited = false;
    BOOL isAttending = false;
    
//    commentCount = [dcFeedItem.commentCount intValue];
    
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

//    [cell configureWithFeedItem:dcFeedItem isFavorited:isFavorited isAttending:isAttending];
    [cell configureWithFeedItemWith:dcFeedItem isFavorited:isFavorited isAttending:isAttending indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 279.0;
    return UITableViewAutomaticDimension;
}

#pragma mark:- HTHorizontalSelectionList DataSource Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return _feedItemSeasonArray.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    NSString *seasonName = [NSString stringWithFormat:@"Season %@", _feedItemSeasonArray[index]];
    return [seasonName uppercaseString];
}

#pragma mark - HTHorizontalSelectionList Delegate Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    NSLog(@"feedItemSeasonArray[index]: %@",_feedItemSeasonArray[index]);
    int mSelectedSeason = [_feedItemSeasonArray[index] intValue];
    [self loadSelectedSeason:mSelectedSeason];
}

#pragma mark - DCSeasonSelectorTableViewControllerl Delegate methods

- (void)loadSelectedSeason:(int)selectedSeason{
    _currentSeason = selectedSeason;
    [self loadEpisodesInSelectedSeasion:[NSString stringWithFormat:@"%d", _currentSeason]];
}

#pragma mark:- DCNewTVShowEpisodeTableViewCell Delegate methods

- (void)playVideoForSelectedEpisode:(DCNewTVShowEpisodeTableViewCell *)dcTVShowEpisodeTableViewCell index:(NSInteger)index{
    DCFeedItem *dcFeedItem = [_episodesInSeason objectAtIndex:index];
//    NSLog(@"CID: %@", [[dcFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8]);
    
    [[ECAPI sharedManager] getPlaybackUrl:[[dcFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8] callback:^(NSString *aPlaybackUrl, NSError *error) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:aPlaybackUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
        [self presentViewController:avvc animated:YES completion:nil];
    }];
}

- (void)didTapCommentsButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index {
//    NSLog(@"didTapCommentsButton");
    
    if (self.userEmail != nil){
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:dcTVNewShowEpisodeTableViewCell.feedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.topics = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topics objectAtIndex:1];
                
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = dcTVNewShowEpisodeTableViewCell.feedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
    }else{
        self.saveFeedItem = dcTVNewShowEpisodeTableViewCell.feedItem;
        [[NSUserDefaults standardUserDefaults] setObject:dcTVNewShowEpisodeTableViewCell.feedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInVC:@"DCChatReactionViewController"];
    }
}

- (void)mainFeedDidTapFavoriteButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index{
    if (self.userEmail != nil){
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = true;
        dcPlaylistsTableViewController.isSignedInUser = true;
        dcPlaylistsTableViewController.feedItemId = dcTVNewShowEpisodeTableViewCell.feedItem.feedItemId;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:dcTVNewShowEpisodeTableViewCell.feedItem.feedItemId forKey:@"feedItemId"];
        self.isTopFavButtonSelected = false;
        [self pushToSignInVC:@"DCPlaylistsTableViewController"];
    }
}

- (void)mainFeedDidTapAttendanceButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index{
    if (self.userEmail != nil){
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = dcTVNewShowEpisodeTableViewCell.feedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }else{
        self.saveFeedItem = dcTVNewShowEpisodeTableViewCell.feedItem;
        [self pushToSignInVC:@"ECAttendanceDetailsViewController"];
    }
}

- (void)mainFeedDidTapShareButton:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell index:(NSInteger)index {
    if (self.userEmail != nil){
        NSString* title = dcTVNewShowEpisodeTableViewCell.feedItem.digital.episodeTitle;
        NSString* link = dcTVNewShowEpisodeTableViewCell.feedItem.digital.imageUrl;
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
                                             self.content.contentURL = [NSURL URLWithString:dcTVNewShowEpisodeTableViewCell.feedItem.digital.imageUrl];
                                             self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                             self.content.contentDescription = dcTVNewShowEpisodeTableViewCell.feedItem.digital.episodeDescription;
                                             
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
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            popover.sourceView = dcTVNewShowEpisodeTableViewCell;
            popover.sourceRect = dcTVNewShowEpisodeTableViewCell.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self pushToSignInVC:@"sameVC"];
    }
}

- (void)viewMoreButtonTapped:(DCNewTVShowEpisodeTableViewCell *)dcTVNewShowEpisodeTableViewCell{
    [self.episodeTableView beginUpdates];
    [self.episodeTableView endUpdates];
}

#pragma mark:- FBSDKSharing Delegate Methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

#pragma mark:- IBAction Methods

- (IBAction)didTapPlayVideo:(id)sender {
//    NSLog(@"_selectedFeedItem.digital.imageUrl: %@", [[_selectedFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8]);
    
    [[ECAPI sharedManager] getPlaybackUrl:[[_selectedFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8] callback:^(NSString *aPlaybackUrl, NSError *error) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:aPlaybackUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
        [self presentViewController:avvc animated:YES completion:nil];
    }];
}

- (IBAction)didTapShareButton:(id)sender {
    if (self.userEmail != nil){
        [self openShareSheet];
    }else{
        [self pushToSignInVC:@"sameVC"];
    }
}

- (IBAction)didTapFavButton:(id)sender {
    [self didTapFavButton];
}

- (IBAction)actionOnViewMoreButton:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    DCNewTVShowEpisodeTableViewCell* cell = [self.episodeTableView cellForRowAtIndexPath:indexPath];
    
    if (self.isLabelExpanded == false){
        self.topDescriptionLabel.numberOfLines = 0;
            self.topDescriptionLabel.contentMode = NSLineBreakByWordWrapping;
        [self.viewMoreButton setTitle:@"View less..." forState:UIControlStateNormal];
        CGSize labelSize = [self.topDescriptionLabel.text sizeWithFont:self.topDescriptionLabel.font
            constrainedToSize:self.topDescriptionLabel.frame.size
                                                        lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat labelHeight = labelSize.height;
        self.topDescriptionLabelHeightConstraints.constant = labelHeight;
        cell.episodeImageViewTopConstraint.constant = 30.0;
        self.isLabelExpanded = true;
    }else{
        self.topDescriptionLabel.numberOfLines = 3;
        self.topDescriptionLabel.contentMode = NSLineBreakByWordWrapping;
        [self.viewMoreButton setTitle:@"View more..." forState:UIControlStateNormal];
        self.topDescriptionLabelHeightConstraints.constant = 42;
        cell.episodeImageViewTopConstraint.constant = 8.0;
        self.isLabelExpanded = false;
    }
    [self.episodeTableView beginUpdates];
    [self.episodeTableView endUpdates];
}

#pragma mark:- Instance Methods

- (void)initialSetup{
    _currentSeason = 1;
    self.feedItemSeasonArray = [_relatedFeedItems valueForKeyPath:@"@distinctUnionOfObjects.digital.seasonNumber"];
    
    self.filterSeasonList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, 40)];
    self.filterSeasonList.delegate = self;
    self.filterSeasonList.dataSource = self;
    [self.mView addSubview:self.filterSeasonList];
    
    self.episodePlayButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    
    for(int i = 0; i < [_relatedFeedItems count]; i++){
        DCFeedItem *feedItem = [_relatedFeedItems objectAtIndex:i];
        if([feedItem.digital.seasonNumber isEqual:_selectedFeedItem.digital.seasonNumber] && [feedItem.digital.episodeNumber isEqual:@"1"]){
            [_topDescriptionLabel setText:_selectedFeedItem.digital.seriesDescription];
            _topEpisodeTitle = feedItem.digital.episodeTitle;
            _topEpisodeImageURL = feedItem.digital.imageUrl;
            _topEpisodeDescription = feedItem.digital.episodeDescription;
            if( feedItem.digital.imageUrl != nil){
                [self showImageOnHeader:feedItem.digital.imageUrl];
            }
        }
    }
    
    [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    
    self.episodeTableView.estimatedRowHeight = 279.0;
    self.episodeTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadSelectedSeason:[_selectedFeedItem.digital.seasonNumber intValue]];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
}

- (void)pushToSignInVC :(NSString*)stbIdentifier{
    ECCommonClass *sharedInstance = [ECCommonClass sharedManager];
    sharedInstance.isUserLogoutTap = false;
    sharedInstance.isFromMore = false;
    
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpVC = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    signUpVC.delegate = self;
    signUpVC.hidesBottomBarWhenPushed = YES;
    signUpVC.storyboardIdentifierString = stbIdentifier;
    [self.navigationController pushViewController:signUpVC animated:true];
}

-(void)sendToSpecificVC:(NSString*)identifier{
    if([identifier isEqualToString:@"DCChatReactionViewController"]) {
        NSString *feedItemId = [[NSUserDefaults standardUserDefaults] valueForKey:@"feedItemId"];
        
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.topics = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topics objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = self.saveFeedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
    }
    else if([identifier isEqualToString:@"DCPlaylistsTableViewController"]) {
        NSString *feedItemId = [[NSUserDefaults standardUserDefaults] valueForKey:@"feedItemId"];
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isSignedInUser = true;
        
        if (self.isTopFavButtonSelected == true){
            dcPlaylistsTableViewController.isFeedMode = false;
            [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
        }else{
            dcPlaylistsTableViewController.isFeedMode = true;
            dcPlaylistsTableViewController.feedItemId = feedItemId;
            UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
             [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
//            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }
    else if([identifier isEqualToString:@"ECAttendanceDetailsViewController"]) {
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = self.saveFeedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }
}

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

- (void)didTapFavButton{
    if (self.userEmail != nil){
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = false;
        dcPlaylistsTableViewController.isSignedInUser = true;
        [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
    }else{
        self.isTopFavButtonSelected = true;
        [self pushToSignInVC:@"DCPlaylistsTableViewController"];
    }
}

-(void)openShareSheet{
    NSArray* dataToShare = @[_topEpisodeTitle, _topEpisodeImageURL];
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
                                         self.content.contentURL = [NSURL URLWithString:_topEpisodeImageURL];
                                         self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                         self.content.contentDescription = _topEpisodeDescription;
                                         
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

#pragma mark:- SignUpLoginDelegate Methods

- (void)didTapLoginButton:(NSString *)storyboardIdentifier{
    NSLog(@"didTapLoginButton: DCNewTVShowVC: storyboardIdentifier: %@", storyboardIdentifier);
    [self sendToSpecificVC:storyboardIdentifier];
}

#pragma mark:- AF
- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager)
    {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return _operationManager;
}

#pragma mark - SDWebImage
// Displaying Image on Header
-(void)showImageOnHeader:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        _topImageView.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        _topImageView.image = image;
        
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
                                    _topImageView.image = image;
                                    _topImageView.layer.borderWidth = 1.0;
                                    _topImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                    
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image,please try again...");
                                        return;
                                    }
                                    
                                }
                            }];
    }
    
    UIView *view = [[UIView alloc] initWithFrame: _topImageView.frame];
    CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
    gradient.frame = view.frame;
    gradient.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor] ];
    gradient.locations = @[@0.0, @0.9];
    [view.layer insertSublayer: gradient atIndex: 0];
    [_topImageView addSubview: view];
    [_topImageView bringSubviewToFront: view];
}

@end
