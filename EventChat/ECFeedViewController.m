//
//  ECFeedViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/31/16.
//  Copyright © 2016 Apex Ventures, LLC. All rights reserved.
//

#import "ECFeedViewController.h"
#import "ECAPI.h"
#import "ECEventBriteSearchResult.h"
#import "ECEventBriteEvent.h"
#import "ECFeedCell.h"
#import "AppDelegate.h"
#import "ECUser.h"
#import "ECEventDetailsViewController.h"
#import "SVProgressHUD.h"
#import "ECTopicViewController.h"
#import "ECEventDetailViewController.h"
#import "ECEvent.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSObject+AssociatedObject.h"
#import "ECHowToViewController.h"
#import "ECFavoritesViewController.h"
#import "ECEventTopicCommentsViewController.h"
#import "ECAttendanceDetailsViewController.h"
#import "DCFeedItem.h"
#import "ECColor.h"
#import "DCFeedItemDetailsViewController.h"
#import "DCPlaylistsTableViewController.h"
#import "IonIcons.h"
#import "DCTVShowViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "DCFeedItemFilter.h"
#import "DCPersonDetailTableViewController.h"
#import "AFOAuth2Manager.h"
#import "ECAuthAPI.h"
#import "DCProfileTableViewController.h"
#import "DCNewTVShowViewController.h"
#import "DCChatReactionViewController.h"
//
#import "ECNewTableViewCell.h"
#import "SignUpLoginViewController.h"
#import "AFOAuth2Manager.h"
#import "ECAuthAPI.h"
#import "DCInfluencersPersonDetailsViewController.h"
#import <Social/Social.h>
#import "ECNewUserProfileViewController.h"
#import "ECNewPlaylistTableViewController.h"
#import "AddToPlaylistPopUpViewController.h"
#import "ECCommonClass.h"
#import "IndividualFeedDetailsViewController.h"
#import "ECIndividualProfileViewController.h"

@interface ECFeedViewController () <HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>
@property (nonatomic, weak) IBOutlet UITableView *eventFeedTableView;
@property (nonatomic, strong) ECEventBriteSearchResult *feedResult;
@property (nonatomic, strong) ECEventBriteSearchResult *searchResult;
//@property (nonatomic, strong) ECEventBriteEvent *event;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) UISearchController *searchController;
//@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) int searchRadius;
@property (nonatomic, strong) DCFeedItemFilter *currentFilter;
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) NSMutableArray *feedItemsArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *favoriteBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sortOptionsBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *searchBarButtonItem;
@property (nonatomic, strong) HTHorizontalSelectionList *filterList;
@property (nonatomic, strong) NSArray *feedItemFilters;
@property (nonatomic, assign) NSString *userEmail;
// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, retain) UIButton *profileButton;

@end

@implementation ECFeedViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ECCommonClass *instance = [ECCommonClass sharedManager];
    if (instance.isAouthToken){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationIsActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationEnteredForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated) name:@"profileUpdated" object:nil];
        //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(morevctap) name:@"morevctap" object:nil];
        
        [self.eventFeedTableView registerNib:[UINib nibWithNibName:@"ECNewTableViewCell" bundle:nil]
                      forCellReuseIdentifier:@"ECNewTableViewCell"];
        
        UIRefreshControl *refreshControl = [UIRefreshControl new];
        [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        [self.eventFeedTableView addSubview:refreshControl];
        [self.eventFeedTableView sendSubviewToBack:refreshControl];
        
        [self.searchController.searchBar setBarStyle:UIBarStyleDefault];
        [self.searchController.searchBar setTintColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
        [self.searchController.searchBar setBackgroundColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"Loading..."];
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.favoriteBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapViewFavorites:)];
        /*
        self.searchBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_search_strong  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(showSearchbar:)];
        [self.navigationItem setRightBarButtonItems:@[self.favoriteBarButtonItem, self.searchBarButtonItem]];
         */
        [self.navigationItem setRightBarButtonItems:@[self.favoriteBarButtonItem]];
        
        //[self.favoriteBarButtonItem setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]]];
        //[self.searchBarButtonItem  setImage:[IonIcons imageWithIcon:ion_ios_search size:30.0 color:[UIColor whiteColor]]];
        [self.searchController.searchBar setBackgroundColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
        self.searchRadius = 5;
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.currentLocation = self.appDelegate.lastLocation;
        // Get logged in user
        self.signedInUser = [[ECAPI sharedManager] signedInUser];
        self.searchController.searchResultsUpdater = self;
        // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
        self.searchController.delegate = self;
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
        self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
//        [self.navigationItem setTitle:@"EdgeChat"]; //self.navigationItem.titleView = self.searchController.searchBar;
        [self.navigationItem setTitle:@"EdgeTV!"];
        [self.searchController.searchBar sizeToFit];
        if (@available(iOS 11.0, *)) {
            [self.searchController.searchBar.heightAnchor constraintLessThanOrEqualToConstant: 44].active = YES;
        }
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        //
        self.definesPresentationContext = YES;
        //[self loadEventBriteSearchResults];
        NSLog(@"Overlay: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"HasSeenOverlay"]);
        BOOL hasSeenOverlay = [[NSUserDefaults standardUserDefaults] objectForKey:@"HasSeenOverlay"];
        if(!hasSeenOverlay){
            ECHowToViewController *addController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECHowToViewController"];
            addController.providesPresentationContextTransitionStyle = YES;
            addController.definesPresentationContext = YES;
            [addController setModalPresentationStyle:UIModalPresentationOverFullScreen];
            [self.navigationController presentViewController:addController animated:YES completion: nil];
        }
        //
        NSString *fb_profileImageURL = [[NSUserDefaults standardUserDefaults] valueForKey:@"FB_PROFILE_PIC_URL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIImage* img;
        if(fb_profileImageURL != nil){
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL   URLWithString:fb_profileImageURL]];
            img = [UIImage imageWithData:data];
            if (img == nil){
                img = [UIImage imageNamed:@"missing-profile.png"];
            }
            [self updateUserProfilePic:self.signedInUser.userId URL:fb_profileImageURL];
        }else if(self.signedInUser.profilePicUrl != nil){
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL   URLWithString:self.signedInUser.profilePicUrl]];
            img = [UIImage imageWithData:data];
            if (img == nil){
                img = [UIImage imageNamed:@"missing-profile.png"];
            }
            [self updateUserProfilePic:self.signedInUser.userId URL:self.signedInUser.profilePicUrl];
        }else{
            img = [UIImage imageNamed:@"missing-profile.png"];
        }
        _profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_profileButton setTranslatesAutoresizingMaskIntoConstraints:YES];
        _profileButton.frame = CGRectMake(0, 0, 30, 30);
        _profileButton.layer.cornerRadius = _profileButton.frame.size.width /2;
        _profileButton.layer.masksToBounds = YES;
        _profileButton.layer.borderWidth = 0.5;
        _profileButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [_profileButton setImage:[self imageWithImage:img scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
        [_profileButton addTarget:self action:@selector(didTapViewProfile:) forControlEvents:UIControlEventTouchUpInside];
        self.sortOptionsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_profileButton];
        self.navigationItem.leftBarButtonItem = self.sortOptionsBarButtonItem;
        //
        
        // JB: 01/26/18 - Commented out for not and loading particular category directly. Will address after business discussion.
        //    [[ECAPI sharedManager] getFeedItems:^(NSArray *searchResult, NSError *error) {
        //        self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
        //
        ////        dispatch_async(dispatch_get_main_queue(), ^{
        ////            [self.eventFeedTableView reloadData];
        ////        });
        //        [self.eventFeedTableView reloadData];
        //        [SVProgressHUD dismiss];
        //    }];
        
        self.filterList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, 56)];
        self.filterList.delegate = self;
        self.filterList.dataSource = self;
        [self.view addSubview:self.filterList];
        
        [[ECAPI sharedManager] getFeedItemFilters:^(NSArray *results, NSError *error){
            self.feedItemFilters = [[NSMutableArray alloc] initWithArray:results];
            [self.filterList reloadData];
            if (self.feedItemFilters.count > 0){
                DCFeedItemFilter *feedItemFilter = _feedItemFilters[0];
                _currentFilter = feedItemFilter;
                [self loadFeedItemsByFilter:feedItemFilter];
            }else{
                NSLog(@"_feedItemFilters get empty array...");
            }
        }];
    }else{
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *fb_profileImageURL = [[NSUserDefaults standardUserDefaults] valueForKey:@"FB_PROFILE_PIC_URL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *imageURL = @"";
    
    if (_userEmail != nil && ![_userEmail isEqualToString:@""]){
        UIImage* img;
        ECCommonClass *instance = [ECCommonClass sharedManager];
        if (instance.isProfilePicUpdated){
            instance.isProfilePicUpdated = false;
            if(fb_profileImageURL != nil){
                imageURL = fb_profileImageURL;
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL   URLWithString:fb_profileImageURL]];
                img = [UIImage imageWithData:data];
                if (img == nil){
                    img = [UIImage imageNamed:@"missing-profile.png"];
                }
            }else if(self.signedInUser.profilePicUrl != nil){
                imageURL = self.signedInUser.profilePicUrl;
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL   URLWithString:self.signedInUser.profilePicUrl]];
                img = [UIImage imageWithData:data];
                if (img == nil){
                    img = [UIImage imageNamed:@"missing-profile.png"];
                }
            }
            else{
                img = [UIImage imageNamed:@"missing-profile.png"];
            }

//            [_profileButton setImage:[self imageWithImage:img scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
            
            if (self.signedInUser.profilePicUrl != nil && ![self.signedInUser.profilePicUrl  isEqual: @""]){
                [self showProfilePicImage:self ForImageUrl:self.signedInUser.profilePicUrl ForImageView:_profileButton];
            }else{
                UIImage *blankImg = [UIImage imageNamed:@"missing-profile.png"];
                [self.profileButton setImage:[self imageWithImage:blankImg scaledToSize:CGSizeMake(30.0, 30.0)]  forState:UIControlStateNormal];
            }
            [self.profileButton addTarget:self action:@selector(didTapViewProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            self.sortOptionsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_profileButton];
            self.navigationItem.leftBarButtonItem = self.sortOptionsBarButtonItem;
            [self updateUserProfilePic:self.signedInUser.userId URL:imageURL];
        }
    }else{
        self.navigationItem.leftBarButtonItem = nil;
        self.signedInUser = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if(_currentFilter != nil){
        [self loadFeedItemsByFilter:_currentFilter];
    }
}

#pragma mark:- Post Notification Methods

-(void)profileUpdated {
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self.eventFeedTableView reloadData];
}

//-(void)morevctap {
//    NSLog(@"iscomming from more...");
//    [self pushToSignInVC:@"MoreViewController"];
//}

#pragma mark:- AddToPlaylist Delegate Methods

- (void)updateUI{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self.filterList setUserInteractionEnabled:YES];
}

#pragma mark:- SignUpLoginDelegate Methods

- (void)didTapLoginButton:(NSString *)storyboardIdentifier{
    NSLog(@"didTapLoginButton: ECFeedVC: storyboardIdentifier: %@", storyboardIdentifier);
    [self sendToSpecificVC:storyboardIdentifier];
}

#pragma mark:- RegisterDelegate Methods

- (void)didTapSignUpButton:(NSString *)storyboardIdentifier{
    NSLog(@"didTapSignUpButton: ECFeedVC: storyboardIdentifier: %@", storyboardIdentifier);
    [self sendToSpecificVC:storyboardIdentifier];
}

#pragma mark:- Instance Methods

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
    if([identifier isEqualToString:@"DCProfileTableViewController"]) {
        DCProfileTableViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCProfileTableViewController"];
        dcProfileTableViewController.isSignedInUser = true;
        dcProfileTableViewController.profileUser = self.signedInUser;
        [self.navigationController pushViewController:dcProfileTableViewController animated:YES];
    }
    else if([identifier isEqualToString:@"ECNewPlaylistTableViewController"]) {
        ECNewPlaylistTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECNewPlaylistTableViewController"];
        vc.isSignedInUser = true;
        vc.isFeedMode = false;
        [self.navigationController pushViewController:vc animated:YES];
    }
    //    else if([identifier isEqualToString:@"ECEventTopicCommentsViewController"]) {
    else if([identifier isEqualToString:@"DCChatReactionViewController"]) {
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
                dcChat.isInfluencers = true;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
        
        /*
         [[ECAPI sharedManager] fetchTopicsByFeedItemId:feedItemId callback:^(NSArray *topics, NSError *error)  {
         if(error){
         NSLog(@"Error: %@", error);
         }
         else{
         self.topics = [[NSMutableArray alloc] initWithArray:topics];
         ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
         ECTopic *topic = [self.topics objectAtIndex:1];
         ecEventTopicCommentsViewController.selectedFeedItem = self.saveFeedItem;
         ecEventTopicCommentsViewController.selectedTopic = topic;
         ecEventTopicCommentsViewController.topicId = topic.topicId;
         [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
         }
         }];
         */
    }
    else if([identifier isEqualToString:@"AddToPlaylistPopUpViewController"]) {
        NSString *feedItemId = [[NSUserDefaults standardUserDefaults] valueForKey:@"feedItemId"];
        
        AddToPlaylistPopUpViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToPlaylistPopUpViewController"];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFromBottom;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        self.tabBarController.tabBar.hidden = YES;
        [self.filterList setUserInteractionEnabled:NO];
        vc.playlistDelegate = self;
        vc.isFeedMode = true;
        vc.mFeedItemId = feedItemId;
        [self addChildViewController:vc];
        vc.view.frame = self.view.frame;
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
        
        /*
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = true;
        dcPlaylistsTableViewController.isSignedInUser = true;
        dcPlaylistsTableViewController.feedItemId = feedItemId;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
        [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
        //        [self presentViewController:navigationController animated:YES completion:nil];
         */
    }
    else if([identifier isEqualToString:@"SameVC"]) {
        [self setUserAttendanceResponse:self.saveFeedItem.feedItemId];
        /*
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = self.saveFeedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
         */
    }
//    else if([identifier isEqualToString:@"MoreViewController"]) {
//        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:3];
//        //[self.tabBarController setSelectedIndex:1];
//    }
    
}

- (UIImage *)imageWithImageOld:(UIImage *)image scaledToSize:(CGSize)newSize {
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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)applicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    if(_currentFilter != nil){
        [self loadFeedItemsByFilter:_currentFilter];
    }
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    if(_currentFilter != nil){
        [self loadFeedItemsByFilter:_currentFilter];
    }
    [refreshControl endRefreshing];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (IBAction)showSearchbar:(id)sender{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    [self.searchController.searchBar setBarStyle:UIBarStyleDefault];
    [self.searchController.searchBar setTintColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
    self.searchController.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    [self presentViewController:self.searchController animated:YES completion:nil];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return _feedItemFilters.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    DCFeedItemFilter *feedItemFilter = _feedItemFilters[index];
    return [feedItemFilter.name uppercaseString];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    DCFeedItemFilter *feedItemFilter = _feedItemFilters[index];
    _currentFilter = feedItemFilter;
    [[ECAPI sharedManager] filterFeedItemsByFilterObject:feedItemFilter callback:^(NSArray *searchResult, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        }
        else{
            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
            [self.eventFeedTableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
    
    //    if([feedItemCategory.type isEqual:@"entity"]){
    //        [[ECAPI sharedManager] filterFeedItemsByEntityType:@"person" callback:^(NSArray *searchResult, NSError *error) {
    //            if (error) {
    //                NSLog(@"Error adding user: %@", error);
    //                NSLog(@"%@", error);
    //            }
    //            else{
    //                self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
    //                [self.eventFeedTableView reloadData];
    //                [SVProgressHUD dismiss];
    //            }
    //        }];
    //    }
    //    else{
    //        [[ECAPI sharedManager] filterFeedItemsByCatagory:feedItemCategory.name callback:^(NSArray *searchResult, NSError *error) {
    //            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
    //            [self.eventFeedTableView reloadData];
    //            [SVProgressHUD dismiss];
    //        }];
    //    }
    //    if(index == 0){
    //        [[ECAPI sharedManager] getFeedItems:^(NSArray *searchResult, NSError *error) {
    //            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
    //            [self.eventFeedTableView reloadData];
    //            [SVProgressHUD dismiss];
    //        }];
    //    }else{
    //
    //
    //    }
}

#pragma mark - API calls
- (void)loadEventBriteSearchResults{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading Events"];
    [[ECAPI sharedManager] getEventsByLocation:[NSString stringWithFormat:@"location.latitude=%f&location.longitude=%f&location.within=%dmi", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, self.searchRadius] callback:^(ECEventBriteSearchResult *searchResult, NSError *error) {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.feedResult = searchResult;
            
            for (int i = 0; i < [self.feedResult.events count]; i++){
                NSError *eventError;
                ECEventBriteEvent *ebEvent = [[ECEventBriteEvent alloc] initWithDictionary:[self.feedResult.events objectAtIndex:i] error:&eventError];
                id object = [self.feedResult.events objectAtIndex:i];
                NSLog(@"EBEvent: %@", ebEvent.id);
                NSLog(@"EBEvent: %@", ebEvent.eventId);
                if([self.signedInUser.favoritedEventIds containsObject:ebEvent.eventId]){
                    [self.feedResult.events removeObjectAtIndex:i];
                    [self.feedResult.events insertObject:object atIndex:0];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.eventFeedTableView reloadData];
            });
            
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)loadFeedItemsFromSearchResult{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Searching..."];
    
    [[ECAPI sharedManager] searchFeedItemsByText:self.searchController.searchBar.text callback:^(NSArray *searchResult, NSError *error) {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.eventFeedTableView reloadData];
            });
            [SVProgressHUD dismiss];
        }
    }];
}

// 1st API Call
- (void)loadFeedItemsByFilter:(DCFeedItemFilter *)feedItemFilter{
    [[ECAPI sharedManager] filterFeedItemsByFilterObject:feedItemFilter callback:^(NSArray *searchResult, NSError *error) {
        if (error) {
            NSLog(@"Error loadFeedItemsByFilter: %@", error);
        }
        else{
            self.feedItemsArray = [[NSMutableArray alloc] initWithArray:searchResult];
            [self.eventFeedTableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)tempCall{
    [[ECAPI sharedManager] getUserByEmail:@"belani.jigish@gmail.com" callback:^(ECUser *ecUser, NSError *error) {
        if(error){
            NSLog(@"Error tempCall: %@", error);
        }
        else{
            NSLog(@"User: %@", ecUser);
        }
    }];
}

-(void)setUserAttendanceResponse:(NSString *)strFeedId{
    NSString *userResponse = @"Going";
    
    [[ECAPI sharedManager] setAttendeeResponse:self.signedInUser.userId feedItemId:strFeedId response:userResponse callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
        } else {
            [self updateUserProfile];
        }
    }];
}

-(void)updateUserProfile{
    [[ECAPI sharedManager] updateProfilePicUrl:self.signedInUser.userId profilePicUrl:self.signedInUser.profilePicUrl callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error update user profile: %@", error);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdated" object:nil];
        }
    }];
}

-(void)updateUserProfilePic:(NSString *)userId URL:(NSString *)profilePicURL{
    [[ECAPI sharedManager] updateProfilePicUrl:userId profilePicUrl:profilePicURL callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error update user profile pic: %@", error);
        } else {
            self.signedInUser.profilePicUrl = profilePicURL;
        }
    }];
}

#pragma mark - Table view data source

- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager)
    {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return _operationManager;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 311.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ECNewTableViewCell";
    
    DCFeedItem *dcFeedItem = [self.feedItemsArray objectAtIndex:indexPath.row];
    //DCFeedItem *dcFeedItem = [[DCFeedItem alloc] initWithDictionary:[self.feedItemsArray objectAtIndex:indexPath.row]error:nil];
    ECNewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ECNewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //ECFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
    //                                                        forIndexPath:indexPath];
    cell.delegate = self;
    int commentCount = 0;
    BOOL isFavorited = false;
    BOOL isAttending = false;
    
    commentCount = [dcFeedItem.commentCount intValue];
    
    // Get ECUser favorited feedItems //5b32f95c3fa5b10b07f4fb5d
    if([self.signedInUser.favoritedFeedItemIds containsObject:dcFeedItem.feedItemId]){
        isFavorited = true;
    }
    else{
        isFavorited = false;
    }
    
    // Get ECUser attending feedItems
    if([self.signedInUser.attendingFeedItemIds containsObject:dcFeedItem.feedItemId]){
        isAttending = true;
    }
    else{
        isAttending = false;
    }
    
    [cell configureWithFeedItem:dcFeedItem ecUser:self.signedInUser cellIndex:indexPath commentCount:commentCount isFavorited:isFavorited isAttending:isAttending];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self performSegueWithIdentifier:@"show_details" sender:nil];
    //    ECEventDetailsViewController *ecEventDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECEventDetailsViewController"];
    //    ECEventBriteEvent *event = [[ECEventBriteEvent alloc] initWithDictionary:[self.feedResult.events objectAtIndex:indexPath.row] error:nil];
    //    ecEventDetailsViewController.selectedEvent = event;
    //    ecEventDetailsViewController.eventId = event.id;
    //
    //    [self.navigationController pushViewController:ecEventDetailsViewController animated:YES];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Action sheet
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@", self.feedResult.events);
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self.feedResult.events sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]]];
                    break;
                case 1:
                    [self.feedResult.events sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"end.local" ascending:YES]]];
                    break;
                case 2:
                    [self.feedResult.events sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name.text" ascending:YES]]];
                    break;
                case 3:
                    [self.feedResult.events sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name.text" ascending:NO]]];
                    break;
                default:
                    break;
            }
            [self.eventFeedTableView reloadData];
            break;
        }
        case 2: {
            [SVProgressHUD showWithStatus:@"Loading..."];
            switch (buttonIndex) {
                case 0:
                    self.searchRadius = 5;
                    break;
                case 1:
                    self.searchRadius = 10;
                    break;
                case 2:
                    self.searchRadius = 25;
                    break;
                default:
                    break;
            }
            break;
        }
        case 3: {
            [SVProgressHUD showWithStatus:@"Loading..."];
            switch (buttonIndex) {
                case 0:
                    self.searchRadius = 5;
                    break;
                case 1:
                    self.searchRadius = 10;
                    break;
                case 2:
                    self.searchRadius = 25;
                    break;
                case 3:
                    self.searchRadius = 50;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Action sheet
- (IBAction)didTapMoreOptionsButton:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Date Added", @"End Date", @"Alphabetical (A - Z)", @"Alphabetical (Z - A)",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)didTapFilterButton:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"5 Miles", @"10 Miles", @"25 Miles", @"50 Miles",
                            nil];
    popup.tag = 2;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)didTapAddToPlaylistButton:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Playlist 1", @"Playlist 2", @"Playlist 3",
                            nil];
    popup.tag = 3;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

//** ProfileTap **//
- (IBAction)didTapViewProfile:(id)sender{
    ECNewUserProfileViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECNewUserProfileViewController"];
//    DCProfileTableViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCProfileTableViewController"];
    dcProfileTableViewController.isSignedInUser = true;
    dcProfileTableViewController.profileUser = self.signedInUser;
//    dcProfileTableViewController.mLoginUser = self.signedInUser;
    [self.navigationController pushViewController:dcProfileTableViewController animated:YES];
}

//** FavTap **//
- (IBAction)didTapViewFavorites:(id)sender{
    if (self.userEmail != nil){
        /*
        AddToPlaylistPopUpViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToPlaylistPopUpViewController"];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFromBottom;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        self.tabBarController.tabBar.hidden = YES;
        [self.filterList setUserInteractionEnabled:NO];
        vc.playlistDelegate = self;
        [self addChildViewController:vc];
        vc.view.frame = self.view.frame;
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
        
         //=======================
        
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = false;
        dcPlaylistsTableViewController.isSignedInUser = true;
        [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
        */
        
        ECNewPlaylistTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECNewPlaylistTableViewController"];
         vc.isFeedMode = false;
         vc.isSignedInUser = true;
         [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        [self pushToSignInVC:@"ECNewPlaylistTableViewController"];
    }
}

- (IBAction)didTapSearchButton:(id)sender{
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.titleView = self.searchController.searchBar;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //self.searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
    [self loadFeedItemsFromSearchResult];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar {
    //self.searchBar.showsCancelButton = true;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //self.searchBar.showsCancelButton = false;
    [searchBar resignFirstResponder];
    [self loadFeedItemsByFilter:_currentFilter];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        [searchBar resignFirstResponder];
        [self loadFeedItemsByFilter:_currentFilter];
    }
}

#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.searchController.searchBar.showsCancelButton = YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.feedResult.events mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"title"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // yearIntroduced field matching
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterNoStyle;
        NSNumber *targetNumber = [numberFormatter numberFromString:searchString];
        if (targetNumber != nil) {   // searchString may not convert to a number
            lhs = [NSExpression expressionForKeyPath:@"yearIntroduced"];
            rhs = [NSExpression expressionForConstantValue:targetNumber];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSEqualToPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            // price field matching
            lhs = [NSExpression expressionForKeyPath:@"introPrice"];
            rhs = [NSExpression expressionForConstantValue:targetNumber];
            finalPredicate = [NSComparisonPredicate
                              predicateWithLeftExpression:lhs
                              rightExpression:rhs
                              modifier:NSDirectPredicateModifier
                              type:NSEqualToPredicateOperatorType
                              options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
        }
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    [self.eventFeedTableView reloadData];
}

#pragma mark - API calls

- (void)loadEventTopics:(DCFeedItem* )selectedFeedItem{
    NSLog(@"%@", selectedFeedItem.feedItemId);
    //    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:selectedFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            //            NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
            self.topics = [[NSMutableArray alloc] initWithArray:topics];
        }
    }];
}

#pragma mark - Event Feed delegate methods

- (void)mainFeedDidTapFeedITemThumbnail:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index{
    NSLog(@"ecFeedCell.feedItem.feedItemId: %@", ecFeedCell.feedItem.feedItemId);
    // EntityType = Digital, Person, Event
    if([ecFeedCell.feedItem.entityType isEqual:EntityType_DIGITAL]){
        // Play one-off episodes or navigate to TV Show view
        if([ecFeedCell.feedItem.digital.seasonNumber intValue] == 0 && [ecFeedCell.feedItem.digital.seasonNumber intValue] ==0){
            NSLog(@"CID: %@", [[ecFeedCell.feedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8]);
            [[ECAPI sharedManager] getPlaybackUrl:[[ecFeedCell.feedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8] callback:^(NSString *aPlaybackUrl, NSError *error) {
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:aPlaybackUrl]];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                AVPlayerViewController *avvc = [AVPlayerViewController new];
                avvc.player = player;
                [player play];
                [self presentViewController:avvc animated:YES completion:nil];
            }];
        }
        else{
            [[ECAPI sharedManager] getRelatedEpisodes:ecFeedCell.feedItem.digital.series callback:^(NSArray *searchResult, NSError *error) {
                if(error){
                    NSLog(@"Error: %@", error);
                }
                else{
                    /*
                     DCTVShowViewController * dcTVShowViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCTVShowViewController"];
                     dcTVShowViewController.selectedFeedItem = ecFeedCell.feedItem;
                     dcTVShowViewController.relatedFeedItems = searchResult;
                     [self presentViewController:dcTVShowViewController animated:YES completion:nil];
                     */
                    
                    DCNewTVShowViewController *dc = [self.storyboard instantiateViewControllerWithIdentifier:@"DCNewTVShowViewController"];
                    dc.selectedFeedItem = ecFeedCell.feedItem;
                    dc.relatedFeedItems = searchResult;
                    [self.navigationController pushViewController:dc animated:NO];
                }
            }];
        }
    }else{
        /*
        DCPersonDetailTableViewController * dcPersonDetailTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPersonDetailTableViewController"];
        dcPersonDetailTableViewController.selectedFeedItem = ecFeedCell.feedItem;
        //            UINavigationController *navigationController =
        //            [[UINavigationController alloc] initWithRootViewController:dcPersonDetailTableViewController];
        [self.navigationController pushViewController:dcPersonDetailTableViewController animated:YES];
        //[self presentViewController:navigationController animated:YES completion:nil];
       */
        
        if (index == 0 || index == 1  || index == 2){            
            IndividualFeedDetailsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"IndividualFeedDetailsViewController"];
            vc.mFeedItem = ecFeedCell.feedItem;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            DCInfluencersPersonDetailsViewController * dcInfluencersPersonDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DCInfluencersPersonDetailsViewController"];
            dcInfluencersPersonDetailsVC.mSelectedDCFeedItem = ecFeedCell.feedItem;
            [self.navigationController pushViewController:dcInfluencersPersonDetailsVC animated:YES];
        }
        /*
        DCInfluencersPersonDetailsViewController * dcInfluencersPersonDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DCInfluencersPersonDetailsViewController"];
        dcInfluencersPersonDetailsVC.mSelectedDCFeedItem = ecFeedCell.feedItem;
        [self.navigationController pushViewController:dcInfluencersPersonDetailsVC animated:YES];
         */
    }
}

//** CommentTap **//
- (void)mainFeedDidTapCommentsButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index{
    if (self.userEmail != nil){
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:ecFeedCell.feedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.topics = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topics objectAtIndex:1];
                
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = ecFeedCell.feedItem;
                dcChat.selectedTopic = topic;
                dcChat.topicId = topic.topicId;
                dcChat.isInfluencers = true;
                [self.navigationController pushViewController:dcChat animated:NO];
            }
        }];
        /*
         [[ECAPI sharedManager] fetchTopicsByFeedItemId:ecFeedCell.feedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
         if(error){
         NSLog(@"Error: %@", error);
         }
         else{
         self.topics = [[NSMutableArray alloc] initWithArray:topics];
         ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
         ECTopic *topic = [self.topics objectAtIndex:1];
         ecEventTopicCommentsViewController.selectedFeedItem = ecFeedCell.feedItem;
         ecEventTopicCommentsViewController.selectedTopic = topic;
         ecEventTopicCommentsViewController.topicId = topic.topicId;
         [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
         }
         }];
         */
    }else{
        self.saveFeedItem = ecFeedCell.feedItem;
        [[NSUserDefaults standardUserDefaults] setObject:ecFeedCell.feedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInVC:@"DCChatReactionViewController"];
        /*
         self.saveFeedItem = ecFeedCell.feedItem;
         [[NSUserDefaults standardUserDefaults] setObject:ecFeedCell.feedItem.feedItemId forKey:@"feedItemId"];
         [self pushToSignInVC:@"ECEventTopicCommentsViewController"];
         */
    }
}

//** FavTap **//
- (void)mainFeedDidTapFavoriteButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index{
    if (self.userEmail != nil){
        AddToPlaylistPopUpViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddToPlaylistPopUpViewController"];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFromBottom;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        self.tabBarController.tabBar.hidden = YES;
        [self.filterList setUserInteractionEnabled:NO];
        vc.playlistDelegate = self;
        vc.isFeedMode = true;
        vc.mFeedItemId = ecFeedCell.feedItem.feedItemId;
        [self addChildViewController:vc];
        vc.view.frame = self.view.frame;
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
        
        /*
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isFeedMode = true;
        dcPlaylistsTableViewController.isSignedInUser = true;
        dcPlaylistsTableViewController.feedItemId = ecFeedCell.feedItem.feedItemId;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcPlaylistsTableViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
         */
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:ecFeedCell.feedItem.feedItemId forKey:@"feedItemId"];
        [self pushToSignInVC:@"AddToPlaylistPopUpViewController"];
    }
}

//** LikeTap **//
- (void)mainFeedDidTapAttendanceButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index{
    if (self.userEmail != nil){
        [self setUserAttendanceResponse:ecFeedCell.feedItem.feedItemId];
        /*
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ecAttendanceDetailsViewController.selectedFeedItem = ecFeedCell.feedItem;
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
         */
    }else{
        self.saveFeedItem = ecFeedCell.feedItem;
        [self pushToSignInVC:@"SameVC"];
    }
}

//** ShareTap **//
- (void)mainFeedDidTapShareButton:(ECNewTableViewCell *)ecFeedCell index:(NSInteger)index {
    if (self.userEmail != nil){
        NSString* title = ecFeedCell.feedItem.person.name;
        NSString* link = ecFeedCell.feedItem.person.profilePic_url;
//        UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ecFeedCell.feedItem.person.profilePic_url]]];
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
                                             self.content.contentURL = [NSURL URLWithString:ecFeedCell.feedItem.person.profilePic_url];
                                             self.content.contentTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bundle display name"];
                                             self.content.contentDescription = ecFeedCell.feedItem.person.blurb;
                                             
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
                                            [self twitterSetup:[NSURL URLWithString:ecFeedCell.feedItem.person.profilePic_url] :ecFeedCell.feedItem.person.name];
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
    }else{
        [self pushToSignInVC:@"sameFeedVC"];
    }
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

/*
- (void)shareViaTwitter:(NSURL *)mURL :(NSString *)title{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:mURL]];
    [composer setImage:mImage];
    [composer setText:title];
    
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        [SVProgressHUD dismiss];
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
 */

-(void)showProfilePicImage:(ECFeedViewController *)vc ForImageUrl:(NSString *)url ForImageView:(UIButton *)button{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
//        imageView.image = inMemoryImage;
        [button setImage:[self imageWithImage:inMemoryImage scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
//        imageView.image = image;
        [button setImage:[self imageWithImage:image scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
        
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
//                                    imageView.image = image;
                                    [button setImage:[self imageWithImage:image scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
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
@end
