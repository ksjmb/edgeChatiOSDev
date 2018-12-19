//
//  DCChatReactionViewController.m
//  EventChat
//
//  Created by Mindbowser on 19/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCChatReactionViewController.h"
#import "MessageTextView.h"
#import "TypingIndicatorView.h"
#import "Message.h"
#import <LoremIpsum/LoremIpsum.h>
#import "ECAPI.h"
#import "ECUser.h"
#import "ECColor.h"
#import "ECComment.h"
#import "NSDate+NVTimeAgo.h"
#import "MessageTableViewCell.h"
#import "ECCommonClass.h"
#import "ECSharedmedia.h"
#import "S3UploadImage.h"
#import "SVProgressHUD.h"
#import "S3UploadVideo.h"
#import "S3Constants.h"
#import "ECFullScreenImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECVideoData.h"
#import "Reachability.h"
#import "ECAPINames.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "IonIcons.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"
#import "DCPost.h"
#import "DCEventEntityObject.h"
#import "DCPlaylistsTableViewController.h"
#import "MessageTableViewCell.h"
#import "DCReactionTableViewCell.h"
#import "AppDelegate.h"
#import <Social/Social.h>

#define DEBUG_CUSTOM_TYPING_INDICATOR 0

@interface DCChatReactionViewController () <MessageTableViewCellDelegate>
{
    Reachability *reachabilityInfo;
    ECVideoData *videoData;
    NSMutableArray *array;
    BOOL isChild;
    NSDate *created_atFromString;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, weak) Message *editingMessage;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong) NSString* topEpisodeTitle;
@property (nonatomic, strong) NSString* topEpisodeDescription;
@property (nonatomic, strong) NSString* topEpisodeImageURL;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, strong) UIWindow *pipWindow;
@property (nonatomic, assign, getter = isInverted) BOOL inverted;
@property (nonatomic, weak) UIScrollView *scrollViewProxy;
@property int viewCount;
@property int counter;
@property (nonatomic, strong)NSMutableDictionary *viewReplyDict;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) BOOL isParentIdPresent;
@property (nonatomic, strong)NSMutableArray *attendanceArray;
//
@property (strong, nonatomic) ECFullScreenImageViewController *fullScreenImageViewController;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) NSArray *commands;
@property (nonatomic, strong) NSArray *searchResult;
@property (retain, nonatomic) UIImage *alertImage;
@property (retain, nonatomic) NSString *alertTitle;
@property (retain, nonatomic) NSArray *arrayOfButtonTitles;

@end

@implementation DCChatReactionViewController

#pragma mark:- ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    [self configureDataSource];
    self.mTextView.delegate = self;
    
    if(self.isPost){
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.dcPost.content]];
    }
    else{
        // EdgeTVChat custom code
        if ([[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] lowercaseString] isEqual:@"edgetvchat_stage" ]){
            if([self.selectedFeedItem.entityType isEqual:EntityType_DIGITAL]){
                [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.digital.episodeTitle]];
            }
            else if ([self.selectedFeedItem.entityType isEqual:EntityType_EVENT]){
                [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.event.name]];
            }
            else{
                [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.person.name]];
            }
        }
        else{
            [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.title]];
        }
    }
    [self initialSetup];
    [self initialSetupForReaction];
}

#pragma mark:- Instance Methods

- (void)initialSetup{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyComment) name:@"replyComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewReplyTap) name:@"viewReplyTap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTapFavImageView) name:@"didTapFavImageView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadVideoToS3) name:@"uploadVideoToS3" object:nil];
    
    // SLKTVC's configuration
    videoData = [ECVideoData sharedInstance];
    
    [self.chatTableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:messengerMediaCellIdentifier];
    [self.chatTableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    if([self.signedInUser.favoritedFeedItemIds containsObject:_selectedFeedItem.feedItemId]){
        [self.favButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }else{
        [self.favButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //    [self.favButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    
    // Format date
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    //Set imageView image
    if( _selectedFeedItem.digital.imageUrl != nil){
        _topEpisodeImageURL = _selectedFeedItem.digital.imageUrl;
        if (![_topEpisodeImageURL  isEqual: @""]){
            [self showImageOnHeader:_selectedFeedItem.digital.imageUrl];
        }else{
            _topEpisodeImageURL = _selectedFeedItem.person.profilePic_url;
            [self showImageOnHeader:_selectedFeedItem.person.profilePic_url];
        }
    }
    
    self.nameLabel.text = _selectedFeedItem.digital.episodeTitle;
    self.descriptionLabel.text = _selectedFeedItem.digital.episodeDescription;
    
    self.topEpisodeTitle = _selectedFeedItem.digital.episodeTitle;
    if ([self.topEpisodeTitle  isEqual: @""]){
        self.topEpisodeTitle = _selectedFeedItem.person.profession.title;
        self.nameLabel.text = _selectedFeedItem.person.profession.title;
    }
    self.topEpisodeDescription = _selectedFeedItem.digital.episodeDescription;
    if ([self.topEpisodeDescription  isEqual: @""]){
        self.topEpisodeDescription = _selectedFeedItem.person.blurb;
        self.descriptionLabel.text = _selectedFeedItem.person.blurb;
    }
    
    //    self.nameLabel.text = _selectedFeedItem.digital.episodeTitle;
    //    self.descriptionLabel.text = _selectedFeedItem.digital.episodeDescription;
    
    if (self.isCommingFromEvent == false){
        // No need to set date
        self.monthNameLabelWidthConstraint.constant = 0.0;
        self.monthDayLabelWidthConstraint.constant = 0.0;
    }else{
        // set date dirctly come from eventVC
        self.monthNameLabelWidthConstraint.constant = 60.0;
        self.monthDayLabelWidthConstraint.constant = 60.0;
        [self setEventDate];
        self.descriptionLabelHeightConstraint.constant = 21.0;
        [self.descriptionLabel setFont:[UIFont systemFontOfSize:14]];

        [self.nameLabel setText:self.selectedFeedItem.event.name];
        [self.descriptionLabel setText:[NSString stringWithFormat:@"%@, %@", self.selectedFeedItem.event.city, self.selectedFeedItem.event.state]];
        if(self.selectedFeedItem.event.mainImage != nil){
            [self showImageOnHeader:self.selectedFeedItem.event.mainImage];
        }
        //[self convertStringDateToNSDate:_selectedFeedItem.created_at];
    }
    
    //Add camera image to upload video or image
    /*
     NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.signedInUser.profilePicUrl]];
     UIImage *image = [UIImage imageWithData:data];
     self.profileImageView.layer.cornerRadius = 20.0;
     self.profileImageView.clipsToBounds = YES;
     
     if (image != nil){
     [self.profileImageView setImage:image];
     }else{
     self.profileImageView.image = [UIImage imageNamed:@"missing-profile.png"];
     }
     */
    
    self.inverted = YES;
    
    self.mTextView.layer.borderWidth = 0.50f;
    self.mTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    // Checing for internet availability
    reachabilityInfo = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myReachabilityDidChangedMethod)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reachabilityInfo startNotifier];
}

- (void)initialSetupForReaction{
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self getFeedItemAttendeeList];
    [self.attendeeListTableView setHidden:true];
}

- (void)convertStringDateToNSDate :(NSString *)strDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormatter dateFromString:strDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyy"];
    NSLog(@"%@", [formatter stringFromDate:date]);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *components = [calendar components:units fromDate:date];
    //    NSInteger year = [components year];
    NSInteger day = [components day];
    
    NSDateFormatter *weekDay = [[NSDateFormatter alloc] init];
    [weekDay setDateFormat:@"EEE"];
    NSDateFormatter *calMonth = [[NSDateFormatter alloc] init];
    [calMonth setDateFormat:@"MMMM"];
    
    self.monthNameLabel.text = [calMonth stringFromDate:date];
    NSString *monthDay = [NSString stringWithFormat:@"%lu", (long)day];
    [self.monthDayLabel setText:monthDay];
}

-(void)setEventDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *eventDate = [dateFormatter dateFromString:self.selectedFeedItem.event.startDate];
    [dateFormatter setDateFormat:@"MMM"];
    //    NSLog(@"month is %@", [[dateFormatter stringFromDate:eventDate] uppercaseString]);
    [self.monthNameLabel setText:[[dateFormatter stringFromDate:eventDate] uppercaseString]];
    [dateFormatter setDateFormat:@"dd"];
    //    NSLog(@"date is %@", [[dateFormatter stringFromDate:eventDate] uppercaseString]);
    [self.monthDayLabel setText:[[dateFormatter stringFromDate:eventDate] uppercaseString]];
}

- (void)setInverted:(BOOL)inverted
{
    if (_inverted == inverted) {
        return;
    }
    
    _inverted = inverted;
    [self slk_updateInsetAdjustmentBehavior];
    
    self.scrollViewProxy.transform = inverted ? CGAffineTransformMake(1, 0, 0, -1, 0, 0) : CGAffineTransformIdentity;
}

- (void)slk_updateInsetAdjustmentBehavior
{
    // Deactivate automatic scrollView adjustment for inverted table view
    if (@available(iOS 11.0, *)) {
        if (self.isInverted) {
            self.chatTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.chatTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        }
    }
}

- (void)myReachabilityDidChangedMethod {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
        [self.chatTableView reloadData];
    }
}

/*
 - (void)didPressLeftButton:(id)sender
 {
 // Notifies the view controller when the left button's action has been triggered, manually.
 
 UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image",@"Video",nil];
 [actionSheet showInView:self.view];
 
 //    [super didPressLeftButton:sender];
 }
 */

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        // Method to get images from camera or phone gallery.
        
        [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
            if (flag) {
                [self uploadImageToS3];
            }
        }];
        
    }else if(buttonIndex == 1){
        [[ECCommonClass sharedManager] showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Video" andResult:^(bool flag) {
            if (flag) {
                //[self uploadVideoToS3];
            }
        }];
        
    }
}

// Handling background Image upload
- (void) beginBackgroundUpdateTask {
    self.backgroundUpdateTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}
- (void) endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTaskId];
    self.backgroundUpdateTaskId = UIBackgroundTaskInvalid;
}

// Uploading Image On S3
-(void)uploadImageToS3{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Uploading Image"];
    //    NSString *uniqId = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    NSData * thumbImageData = UIImagePNGRepresentation([[ECSharedmedia sharedManager] mediaThumbImage]);
    [self beginBackgroundUpdateTask];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"]);
    [[S3UploadImage sharedManager] uploadImageForData:thumbImageData forFileName:[[ECSharedmedia sharedManager]mediaImageThumbURL] FromController:self andResult:^(bool flag) {
        
        if (flag) {
            
            NSData * imgData = [[ECSharedmedia sharedManager] imageData];
            [[S3UploadImage sharedManager]uploadImageForData:imgData forFileName:[[ECSharedmedia sharedManager] mediaImageURL] FromController:self andResult:^(bool flag) {
                
                if (flag) {
                    [self endBackgroundUpdateTask];
                    [SVProgressHUD dismiss];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    //                    NSDate *created_atFromString = [[NSDate alloc] init];
                    
                    NSString * imageURL = [NSString stringWithFormat:@"%@Images/%@",awsURL,[[ECSharedmedia sharedManager]mediaImageURL]];
                    
                    NSString * thumbImageURL = [NSString stringWithFormat:@"%@Images/%@",awsURL,[[ECSharedmedia sharedManager]mediaImageThumbURL]];
                    
                    // Hit API for new image comment
                    [[ECAPI sharedManager] postImageComment:self.topicId feedItemId:self.selectedFeedItem.feedItemId userId:self.signedInUser.userId displayName:self.signedInUser.firstName imageSizeInBytes:[[ECSharedmedia sharedManager] imageSizeInBytes] thumbnailURL:thumbImageURL  imageURL:imageURL commentType:@"image" parentId:[[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"] postId:self.dcPost.postId callback:^(NSDictionary *jsonDictionary, NSError *error) {
                        if (!error) {
                            if (jsonDictionary != nil && ([jsonDictionary[@"statusCode"] integerValue] == 200)) {
                                
                                Message *message = [Message new];
                                
                                message.displayName      = jsonDictionary [ECdata][ECDisplayName];
                                message.user             = self.signedInUser;
                                message.likeCount        = 0;
                                message.commentType      = jsonDictionary[ECdata][ECCommentType];
                                message.imageUrl         = jsonDictionary[ECdata][ECImageUrl];
                                message.imageSizeInBytes = [jsonDictionary[ECdata][ECImageSizeInBytes] integerValue];
                                message.thumbnailUrl     = jsonDictionary[ECdata][ECThumbnailUrl];
                                message.parantId         = jsonDictionary[ECdata][ECParantId];
                                message.created_at       = jsonDictionary[ECdata][ECCreated_at];
                                message.commentId        = jsonDictionary[ECdata][ECCommentId];
                                
                                int index = 1;
                                NSLog(@"%@",jsonDictionary[ECdata][ECParantId]);
                                for (int i = 0; i < [self.messages count]; i++) {
                                    Message *checkIndex = [self.messages objectAtIndex:i];
                                    if (![jsonDictionary[ECdata][ECParantId] isEqualToString:@"0"] && [checkIndex.commentId isEqualToString:jsonDictionary[ECdata][ECParantId]]) {
                                        index = i;
                                        for (int j = 0; j < [self.messages count]; j++) {
                                            Message *newcheckIndex = [self.messages objectAtIndex:j];
                                            if ([jsonDictionary[ECdata][ECParantId] isEqualToString:newcheckIndex.parantId]) {
                                                index = j;
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (index == 0) {
                                    index = 0;
                                }
                                else{
                                    index = index - 1;
                                }
                                
                                
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
                                UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
                                
                                [self.chatTableView beginUpdates];
                                [self.messages insertObject:message atIndex:index];
                                [self.chatTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                                [self.chatTableView endUpdates];
                                
                                [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                
                                // Fixes the cell from blinking (because of the transform, when using translucent cells)
                                // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
                                [self.chatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                [self.chatTableView resignFirstResponder];
                                [self.chatTableView reloadData];
                                [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeComment" object:nil];
                                NSLog(@"Success uploading Comment:%@",jsonDictionary);
                                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
                            }
                        }
                        if (error) {
                            NSLog(@"Error :%@",error.localizedDescription);
                            [self endBackgroundUpdateTask];
                            
                        }
                    }];
                    
                } else{
                    // Fail Condition ask for retry and cancel through alertView
                    [self showFailureOfS3:@"Image"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];
                    
                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
            [self showFailureOfS3:@"Image"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];
            
        }
    }];
}

// Uploading Video On S3
- (void) uploadVideoToS3
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Uploading Video"];
    
    //Uploading Thumbnail image
    NSData * thumbImageData = UIImagePNGRepresentation(videoData.mediaThumbImage);
    [self beginBackgroundUpdateTask];
    
    [[S3UploadVideo sharedManager] uploadImageForData:thumbImageData forFileName:videoData.mediaThumbImageURL FromController:self andResult:^(bool flag) {
        
        if (flag) {
            //Uploading Video
            NSError* error = nil;
            NSData * videoDatas = [NSData dataWithContentsOfURL:videoData.videoURL options:NSDataReadingUncached error:&error];
            [[S3UploadVideo sharedManager] uploadVideoForData:videoDatas forFileName:[[ECVideoData sharedInstance] mediaURL] FromController:self andResult:^(bool flag) {
                
                if (flag) {
                    [self endBackgroundUpdateTask];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    //                    NSDate *created_atFromString = [[NSDate alloc] init];
                    
                    NSString * imageURL = [NSString stringWithFormat:@"%@Videos/%@",awsURL,videoData.mediaURL];
                    
                    NSString * thumbImageURL = [NSString stringWithFormat:@"%@Videos/%@",awsURL,videoData.mediaThumbImageURL];
                    NSInteger videoBytes = (long)[videoDatas bytes];
                    
                    // Hit API for new video comment
                    [[ECAPI sharedManager] postImageComment:self.topicId feedItemId:self.selectedFeedItem.feedItemId userId:self.signedInUser.userId displayName:self.signedInUser.firstName imageSizeInBytes:videoBytes thumbnailURL:thumbImageURL  imageURL:imageURL commentType:@"video" parentId:[[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"] postId:self.dcPost.postId callback:^(NSDictionary *jsonDictionary, NSError *error) {
                        if (!error) {
                            if (jsonDictionary != nil && ([jsonDictionary[@"statusCode"] integerValue] == 200)) {
                                
                                Message *message = [Message new];
                                
                                message.displayName      = jsonDictionary [ECdata][ECDisplayName];
                                message.user             = self.signedInUser;
                                message.likeCount        = 0;
                                message.commentType      = jsonDictionary[ECdata][ECCommentType];
                                message.imageUrl         = jsonDictionary[ECdata][ECImageUrl];
                                message.videoUrl         = jsonDictionary[ECdata][ECVideoUrl];
                                message.imageSizeInBytes = [jsonDictionary[ECdata][ECImageSizeInBytes] integerValue];
                                message.thumbnailUrl     = jsonDictionary[ECdata][ECThumbnailUrl];
                                message.created_at       = jsonDictionary[ECdata][ECCreated_at];
                                message.parantId         = jsonDictionary[ECdata][ECParantId];
                                message.commentId        = jsonDictionary[ECdata][ECCommentId];
                                
                                int index = 1;
                                NSLog(@"%@",jsonDictionary[ECdata][ECParantId]);
                                for (int i = 0; i < [self.messages count]; i++) {
                                    Message *checkIndex = [self.messages objectAtIndex:i];
                                    if (![jsonDictionary[ECdata][ECParantId] isEqualToString:@"0"] && [checkIndex.commentId isEqualToString:jsonDictionary[ECdata][ECParantId]]) {
                                        index = i;
                                        for (int j = 0; j < [self.messages count]; j++) {
                                            Message *newcheckIndex = [self.messages objectAtIndex:j];
                                            if ([jsonDictionary[ECdata][ECParantId] isEqualToString:newcheckIndex.parantId]) {
                                                index = j;
                                                break;
                                            }
                                        }
                                        
                                    }
                                }
                                if (index == 0) {
                                    index = 0;
                                }
                                else{
                                    index = index - 1;
                                }
                                
                                
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
                                UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
                                
                                [self.chatTableView beginUpdates];
                                [self.messages insertObject:message atIndex:index];
                                [self.chatTableView resignFirstResponder];
                                [self.chatTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                                [self.chatTableView endUpdates];
                                
                                [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                
                                //                                 Fixes the cell from blinking (because of the transform, when using translucent cells)
                                //                              See https:
                                //github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
                                [self.chatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                [self.chatTableView reloadData];
                                [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                
                                
                                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                for (UIViewController *aViewController in allViewControllers) {
                                    if ([aViewController isKindOfClass:[DCChatReactionViewController class]]) {
                                        [self.navigationController popToViewController:aViewController animated:YES];
                                    }
                                }
                                
                                //Removing view of replying.
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeComment" object:nil];
                                NSLog(@"Success uploading Comment:%@",jsonDictionary);
                                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
                            }
                        }
                        if (error) {
                            NSLog(@"Error :%@",error.localizedDescription);
                            [self endBackgroundUpdateTask];
                            
                        }
                    }];
                    
                } else{
                    // Fail Condition ask for retry and cancel through alertView
                    [self showFailureOfS3:@"Video"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];
                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
            [self showFailureOfS3:@"Video"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];
            
        }
    }];
}

//Show Alert based on media type.
-(void)showFailureOfS3:(NSString *)mediaType{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Evnet Chat"
                                          message:[NSString stringWithFormat:@"%@ uploading Failed! \n Do you want to Retry?",mediaType]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Retry", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                                   // Re uploading if fail condition arises
                                   if ([mediaType isEqualToString:@"Image"]) {
                                       [self uploadImageToS3];
                                   }
                                   else{
                                       [self uploadVideoToS3];
                                   }
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark:- Segment Control Action Methods

- (IBAction)actionOnSegmentControl:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self setUserAttendanceResponse:@"Going"];
    } else if(self.segmentControl.selectedSegmentIndex == 1) {
        [self setUserAttendanceResponse:@"Maybe"];
    } else if(self.segmentControl.selectedSegmentIndex == 2) {
        [self setUserAttendanceResponse:@"Can't go"];
    }
}

#pragma mark:- Notification fire methods

-(void)replyComment {
    [self.mTextView resignFirstResponder];
    [self.mTextView becomeFirstResponder];
}

-(void)viewReplyTap {
    //    NSString *mCommentID = [[NSUserDefaults standardUserDefaults] valueForKey:@"commentIdForChat"];
    [self.chatTableView reloadData];
}

-(void)didTapFavImageView {
    [self configureDataSource];
}

- (void)configureDataSource {
    array = [[NSMutableArray alloc] init];
    self.viewReplyDict = [[NSMutableDictionary alloc] init];
    // Get comments
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading"];
    if(_isPost){
        [[ECAPI sharedManager] fetchCommentsByPostId:self.dcPost.postId callback:^(NSArray *comments, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                [[ECCommonClass sharedManager] alertViewTitle:@"Even Chat" message:@"Failed to load comments please try again."];
            }
            else {
                for (int i = 0; i < comments.count; i++) {
                    self.viewCount = 0;
                    ECComment *comment = [comments objectAtIndex:i];
                    isChild = NO;
                    [self assignValuesToMessageClass:comment];
                    for (int j = 0; j < comments.count; j++){
                        ECComment *checkchild = [comments objectAtIndex:j];
                        if ([checkchild.parentId isEqualToString:comment.commentId]) {
                            self.viewCount = self.viewCount + 1;
                            NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.viewCount];
                            self.viewReplyDict[comment.commentId] = count;
                            isChild = YES;
                            [self assignValuesToMessageClass:checkchild];
                        }
                    }
                }
                
                NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
                self.messages = [[NSMutableArray alloc] initWithArray:reversed];
                [self.chatTableView reloadData];
                if (self.messages.count > 0){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
                    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
                }
            }
        }];
    }
    else{
        [[ECAPI sharedManager] fetchCommentsByTopicId:self.topicId callback:^(NSArray *comments, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                [[ECCommonClass sharedManager] alertViewTitle:@"Even Chat" message:@"Failed to load comments please try again."];
            }
            else {
                for (int i = 0; i < comments.count; i++) {
                    self.viewCount = 0;
                    ECComment *comment = [comments objectAtIndex:i];
                    isChild = NO;
                    [self assignValuesToMessageClass:comment];
                    for (int j = 0; j < comments.count; j++){
                        ECComment *checkchild = [comments objectAtIndex:j];
                        if ([checkchild.parentId isEqualToString:comment.commentId]) {
                            self.viewCount = self.viewCount + 1;
                            NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.viewCount];
                            self.viewReplyDict[comment.commentId] = count;
                            isChild = YES;
                            [self assignValuesToMessageClass:checkchild];
                        }
                    }
                }
                
                NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
                self.messages = [[NSMutableArray alloc] initWithArray:reversed];
                [self.chatTableView reloadData];
                if (self.messages.count > 0){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
                    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
                }
            }
        }];
    }
}

-(void)assignValuesToMessageClass :(ECComment *)comment
{
    if ((isChild == NO && [comment.parentId isEqualToString:@"0"]) || isChild == YES) {
        Message *message  = [Message new];
        message.displayName     = comment.displayName;
        message.content         = comment.content;
        message.commentId       = comment.commentId;
        message.userId          = comment.userId;
        message.user            = comment.user;
        message.likeCount       = comment.likeCount;
        message.created_at      = comment.created_at;
        message.likedByIds      = comment.likedByIds;
        message.parantId        = comment.parentId;
        message.commentType     = comment.commentType;
        
        if ([comment.commentType isEqualToString:@"image"])
        {
            message.imageUrl         = comment.imageUrl;
            message.imageSizeInBytes = comment.imageSizeInBytes;
            message.thumbnailUrl     = comment.thumbnailUrl;
        }
        else
        {
            message.videoUrl         = comment.videoUrl;
            message.imageUrl         = comment.thumbnailUrl;
            message.imageSizeInBytes = comment.imageSizeInBytes;
            message.thumbnailUrl     = comment.thumbnailUrl;
        }
        [array addObject:message];
    }
}

#pragma mark:- IBActions Methods

- (IBAction)actionOnCommentsButton:(id)sender {
    self.reactionBottomLabel.backgroundColor = [UIColor whiteColor];
    self.commentsBottomLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:169.0/255.0 alpha:0.75];
    [self.attendeeListTableView setHidden:true];
    [self.segmentControl setHidden:true];
    [self.postCommentView setHidden:false];
    [self.chatTableView setHidden:false];
    self.attendeeList = nil;
    self.attendeeList = [[NSArray alloc] initWithArray:self.attendeeList];
    [self configureDataSource];
}

- (IBAction)actionOnReactionsButton:(id)sender {
    [self.view endEditing:YES];
    self.commentsBottomLabel.backgroundColor = [UIColor whiteColor];
    self.reactionBottomLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:113.0/255.0 blue:169.0/255.0 alpha:0.75];
    [self.postCommentView setHidden:true];
    [self.chatTableView setHidden:true];
    [self.attendeeListTableView setHidden:false];
    [self.messages removeAllObjects];
    [self getFeedItemAttendeeList];
}

- (IBAction)actionOnShareButton:(id)sender {
    [self openShareSheet];
}

- (IBAction)actionOnFavButton:(id)sender {
    DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
    dcPlaylistsTableViewController.isFeedMode = false;
    dcPlaylistsTableViewController.isSignedInUser = true;
    [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
}

- (IBAction)actionOnCameraButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image",@"Video",nil];
    [actionSheet showInView:self.view];
}

#pragma mark:- Message TableView Cell Delegate Methods

- (void)didTapLikeComment:(MessageTableViewCell *)messageTableViewCell {
    NSLog(@"IndexPath: %ld", (long)messageTableViewCell.indexPath.row);
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.chatTableView){
        if (self.messages.count > 0){
            NSString *mCommentCount = [NSString stringWithFormat:@"(%lu", (unsigned long)self.messages.count];
            mCommentCount = [mCommentCount stringByAppendingString:@")"];
            [self.commentsCountLabel setText:mCommentCount];
            [self.noDataAvailableLabel setHidden:true];
            [self.chatTableView setHidden:false];
        }else{
            [self.chatTableView setHidden:true];
            [self.noDataAvailableLabel setHidden:false];
        }
        return self.messages.count;
    }
    else{
        if (self.attendeeList.count > 0){
            NSString *mReactionCount = [NSString stringWithFormat:@"(%lu", (unsigned long)self.attendeeList.count];
            mReactionCount = [mReactionCount stringByAppendingString:@")"];
            [self.reactionsCountLabel setText:mReactionCount];
            //            [self.noDataAvailableLabel setHidden:true];
            //            [self.attendeeListTableView setHidden:false];
        }else{
            [self.attendeeListTableView setHidden:true];
            [self.noDataAvailableLabel setHidden:false];
        }
        return [self.attendeeList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.chatTableView){
        return [self messageCellForRowAtIndexPath:indexPath];
    }else{
        static NSString *cellIdentifier = @"DCReactionTableViewCell";
        DCReactionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[DCReactionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        ECAttendee *attendee = [self.attendeeList objectAtIndex:indexPath.row];
        [cell configureWithAttendee:attendee];
        return cell;
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell;
    Message *message = self.messages[(self.messages.count - 1) - indexPath.row];
    
    //Loading MediaCell
    if ([message.commentType isEqualToString:@"image"] || [message.commentType isEqualToString:@"video"]) {
        cell = (MessageTableViewCell *)[self.chatTableView dequeueReusableCellWithIdentifier:messengerMediaCellIdentifier forIndexPath:indexPath];
        
        //Removing subviews of cell because it was taking previous contents after scroll
        if ([cell.contentView subviews])
        {
            for (UIView *subview in [cell.contentView subviews]) {
                [subview removeFromSuperview];
            }
        }
        
        cell.message = message;
        [cell configureSubviewsForMediaCell];
        cell.delegate = self;
        cell.downloadButton.tag = indexPath.row;
    }
    //Loading TextCell.
    else{
        cell = (MessageTableViewCell *)[self.chatTableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier forIndexPath:indexPath];
        
        //Removing subviews of cell because it was taking previous contents after scroll
        if ([cell.contentView subviews]) {
            for (UIView *subview in [cell.contentView subviews]) {
                [subview removeFromSuperview];
            }
        }
        ECCommonClass *instance = [ECCommonClass sharedManager];
        instance.isFromChatVC = true;
        
        cell.message = message;
        [cell configureSubviewsForChatReaction];
        cell.delegate = self;
    }
    
    cell.cellIndexPath = indexPath;
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", message.user.firstName, message.user.lastName];
    cell.titleLabel.textColor = [UIColor darkGrayColor];
    cell.replyLabel.text = @"\u2022 Reply";
    [cell.viewReplyLabel setHidden:YES];
    
    if ([message.parantId isEqualToString:@"0"]){
        for (NSString* key in self.viewReplyDict) {
            id value = [self.viewReplyDict objectForKey:key];
            if ([message.commentId isEqualToString:key]){
                NSString *mViewReplyCount = [NSString stringWithFormat:@"\u2022 ViewReply(%@",value];
                mViewReplyCount = [mViewReplyCount stringByAppendingString:@")"];
                cell.viewReplyLabel.text = mViewReplyCount;
                [cell.viewReplyLabel setHidden:NO];
                break;
            }else{
                [cell.viewReplyLabel setHidden:YES];
            }
        }
    }
    
    cell.viewReplyLabel.textColor = [UIColor blueColor];
    
    created_atFromString = [dateFormatter dateFromString:message.created_at];
    NSString *ago = [created_atFromString formattedAsTimeAgo];
    
    NSArray *likedByIds = [NSArray arrayWithArray:message.likedByIds];
    
    if([likedByIds containsObject:self.signedInUser.userId]){
        cell.likeCountLabel.textColor = [UIColor lightGrayColor];
        cell.likeCountLabel.userInteractionEnabled = NO;
    }
    else{
        cell.likeCountLabel.textColor = [UIColor lightGrayColor];
    }
    
    if(message.likeCount != nil && ![message.likeCount  isEqual: @"0"]){
        NSString *mLikeCount = [NSString stringWithFormat:@"%@, Like(%@", ago, message.likeCount];
        mLikeCount = [mLikeCount stringByAppendingString:@")"];
        cell.likeCountLabel.text = mLikeCount;
        [cell.favImageView setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]]];
        [cell.favImageView setUserInteractionEnabled:false];
        //        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Like", ago, message.likeCount];
    }
    else{
        NSString *mLikeCount = [NSString stringWithFormat:@"%@, Like(%@", ago, @"0"];
        mLikeCount = [mLikeCount stringByAppendingString:@")"];
        cell.likeCountLabel.text = mLikeCount;
        //        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Like", ago, @"0"];
        [cell.favImageView setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]]];
        [cell.favImageView setUserInteractionEnabled:true];
    }
    
    // Configure cell if not flagged for offensive content
    if(![_signedInUser.blockedPostByUserId containsObject:message.userId]){
        //Configuring cell for image.
        if ([message.commentType isEqualToString:@"image"])
        {
            if (message.imageSizeInBytes < 1048576) {
                // show image without download option.
                [self showImageOnTheCell:cell ForImageUrl:message.imageUrl isFromDownloadButton:NO];
                cell.downloadButton.hidden = YES;
                cell.mediaImageView.userInteractionEnabled = YES;
                
            } else
                // Image size is less than 1 Mb
            {
                // Checking if Image is already in the Cache.
                BOOL imageContains = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]];
                if (imageContains) {
                    cell.mediaImageView.userInteractionEnabled = YES;
                    [self showImageOnTheCell:cell ForImageUrl:message.imageUrl isFromDownloadButton:NO];
                    cell.downloadButton.hidden = YES;
                } else{
                    NSLog(@"Thumb image with download Icon");
                    [self showImageOnTheCell:cell ForImageUrl:message.thumbnailUrl isFromDownloadButton:NO];
                    [cell.downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    cell.downloadButton.hidden = NO;
                }
            }
            // Adding gesture to image to open in another view
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            tapGestureRecognizer.numberOfTouchesRequired = 1;
            cell.mediaImageView.userInteractionEnabled = YES;
            [cell.mediaImageView addGestureRecognizer:tapGestureRecognizer];
            
        }
        //Configuring cell for Video
        else if ([message.commentType isEqualToString:@"video"])
        {
            //Showing Thumbimage of video and adding play button.
            NSLog(@"Thumb image with download Icon");
            [self.view bringSubviewToFront:cell.mediaImageView];
            [self showImageOnTheCell:cell ForImageUrl:message.thumbnailUrl isFromDownloadButton:NO];
            [cell.downloadButton setBackgroundImage:[UIImage imageNamed:@"play-button"] forState:UIControlStateNormal];
            cell.downloadButton.hidden = NO;
            
            //            // Adding gesture to video to open in another view
            //            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTap:)];
            //            tapGestureRecognizer.numberOfTapsRequired = 1;
            //            tapGestureRecognizer.numberOfTouchesRequired = 1;
            //            cell.mediaImageView.userInteractionEnabled = YES;
            //            [cell.mediaImageView addGestureRecognizer:tapGestureRecognizer];
        }
        //Displaying comment text.
        else
        {
            cell.bodyLabel.text = message.content;
            cell.bodyLabel.textColor = [UIColor lightGrayColor];
        }
    }
    else{
        cell.bodyLabel.text = @"[Removed due to offensive content]";
    }
    
    //    cell.bodyLabel.text = message.content;
    //    cell.bodyLabel.textColor = [UIColor lightGrayColor];
    
    // Set profile pic
    [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:message.user.profilePicUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    
    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.chatTableView.transform;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.chatTableView]) {
        // Return NO if you do not want the specified item to be editable.
        Message *message = self.messages[indexPath.row];
        if([self.signedInUser.userId isEqual:message.userId]){
            return NO;
        }
        else{
            return NO;
        }
    }else{
        return NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.chatTableView]) {
        
        //Height for image or video cell.
        Message *message = self.messages[(self.messages.count - 1) - indexPath.row];
        if ([message.commentType isEqualToString:@"image"] || [message.commentType isEqualToString:@"video"]) {
            return 330;
        }
        
        // check parent commentID with child parentID
        NSLog(@"message.parantId: %@", message.parantId);
        ECCommonClass *instance = [ECCommonClass sharedManager];
        
        if ([message.parantId isEqualToString:@"0"] || [instance.parentCommentIDs containsObject:message.parantId]){
            //show list
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.alignment = NSTextAlignmentLeft;
            
            CGFloat pointSize = [MessageTableViewCell defaultFontSize];
            
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:pointSize],
                                         NSParagraphStyleAttributeName: paragraphStyle};
            
            CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
            width -= 25.0;
            
            CGRect titleBounds = [message.displayName boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
            CGRect bodyBounds = [message.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
            CGRect likeLabelBounds = [message.likeCount boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
            
            if (message.content.length == 0) {
                return 0.0;
            }
            
            CGFloat height = CGRectGetHeight(titleBounds);
            height += CGRectGetHeight(bodyBounds);
            height += CGRectGetHeight(likeLabelBounds);
            height += 50.0;
            
            if (height < kMessageTableViewCellMinimumHeight) {
                height = kMessageTableViewCellMinimumHeight;
            }
            
            return height;
        }else{
            // hide child list
            return 0.0;
        }
    }else {
        return 65.0;
    }
}

// Displaying Image on Cell
-(void)showImageOnTheCell:(MessageTableViewCell *)cell ForImageUrl:(NSString *)url isFromDownloadButton:(BOOL)downloadFlag{
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor colorWithRed:171.0/255.0 green:57.0/255.0 blue:158.0/255.0 alpha:1.0];
    [indicator startAnimating];
    [indicator setCenter: CGPointMake(170, 160)];
    
    [cell.contentView addSubview:indicator];
    [cell.contentView bringSubviewToFront:indicator];
    [indicator setCenter: CGPointMake(170, 160)];
    
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.mediaImageView.image = inMemoryImage;
        [indicator removeFromSuperview];
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.mediaImageView.image = image;
        [indicator removeFromSuperview];
        
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
                                [indicator removeFromSuperview];
                                if (image) {
                                    cell.mediaImageView.image = image;
                                    cell.mediaImageView.layer.borderWidth = 1.0;
                                    cell.mediaImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again")
                                        ;
                                        if (downloadFlag) {
                                            cell.downloadButton.hidden = NO;
                                        }
                                        return;
                                    }
                                }
                            }];
    }
}

-(void)playButtonPressed:(Message *)message
{
    BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
    if (isInternetAvailable) {
        //        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:message.videoUrl]];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:message.content]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinishVideoPlay)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        //mpvc.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        //[self presentMoviePlayerViewControllerAnimated:mpvc];
        [self presentViewController:avvc animated:YES completion:nil];
        
        
    } else {
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
    }
}

-(void)didFinishVideoPlay{
    [self.navigationController dismissViewControllerAnimated:false completion:nil];
}

// Clicking Downolad Button on Image
-(void)downloadButtonClickedForImage:(NSInteger)imageIndex forCell:(MessageTableViewCell *)cell{
    
    BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
    if (isInternetAvailable) {
        NSLog(@"Button clicked tag :%ld",(long)imageIndex);
        Message *message = self.messages[imageIndex];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color = [UIColor colorWithRed:171.0/255.0 green:57.0/255.0 blue:158.0/255.0 alpha:1.0];
        [indicator startAnimating];
        [indicator setCenter: CGPointMake(170, 160)];
        [cell.contentView addSubview:indicator];
        [cell.contentView bringSubviewToFront:indicator];
        [indicator setCenter: CGPointMake(170, 160)];
        
        if (cell.downloadButton.tag == imageIndex) {
            cell.downloadButton.hidden = YES;
        }
        
        SDImageCache *cache = [SDImageCache sharedImageCache];
        UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:message.imageUrl];
        // resolves the SDWebImage issue of image missing
        if (inMemoryImage)
        {
            cell.mediaImageView.image = inMemoryImage;
            [indicator removeFromSuperview];
            if (cell.downloadButton.tag == imageIndex) {
                cell.downloadButton.hidden = YES;
            }
            
        }
        else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]]){
            UIImage *image = [cache imageFromDiskCacheForKey:message.imageUrl];
            cell.mediaImageView.image = image;
            [indicator removeFromSuperview];
            if (cell.downloadButton.tag == imageIndex) {
                cell.downloadButton.hidden = YES;
            }
            
        }else{
            NSURL *url = [NSURL URLWithString:message.imageUrl];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager.imageDownloader setDownloadTimeout:20];
            [manager downloadImageWithURL:url
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     // progression tracking code
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    [indicator removeFromSuperview];
                                    
                                    if (image) {
                                        if (cell.downloadButton.tag == imageIndex) {
                                            cell.downloadButton.hidden = YES;
                                        }
                                        cell.mediaImageView.image = image;
                                        cell.mediaImageView.layer.borderWidth = 1.0;
                                        cell.mediaImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                    }
                                    else {
                                        if (cell.downloadButton.tag == imageIndex) {
                                            cell.downloadButton.hidden = NO;
                                        }
                                    }
                                }];
        }
    }else{
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
    }
}

// Handling image tap which will open image in another larger view

- (void)handleImageTap:(UIGestureRecognizer *)sender {
    
    CGPoint location = [sender locationInView:self.view];
    if (CGRectContainsPoint([self.view convertRect:self.chatTableView.frame fromView:self.chatTableView.superview], location))
    {
        CGPoint locationInTableview = [self.chatTableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:locationInTableview];
        if (indexPath){
            
            Message *message = [Message new];
            //            message = [self.messages objectAtIndex:indexPath.row];
            message = self.messages[(self.messages.count - 1) - indexPath.row];
            
            BOOL imageContains = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]];
            if (imageContains) {
                self.fullScreenImageViewController = [[ECFullScreenImageViewController alloc] initWithNibName:@"ECFullScreenImageViewController" bundle:nil];
                self.fullScreenImageViewController.imagePath = message.imageUrl;
                [self presentViewController:self.fullScreenImageViewController animated:YES completion:nil];
            }
        }
    }
}

- (void)handleVideoTap:(UIGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    if (CGRectContainsPoint([self.view convertRect:self.chatTableView.frame fromView:self.chatTableView.superview], location))
    {
        CGPoint locationInTableview = [self.chatTableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.chatTableView indexPathForRowAtPoint:locationInTableview];
        if (indexPath){
            BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
            if (isInternetAvailable) {
                Message *message = [Message new];
                //                message = [self.messages objectAtIndex:indexPath.row];
                message = self.messages[(self.messages.count - 1) - indexPath.row];
                MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:message.videoUrl]];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(didFinishVideoPlay)
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                                           object:nil];
                
                mpvc.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                [self presentMoviePlayerViewControllerAnimated:mpvc];
            } else {
                [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
            }
        }
    }
}

#pragma mark - API Methods

-(void)getFeedItemAttendeeList{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading"];
    
    [[ECAPI sharedManager] getAttendeeList:self.selectedFeedItem.feedItemId callback:^(NSArray *attendees, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSLog(@"Error saving response: getFeedItemAttendeeList: %@", error);
        } else {
            self.attendeeList = [[NSArray alloc] initWithArray:attendees copyItems:true];
            self.attendanceArray = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [self.attendeeList count]; i++){
                ECAttendee *attList = [self.attendeeList objectAtIndex:i];
                [self.attendanceArray addObject:attList.userId];
            }
            
            if ([self.attendanceArray containsObject:self.signedInUser.userId]){
                [self.segmentControl setHidden:false];
            }else{
                [self.segmentControl setHidden:true];
            }
            [self.attendeeListTableView reloadData];
        }
    }];
}

-(void)setUserAttendanceResponse:(NSString *)selectedResponseStr{
    [[ECAPI sharedManager] setAttendeeResponse:self.signedInUser.userId feedItemId:self.selectedFeedItem.feedItemId response:selectedResponseStr callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving response: ChatReaction: %@", error);
        } else {
            [self getFeedItemAttendeeList];
        }
    }];
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(IQTextView *)textView {
    if ([_mTextView.text  isEqual: @"Message"]) {
        [_mTextView setText:@""];
    }
    NSLog(@"did begin editing");
}

- (BOOL)textViewShouldBeginEditing:(IQTextView *)textView{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(IQTextView *)textView{
    if ([_mTextView.text  isEqual: @""]) {
        [_mTextView setText:@"Message"];
    }
    
    NSLog(@"did end editing");
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textView:(IQTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        NSLog(@"Return pressed, do whatever you like here");
        return NO;
    }
    
    return YES;
}

- (IBAction)actionOnPostButton:(id)sender {
    if ([[self.mTextView.text copy] isEqualToString:@"Message"]){
        NSLog(@"enter your message...!");
    }else{
        // Format date
        NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
        [dateFormatters setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *created_atFromStrings = [[NSDate alloc] init];
        
        Message *message = [Message new];
        message.displayName = self.signedInUser.firstName;
        message.content = [self.mTextView.text copy];
        message.user = self.signedInUser;
        message.created_at = [dateFormatters stringFromDate:created_atFromStrings];
        message.likeCount = 0;
        message.parantId = [[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"];
        
        NSLog(@"self.topicId: postButtonClicked: %@", self.topicId);
        [[ECAPI sharedManager] postComment:self.topicId feedItemId:self.selectedFeedItem.feedItemId userId:self.signedInUser.userId displayName:message.displayName content:message.content parentId:message.parantId postId:self.dcPost.postId callback:^(NSDictionary *jsonDictionary, NSError *error){
            if (error) {
                NSLog(@"Error adding user: %@", error);
            } else {
                Message *message = [Message new];
                message.displayName      = jsonDictionary [ECdata][ECDisplayName];
                message.user             = self.signedInUser;
                message.likeCount        = 0;
                message.commentType      = jsonDictionary[ECdata][ECCommentType];
                message.parantId         = jsonDictionary[ECdata][ECParantId];
                message.created_at       = jsonDictionary[ECdata][ECCreated_at];
                message.content          = jsonDictionary[ECdata][ECContent];
                message.eventId          = jsonDictionary[ECdata][ECEventId];
                message.userId           = jsonDictionary[ECdata][ECUserId];
                message.commentId        = jsonDictionary[ECdata][ECCommentId];
                
                for (NSString* key in self.viewReplyDict) {
                    NSString *value = [self.viewReplyDict objectForKey:key];
                    if ([message.parantId isEqualToString:key]){
                        int mValue = [value intValue];
                        NSString *newVal = [NSString stringWithFormat:@"%lu", (unsigned long)mValue + 1];
                        self.viewReplyDict[message.parantId] = newVal;
                        self.isParentIdPresent = true;
                        break;
                    }
                }
                
                if (self.isParentIdPresent == false){
                    self.viewReplyDict[message.parantId] = @"1";
                }
                
                NSLog(@"[self.messages count]: %lu",(unsigned long)[self.messages count]);
                //                NSLog(@"jsonDictionary[ECdata][ECParantId]: %@",jsonDictionary[ECdata][ECParantId]);
                
                int index = 0;
                for (int i = 0; i < [self.messages count]; i++) {
                    Message *checkIndex = [self.messages objectAtIndex:i];
                    if (![jsonDictionary[ECdata][ECParantId] isEqualToString:@"0"] && [checkIndex.commentId isEqualToString:jsonDictionary[ECdata][ECParantId]]) {
                        index = i;
                        for (int j = 0; j < [self.messages count]; j++) {
                            Message *newcheckIndex = [self.messages objectAtIndex:j];
                            if ([jsonDictionary[ECdata][ECParantId] isEqualToString:newcheckIndex.parantId]) {
                                index = j;
                                break;
                            }
                        }
                    }
                }
                if (index == 0) {
                    index = 0;
                }
                else{
                    index = index;
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
                UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
                
                [self.chatTableView beginUpdates];
                [self.messages insertObject:message atIndex:index];
                [self.chatTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                [self.chatTableView endUpdates];
                [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                
                // Fixes the cell from blinking (because of the transform, when using translucent cells)
                // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
                [self.chatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.mTextView resignFirstResponder];
                [self.mTextView setText:@"Message"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeComment" object:nil];
                NSLog(@"Success uploading Comment: jsonDictionary: %@",jsonDictionary);
                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
                
                [self.chatTableView reloadData];
                if (self.messages.count > 0){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
                    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:false];
                }
            }
        }];
    }
}

#pragma mark - Lifeterm

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark:- SDWebImage

// Displaying Image on Header
-(void)showImageOnHeader:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        _mImageView.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        _mImageView.image = image;
        
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
                                    _mImageView.image = image;
                                    _mImageView.layer.borderWidth = 1.0;
                                    _mImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image,please try again...");
                                        return;
                                    }
                                }
                            }];
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
                                         [self.shareDialog setShareContent:self.content];
                                         [self.shareDialog setFromViewController:self];
                                         [self.shareDialog setDelegate:self];
                                         [self.shareDialog show];
                                     }];
    
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Twitter", @"Twitter action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"Twitter action...");
                                        [self shareViaTwitter:[NSURL URLWithString:_topEpisodeImageURL] :_topEpisodeTitle];
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

- (void)shareViaTwitter:(NSURL *)mURL :(NSString *)mTitle{
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    UIImage *mImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:mURL]];
    [tweetSheet addImage:mImage];
    [tweetSheet setInitialText:mTitle];
    
    [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
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

#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title {
    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView {
    NSLog(@"Done Button Clicked");
    if(alertView.tag == 1){
        if(![_signedInUser.blockedPostByUserId containsObject:_blockedMessage.userId]){
            [_signedInUser.blockedPostByUserId addObject:_blockedMessage.userId];
            //Sync user to DB
            [[ECAPI sharedManager] updateUser:self.signedInUser callback:^(ECUser *ecUser, NSError *error) {
                if (error) {
                    NSLog(@"Error adding user: %@", error);
                    NSLog(@"%@", error);
                }
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.delegate = self;
                alert.tag = 2;
                [alert makeAlertTypeWarning];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:@"Would also like to report this user to EdgeChat?"
                       withCustomImage:_alertImage
                   withDoneButtonTitle:@"YES"
                            andButtons:self.arrayOfButtonTitles];
                
                [self.chatTableView reloadData];
            }];
        }
    }else if (alertView.tag == 2){
        //
        NSLog(@"Report Tapped");
        NSLog(@"CommentId: %@ - UserId: %@", _blockedMessage.commentId, self.signedInUser.userId);
        [[ECAPI sharedManager] reportComment:_blockedMessage.commentId userId:self.signedInUser.userId callback:^(NSDictionary *jsonDictionarty, NSError *error){
            
            if (error) {
                NSLog(@"Error adding user: %@", error);
                NSLog(@"%@", error);
            } else {
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:[NSString stringWithFormat:@"%@ has been reported to EdgeChat.", _blockedMessage.displayName]
                       withCustomImage:nil
                   withDoneButtonTitle:nil
                            andButtons:nil];
                NSLog(@"%@",jsonDictionarty);
            }
        }];
    }
    else if (alertView.tag == 3){
        
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView {
    NSLog(@"Alert Dismissed");
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView {
    NSLog(@"Alert Will Appear");
}

@end
