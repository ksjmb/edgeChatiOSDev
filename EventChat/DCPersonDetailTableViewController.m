//
//  DCPersonDetailTableViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCPersonDetailTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DCFeedItem.h"
#import "ECUser.h"
#import "DCSocialButtonTableViewCell.h"
#import "DCPersonBlurbTableViewCell.h"
#import "DCYTPlayerTableViewCell.h"
#import "IonIcons.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"
#import "AppDelegate.h"
#import "ECEventTopicCommentsViewController.h"
#import "SignUpLoginViewController.h"

@interface DCPersonDetailTableViewController ()
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) IBOutlet UIImageView *topImageView;
@property (nonatomic, strong) IBOutlet UIButton *playSelectedEpisodeButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *commentBarButtonItem;
@property (nonatomic, assign) AppDelegate *appDelegate;
@end

#define kTableHeaderHeight 240.0

@implementation DCPersonDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _closeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_arrow_down  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapClose:)];
    //[self.navigationItem setLeftBarButtonItem:_closeBarButtonItem];
    _commentBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_chatboxes  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapComment:)];
    [self.navigationItem setRightBarButtonItem:_commentBarButtonItem];
    [self.navigationItem setTitle:@"Influencer's Profile"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.tableView.contentInset = UIEdgeInsetsMake(kTableHeaderHeight, 0, 0, 0);
//    self.tableView.contentOffset = CGPointMake(0, -kTableHeaderHeight);
//    [self updateHeaderView];
    self.tableView.estimatedRowHeight = 50;
    
    _topImageView.layer.cornerRadius = _topImageView.frame.size.width /2;
    _topImageView.layer.masksToBounds = YES;
    _topImageView.layer.borderWidth = 5;
    _topImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [_titleLabel setText:[NSString  stringWithFormat:@"%@", _selectedFeedItem.person.name]];
    [_descriptionLabel setText:[NSString stringWithFormat:@"%@", _selectedFeedItem.person.profession.title]];
    [self showImageOnHeader:_selectedFeedItem.mainImage_url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapComment:(id)sender{
    if (self.signedInUser != nil){
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:_selectedFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                // Push to comments view controller directly
                ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
                ECTopic *topic = [topics objectAtIndex:1];
                ecEventTopicCommentsViewController.selectedFeedItem = _selectedFeedItem;
                ecEventTopicCommentsViewController.selectedTopic = topic;
                ecEventTopicCommentsViewController.topicId = topic.topicId;
                
                [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
            }
        }];
    }else{
        [self pushToSignInVC];
    }
}

#pragma mark - Instance Methods

- (void)pushToSignInVC{
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpVC = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    signUpVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:signUpVC animated:true];
}

- (void)updateHeaderView{
    CGRect headerRect = CGRectMake(0, -kTableHeaderHeight, self.tableView.bounds.size.width, kTableHeaderHeight);
    if(self.tableView.contentOffset.y < -kTableHeaderHeight){
        headerRect.origin.y = self.tableView.contentOffset.y;
        headerRect.size.height = -self.tableView.contentOffset.y;
    }
    _headerView.frame = headerRect;
}

#pragma mark - UIScroll view delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self updateHeaderView];
//}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2){
        return 200.0;
    }
    else{
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        static NSString *CellIdentifier = @"DCPersonBlurbTableViewCell";
        DCPersonBlurbTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        [cell configureWithText:_selectedFeedItem.person.blurb];
        return cell;
    }
    else if(indexPath.row == 1){
        static NSString *CellIdentifier = @"DCSocialButtonTableViewCell";
        DCSocialButtonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        [cell configure:_selectedFeedItem];
        return cell;
    }
    else{
        static NSString *CellIdentifier = @"DCYTPlayerTableViewCell";
        DCYTPlayerTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        [cell configureWithFeedItem:_selectedFeedItem];
        return cell;
    }
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
}

@end
