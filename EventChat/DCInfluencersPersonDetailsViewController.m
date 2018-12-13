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
#import "DCPersonBlurbTableViewCell.h"
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

@interface DCInfluencersPersonDetailsViewController ()
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *commentBarBtnItem;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSString *userEmailStr;
@property (nonatomic, strong) NSMutableArray *topicsArray;

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
    self.mBKImageView.layer.masksToBounds = YES;
    self.mBKImageView.layer.borderWidth = 5;
    self.mBKImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.mPersonTitleLabel setText:[NSString  stringWithFormat:@"%@", self.mSelectedDCFeedItem.person.name]];
    [self.mPersonDescriptionLabel setText:[NSString stringWithFormat:@"%@", self.mSelectedDCFeedItem.person.profession.title]];
//    [self showImageOnHeader:self.mSelectedDCFeedItem.mainImage_url];
    [self showImageOnHeader:self.mSelectedDCFeedItem.person.profilePic_url];
}

- (void)viewWillAppear:(BOOL)animated{
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    self.userEmailStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInUserEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.row == 0){
        static NSString *CellIdentifier = @"DCSocialTableViewCell";
        DCSocialTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [mCell configureCell:self.mSelectedDCFeedItem];
        return mCell;
//    }
//    else{
//        static NSString *CellIdentifier = @"DCSocialButtonTableViewCell";
//        DCSocialButtonTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        // Configure the cell...
//        [cell configure:_selectedFeedItem];
//        return cell;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 50.0;
    }
    else{
        return 0.0;
    }
}

#pragma mark:- Instance Methods

- (IBAction)didTapComment:(id)sender{
    if (![self.userEmailStr  isEqual: @""] || self.userEmailStr != nil){
        [[ECAPI sharedManager] fetchTopicsByFeedItemId:self.mSelectedDCFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                /*
                 // Push to comments view controller directly
                 
                 ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
                 ECTopic *topic = [topics objectAtIndex:1];
                 ecEventTopicCommentsViewController.selectedFeedItem = _selectedFeedItem;
                 ecEventTopicCommentsViewController.selectedTopic = topic;
                 ecEventTopicCommentsViewController.topicId = topic.topicId;
                 [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
                 */
                
                self.topicsArray = [[NSMutableArray alloc] initWithArray:topics];
                ECTopic *topic = [self.topicsArray objectAtIndex:1];
                DCChatReactionViewController *dcChat = [self.storyboard instantiateViewControllerWithIdentifier:@"DCChatReactionViewController"];
                dcChat.selectedFeedItem = self.saveSelectedFeedItem;
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

#pragma mark:- Instance Methods

- (IBAction)actionOnFollowBtn:(id)sender {
    NSLog(@"Comming soon...");
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
