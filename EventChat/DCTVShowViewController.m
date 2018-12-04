//
//  DCTVShowViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/7/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCTVShowViewController.h"
#import "IonIcons.h"
#import "DCTVShowEpisodeTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "DCStreamingPlayerViewController.h"
#import "DCSeasonSelectorTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECEventTopicCommentsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#define kTableHeaderHeight 300.0

@interface DCTVShowViewController ()
@property (nonatomic, weak) IBOutlet UITableView *episodeTableView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, strong) UINavigationItem *navigationItem;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) IBOutlet UIImageView *topImageView;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) IBOutlet UIButton *playSelectedEpisodeButton;
@property (nonatomic, weak) IBOutlet UILabel *episodeTitle;
@property (nonatomic, weak) IBOutlet UILabel *episodeDescription;
@property (nonatomic, strong) NSMutableArray *episodesInSeason;
@property (nonatomic, strong) NSArray *seasonsInSeries;
@property (nonatomic, strong) UIToolbar *topToolBar;
@end

@implementation DCTVShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentSeason = 1;
    _seasonsInSeries = [_relatedFeedItems valueForKeyPath:@"@distinctUnionOfObjects.digital.seasonNumber"];
    _headerView = self.episodeTableView.tableHeaderView;
    _episodeTableView.tableHeaderView = nil;
    [_episodeTableView addSubview:_headerView];
    _episodeTableView.contentInset = UIEdgeInsetsMake(kTableHeaderHeight, 0, 0, 0);
    _episodeTableView.contentOffset = CGPointMake(0, -kTableHeaderHeight);
    [self updateHeaderView];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    // Do any additional setup after loading the view.
    self.closeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_chevron_down  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapClose:)];
    [self.closeButton setBackgroundImage:[IonIcons imageWithIcon:ion_close_circled  size:30.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(didTapClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.playSelectedEpisodeButton setBackgroundImage:[IonIcons imageWithIcon:ion_play  size:60.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    for(int i = 0; i < [_relatedFeedItems count]; i++){
        DCFeedItem *feedItem = [_relatedFeedItems objectAtIndex:i];
        if([feedItem.digital.seasonNumber isEqual:_selectedFeedItem.digital.seasonNumber] && [feedItem.digital.episodeNumber isEqual:@"1"]){
            [_episodeTitle setText:_selectedFeedItem.digital.series];
            [_episodeDescription setText:_selectedFeedItem.digital.seriesDescription];
            if( feedItem.digital.imageUrl != nil){
                [self showImageOnHeader:feedItem.digital.imageUrl];
            }
        }
    }
    self.topToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,20, self.view.frame.size.width, 44)];
    [self.topToolBar setBackgroundImage:[UIImage new]
                     forToolbarPosition:UIToolbarPositionAny
                             barMetrics:UIBarMetricsDefault];
    
    [self.topToolBar setBackgroundColor:[UIColor clearColor]];
    [self.topToolBar setItems:@[self.closeBarButtonItem]];
    [self.view addSubview:self.topToolBar];
    [self loadSelectedSeason:[_selectedFeedItem.digital.seasonNumber intValue]];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidAppear:(BOOL)animated{
    
}
- (void)viewWillAppear:(BOOL)animated{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}
- (void)updateHeaderView{
    CGRect headerRect = CGRectMake(0, -kTableHeaderHeight, _episodeTableView.bounds.size.width, kTableHeaderHeight);
    if(_episodeTableView.contentOffset.y < -kTableHeaderHeight){
        headerRect.origin.y = _episodeTableView.contentOffset.y;
        headerRect.size.height = -_episodeTableView.contentOffset.y;
    }
    _headerView.frame = headerRect;
}

- (IBAction)didTapPlayVideo:(id)sender{
    NSLog(@"CID: %@", [[_selectedFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8]);
    [[ECAPI sharedManager] getPlaybackUrl:[[_selectedFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8] callback:^(NSString *aPlaybackUrl, NSError *error) {
//        DCStreamingPlayerViewController *dcStreamingPlayerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCStreamingPlayerViewController"];
//        dcStreamingPlayerViewController.playbackUrl = aPlaybackUrl;
//        dcStreamingPlayerViewController.episodeTitle = _selectedFeedItem.digital.episodeTitle;
////        UINavigationController *navigationController =
////        [[UINavigationController alloc] initWithRootViewController:dcStreamingPlayerViewController];
//        [self presentViewController:dcStreamingPlayerViewController animated:YES completion:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:aPlaybackUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(moviePlaybackDidFinish)
//                                                     name:AVPlayerItemDidPlayToEndTimeNotification
//                                                   object:nil];
        
        //mpvc.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        
        //[self presentMoviePlayerViewControllerAnimated:mpvc];
        [self presentViewController:avvc animated:YES completion:nil];
    }];
    
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

#pragma mark - AF
- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager)
    {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return _operationManager;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Table view data source
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 260.0;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if
//    return 2;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 44.0;
    }
    else{
        return 260.0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    else{
        return [_episodesInSeason count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        static NSString *cellIdentifier = @"Seasons";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        [cell.textLabel setText:[NSString stringWithFormat:@"Season %@", [_seasonsInSeries objectAtIndex:_currentSeason - 1]]];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else{
        static NSString *CellIdentifier = @"DCTVShowEpisodeTableViewCell";
        DCTVShowEpisodeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        DCFeedItem *dcFeedItem = [_episodesInSeason objectAtIndex:indexPath.row];
        if (!cell) {
            cell = [[DCTVShowEpisodeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        cell.delegate = self;
        [cell configureWithFeedItem:dcFeedItem];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        DCSeasonSelectorTableViewController *dcSeasonSelectorTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCSeasonSelectorTableViewController"];
        dcSeasonSelectorTableViewController.seasons = _seasonsInSeries;
        dcSeasonSelectorTableViewController.currentSeason = _currentSeason;
        dcSeasonSelectorTableViewController.delegate = self;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:dcSeasonSelectorTableViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - UIScroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateHeaderView];
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSIndexPath *firstVisibleIndexPath = [[self.episodeTableView indexPathsForVisibleRows] objectAtIndex:0];
//    NSLog(@"first visible cell's section: %i, row: %i", firstVisibleIndexPath.section, firstVisibleIndexPath.row);
//    if(firstVisibleIndexPath.row > 4){
//        [self.navigationBar setTranslucent:NO];
//    }
//}

#pragma mark - DCSeasonSelectorTableViewControllerlDelegate methods
- (void)loadSelectedSeason:(int)selectedSeason{
    _currentSeason = selectedSeason;
    [self loadEpisodesInSelectedSeasion:[NSString stringWithFormat:@"%d", _currentSeason]];
}

#pragma mark - DCSeasonSelectorTableViewControllerlDelegate methods

- (void)playVideoForSelectedEpisode:(DCTVShowEpisodeTableViewCell *)dcTVShowEpisodeTableViewCell index:(NSInteger)index{
    DCFeedItem *dcFeedItem = [_episodesInSeason objectAtIndex:index];
    NSLog(@"CID: %@", [[dcFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8]);
    [[ECAPI sharedManager] getPlaybackUrl:[[dcFeedItem.digital.imageUrl componentsSeparatedByString:@"/"] objectAtIndex:8] callback:^(NSString *aPlaybackUrl, NSError *error) {
//        DCStreamingPlayerViewController *dcStreamingPlayerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCStreamingPlayerViewController"];
//        dcStreamingPlayerViewController.playbackUrl = aPlaybackUrl;
//        dcStreamingPlayerViewController.episodeTitle = dcFeedItem.digital.episodeTitle;
//        [self presentViewController:dcStreamingPlayerViewController animated:YES completion:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:aPlaybackUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
        [self presentViewController:avvc animated:YES completion:nil];
    }];
}

- (void)didTapCommentsButton:(DCTVShowEpisodeTableViewCell *)dcTVShowEpisodeTableViewCell index:(NSInteger)index{
    DCFeedItem *dcFeedItem = [_episodesInSeason objectAtIndex:index];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:dcFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            // Push to comments view controller directly
            ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
            ECTopic *topic = [[[NSMutableArray alloc] initWithArray:topics] objectAtIndex:1];
            ecEventTopicCommentsViewController.selectedFeedItem = dcFeedItem;
            ecEventTopicCommentsViewController.selectedTopic = topic;
            ecEventTopicCommentsViewController.topicId = topic.topicId;
            UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:ecEventTopicCommentsViewController];
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    }];
    //[self cloneEventBriteEventToDB:ecFeedCell index:index];
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
                                        NSLog(@"Problem downloading Image, play try again");
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
