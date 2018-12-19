//
//  DCInfluencersPersonDetailsViewController.m
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCInfluencersPersonDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DCFeedItem.h"
#import "ECUser.h"
#import "DCYTPlayerTableViewCell.h"
#import "IonIcons.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"
#import "AppDelegate.h"
#import "ECEventTopicCommentsViewController.h"
#import "SignUpLoginViewController.h"
#import "DCChatReactionViewController.h"
#import "DCInfluencersPersonDetailsTableViewCell.h"
#import "DCSocialTableViewCell.h"
#import "DCPlaylistsTableViewController.h"
#import "ECAttendanceDetailsViewController.h"

@interface DCInfluencersPersonDetailsViewController ()
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *commentBarBtnItem;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSString *userEmailStr;
@property (nonatomic, strong) NSMutableArray *topicsArray;
@property (nonatomic, strong) NSMutableArray *videoArray;

@property (nonatomic, strong) FBSDKShareDialog *fbShareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *fbContent;

@end

@implementation DCInfluencersPersonDetailsViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.commentBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_chatboxes  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapComment:)];
    [self.navigationItem setRightBarButtonItem:self.commentBarBtnItem];

    if (![self.mSelectedDCFeedItem.person.name  isEqual: @""]){
        [self.navigationItem setTitle:self.mSelectedDCFeedItem.person.name];
    }else{
        [self.navigationItem setTitle:@"Influencer's Profile"];
    }
    
    self.mProfilePhotoImageView.layer.cornerRadius = self.mProfilePhotoImageView.frame.size.width / 2;
    self.mProfilePhotoImageView.layer.borderWidth = 5;
    self.mProfilePhotoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mProfilePhotoImageView.layer.masksToBounds = YES;
    
    self.mBKImageView.layer.cornerRadius = 5.0;
    self.mBKImageView.layer.masksToBounds = YES;
    self.mBKImageView.layer.borderWidth = 5;
    self.mBKImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.mFollowbtn.layer.cornerRadius = 5.0;
    
    [self.mPersonTitleLabel setText:[NSString  stringWithFormat:@"%@", self.mSelectedDCFeedItem.person.name]];
    [self.mPersonDescriptionLabel setText:[NSString stringWithFormat:@"%@", self.mSelectedDCFeedItem.person.blurb]];
//    [self showImageOnHeader:self.mSelectedDCFeedItem.mainImage_url];
    [self showImageOnHeader:self.mSelectedDCFeedItem.person.profilePic_url];
    
    // Register cell
    [self.mTableView registerNib:[UINib nibWithNibName:@"DCInfluencersPersonDetailsTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"DCInfluencersPersonDetailsTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated{
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    self.userEmailStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        static NSString *CellIdentifier = @"DCSocialTableViewCell";
        DCSocialTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [mCell configureCell:self.mSelectedDCFeedItem];
        return mCell;
    }
    else{
        static NSString *CellIdentifierNew = @"DCInfluencersPersonDetailsTableViewCell";
        DCInfluencersPersonDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
//        DCFeedItem *dcFeedItem = [self.mSelectedDCFeedItem objectAtIndex:indexPath.row];
        if (!cell) {
            cell = [[DCInfluencersPersonDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierNew];
        }
        
        cell.dcPersonDelegate = self;
        BOOL isFavorited = false;
        BOOL isAttending = false;
        
        if([self.signedInUser.favoritedFeedItemIds containsObject:self.mSelectedDCFeedItem.feedItemId]){
            isFavorited = true;
        }
        else{
            isFavorited = false;
        }
        
        if([self.signedInUser.attendingFeedItemIds containsObject:self.mSelectedDCFeedItem.feedItemId]){
            isAttending = true;
        }
        else{
            isAttending = false;
        }

        [cell configureTableViewCellWithItem:self.mSelectedDCFeedItem isFavorited:isFavorited isAttending:isAttending indexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 50.0;
    }
    else{
//        return 279.0;
        return 248.0;
    }
}

#pragma mark:- Instance Methods

- (IBAction)didTapComment:(id)sender{
    if (![self.userEmailStr  isEqual: @""] && self.userEmailStr != nil){
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:self.mSelectedDCFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.topicsArray = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topicsArray objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = self.mSelectedDCFeedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
    }else{
        [self pushToSignInViewController:@"DCChatReactionViewController"];
    }
}

- (void)pushToSignInViewController :(NSString*)stbIdentifier{
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *vc = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    vc.delegate = self;
    vc.hidesBottomBarWhenPushed = YES;
    vc.storyboardIdentifierString = stbIdentifier;
    [self.navigationController pushViewController:vc animated:true];
}

-(void)sendToSpecificVC:(NSString*)identifier{
    if([identifier isEqualToString:@"DCChatReactionViewController"]) {
        NSString *feedItemId = [[NSUserDefaults standardUserDefaults] valueForKey:@"feedItemId"];
        
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.topicsArray = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topicsArray objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = self.mSelectedDCFeedItem;
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
            dcPlaylistsTableViewController.isFeedMode = true;
            dcPlaylistsTableViewController.feedItemId = feedItemId;
            [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
    }
    else if([identifier isEqualToString:@"ECAttendanceDetailsViewController"]) {
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = self.mSelectedDCFeedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }
}

#pragma mark:- SignUpLoginDelegate Methods

- (void)didTapLoginButton:(NSString *)storyboardIdentifier{
    NSLog(@"didTapLoginButton: DCInfluencersPersonDetails: storyboardIdentifier: %@", storyboardIdentifier);
    [self sendToSpecificVC:storyboardIdentifier];
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnFollowBtn:(id)sender {
    NSLog(@"Comming soon...");
}

#pragma mark:- Delegate Methods

- (void)didTapShareButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    if (![self.userEmailStr  isEqual: @""] && self.userEmailStr != nil){
        NSString* title = self.mSelectedDCFeedItem.person.name;
        NSString* link = self.mSelectedDCFeedItem.person.profilePic_url;
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
                                             self.fbShareDialog = [[FBSDKShareDialog alloc] init];
                                             self.fbContent = [[FBSDKShareLinkContent alloc] init];
                                             self.fbContent.contentURL = [NSURL URLWithString:self.mSelectedDCFeedItem.person.profilePic_url];
                                             self.fbContent.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                             self.fbContent.contentDescription = self.mSelectedDCFeedItem.person.blurb;
                                             
                                             if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
                                                 [self.fbShareDialog setMode:FBSDKShareDialogModeNative];
                                             }
                                             else {
                                                 [self.fbShareDialog setMode:FBSDKShareDialogModeAutomatic];
                                             }
                                             //[self.shareDialog setMode:FBSDKShareDialogModeShareSheet];
                                             [self.fbShareDialog setShareContent:self.fbContent];
                                             [self.fbShareDialog setFromViewController:self];
                                             [self.fbShareDialog setDelegate:self];
                                             [self.fbShareDialog show];
                                             //[FBSDKShareDialog showFromViewController:self withContent:self.content delegate:self];
                                         }];
        
        UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Twitter", @"Twitter action")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                        {
                                            NSLog(@"Twitter action...");
                                            [self shareViaTwitter:[NSURL URLWithString:self.mSelectedDCFeedItem.person.profilePic_url] :self.mSelectedDCFeedItem.person.name];
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
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self pushToSignInViewController:@"sameVC"];
    }
}

- (void)didTapCommentsButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    if (![self.userEmailStr  isEqual: @""] && self.userEmailStr != nil){
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:self.mSelectedDCFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.topicsArray = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topicsArray objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = self.mSelectedDCFeedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
    }else{
//        self.saveSelectedFeedItem = dcPersonDetailsCell.feedItem;
        [[NSUserDefaults standardUserDefaults] setObject:self.mSelectedDCFeedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInViewController:@"DCChatReactionViewController"];
    }
}

- (void)didTapFavoriteButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    if (![self.userEmailStr  isEqual: @""] && self.userEmailStr != nil){
        DCPlaylistsTableViewController *dcPlaylistsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTVC.isFeedMode = true;
        dcPlaylistsTVC.isSignedInUser = true;
        dcPlaylistsTVC.feedItemId = self.mSelectedDCFeedItem.feedItemId;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:self.mSelectedDCFeedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInViewController:@"DCPlaylistsTableViewController"];
    }
}

- (void)didTapAttendanceButton:(DCInfluencersPersonDetailsTableViewCell *)dcPersonDetailsCell index:(NSInteger)index{
    if (![self.userEmailStr  isEqual: @""] && self.userEmailStr != nil){
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = self.mSelectedDCFeedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }else{
//        self.saveFeedItem = dcTVNewShowEpisodeTableViewCell.feedItem;
        [self pushToSignInViewController:@"ECAttendanceDetailsViewController"];
    }
}

#pragma mark:- Twitter Methods

- (void)shareViaTwitter:(NSURL *)mURL :(NSString *)title{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:mURL]];
    [composer setImage:mImage];
    [composer setText:title];
    
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            UIAlertController* alert;
            alert = [UIAlertController alertControllerWithTitle:@"Failed" message:@"Something went wrong while sharing on Twitter, Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else {
            UIAlertController* alert;
            alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your post has been successfully shared." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

#pragma mark:- SDWebImage

-(void)showImageOnHeader:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    
    if (inMemoryImage)
    {
        self.mBKImageView.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.mBKImageView.image = image;
        
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
                                    self.mBKImageView.image = image;
                                    self.mBKImageView.layer.borderWidth = 1.0;
                                    self.mBKImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
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

@end
