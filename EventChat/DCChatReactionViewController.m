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
    
    _topEpisodeTitle = _selectedFeedItem.digital.episodeTitle;
    if ([_topEpisodeTitle  isEqual: @""]){
        _topEpisodeTitle = _selectedFeedItem.person.profession.title;
        self.nameLabel.text = _selectedFeedItem.person.profession.title;
    }
    _topEpisodeDescription = _selectedFeedItem.digital.episodeDescription;
    if ([_topEpisodeDescription  isEqual: @""]){
        _topEpisodeDescription = _selectedFeedItem.person.blurb;
        self.descriptionLabel.text = _selectedFeedItem.person.blurb;
    }
    
//    self.nameLabel.text = _selectedFeedItem.digital.episodeTitle;
//    self.descriptionLabel.text = _selectedFeedItem.digital.episodeDescription;
    [self convertStringDateToNSDate:_selectedFeedItem.created_at];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.signedInUser.profilePicUrl]];
    UIImage *image = [UIImage imageWithData:data];
    self.profileImageView.layer.cornerRadius = 20.0;
    self.profileImageView.clipsToBounds = YES;
    if (image != nil){
        [self.profileImageView setImage:image];
    }else{
        self.profileImageView.image = [UIImage imageNamed:@"missing-profile.png"];
    }
    
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

#pragma mark:- Notification fire methods

-(void)replyComment {
    [self.mTextView resignFirstResponder];
    [self.mTextView becomeFirstResponder];
}

-(void)viewReplyTap {
    //    NSString *mCommentID = [[NSUserDefaults standardUserDefaults] valueForKey:@"commentIdForChat"];
    [self.chatTableView reloadData];
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
    self.commentsBottomLabel.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:82.0/255.0 blue:45.0/255.0 alpha:0.75];
    [self.attendeeListTableView setHidden:true];
    [self.chatTableView setHidden:false];
    self.attendeeList = nil;
    self.attendeeList = [[NSArray alloc] initWithArray:self.attendeeList];
    [self configureDataSource];
}

- (IBAction)actionOnReactionsButton:(id)sender {
    [self.view endEditing:YES];
    self.commentsBottomLabel.backgroundColor = [UIColor whiteColor];
    self.reactionBottomLabel.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:82.0/255.0 blue:45.0/255.0 alpha:0.75];
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
    if(message.likeCount != nil){
        NSString *mLikeCount = [NSString stringWithFormat:@"%@, Like(%@", ago, message.likeCount];
        mLikeCount = [mLikeCount stringByAppendingString:@")"];
        cell.likeCountLabel.text = mLikeCount;
//        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Like", ago, message.likeCount];
    }
    else{
        NSString *mLikeCount = [NSString stringWithFormat:@"%@, Like(%@", ago, @"0"];
        mLikeCount = [mLikeCount stringByAppendingString:@")"];
        cell.likeCountLabel.text = mLikeCount;
//        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Like", ago, @"0"];
    }
    
    cell.bodyLabel.text = message.content;
    cell.bodyLabel.textColor = [UIColor lightGrayColor];
    
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

//- (NSDictionary)getViewReplyCount:

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
            [self.attendeeListTableView reloadData];
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

@end
