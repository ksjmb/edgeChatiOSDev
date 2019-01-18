//
//  DCInfluencersPersonDetailsTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCInfluencersPersonDetailsTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "IonIcons.h"
#import "ECUser.h"
#import "ECColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DCFeedItem.h"
#import "DCMediaEntity.h"
#import "DCMediaEntityObject.h"
//
#import "DCPost.h"
#import "CustomButton.h"
#import "NSDate+NVTimeAgo.h"
#import "ECCommonClass.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface DCInfluencersPersonDetailsTableViewCell()
@property (nonatomic, strong) AFHTTPRequestOperationManager *mOperationManager;
@end

@implementation DCInfluencersPersonDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    // Then Reset here back to default values that you want.
    [self.mVideoTitle setText:nil];
    [self.mVideoImageView setImage:[UIImage new]];
    
//    [self.mVideoDescription setText:nil];
//    [_episodeImageView setImage:[UIImage new]];
}

#pragma mark:- AF

- (AFHTTPRequestOperationManager *)operationManager
{
    if (!self.mOperationManager)
    {
        self.mOperationManager = [[AFHTTPRequestOperationManager alloc] init];
        self.mOperationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return self.mOperationManager;
}

#pragma mark:- Configure UITableViewCell

- (void)configureTableViewCellWithItem:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending indexPath:(NSIndexPath*)indexPath{
    
    self.mDCFeedItem = feedItem;
    
    self.mVideoPlayBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    [self.mVideoTitle setText:[NSString stringWithFormat:@"%@", feedItem.media.youtube.title]];
//    [self.mVideoDescription setText:feedItem.media.youtube.description];
    
    // Load Video
    if([feedItem.media.youtube.videoUrl rangeOfString:@"watch"].location == NSNotFound){
        [self.mPlayerView loadWithVideoId:@"tPWtOzOynAQ"];
    }
    else{
        [self.mPlayerView loadWithVideoId:[feedItem.media.youtube.videoUrl componentsSeparatedByString:@"="][1]];
        [self.mPlayerView playVideo];
    }
    
    //Comments Button
    if([feedItem.commentCount intValue] > 0){
        NSString *mCommentCount = [NSString stringWithFormat:@"%@", feedItem.commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.mVideoCommentCount setText:mCommentCount];
        self.mVideoCommentBtn.enabled = TRUE;
    }
    else{
        [self.mVideoCommentCount setText:@"00 comments"];
        self.mVideoCommentBtn.enabled = FALSE;
        //Remove Later
        self.mVideoCommentBtn.enabled = TRUE;
    }
    
    //Fav button
    if(isFavorited){
        [self.mVideoFavBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }
    else{
        [self.mVideoFavBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //like button
    if(isAttending){
        [self.mVideoLikeBtn setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        [self.mVideoLikeBtn setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //share button
//    [self.mVideoShareBtn setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    [self.mVideoShareBtn setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
}

- (void)configureWithPost:(DCPost *)post signedInUser:(ECUser *)signedInUser{
    self.mSignedInUser = signedInUser;
    self.mDCPost = post;
    self.mVideoPlayBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
//    self.mVideoPlayBtn.backgroundColor = [UIColor clearColor];
    [self.mVideoPlayBtn setHidden:true];
    
//    if([signedInUser.favoritedPostIds containsObject:post.postId]){
        if([signedInUser.favoritedFeedItemIds containsObject:post.postId]){
        [self.mVideoFavBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }else{
        [self.mVideoFavBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }

//    if([signedInUser.likedPostIds containsObject:post.postId]){
        if([signedInUser.attendingFeedItemIds containsObject:post.postId]){
        [self.mVideoLikeBtn setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }else{
        [self.mVideoLikeBtn setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //Comments Button
    if([post.commentCount intValue] > 0){
        NSString *mCommentCount = [NSString stringWithFormat:@"%@", post.commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.mVideoCommentCount setText:mCommentCount];
        self.mVideoCommentBtn.enabled = TRUE;
    }
    else{
        [self.mVideoCommentCount setText:@"00 comments"];
        self.mVideoCommentBtn.enabled = FALSE;
        //Remove Later
        self.mVideoCommentBtn.enabled = TRUE;
    }
    
    [self.mVideoShareBtn setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    //Video present
    if ([post.postType  isEqual: @"video"]){
        if(post.imageUrl != nil){
            [self showImageOnTheCell:self ForImageUrl:post.imageUrl];
        }
        [self.mPlayerView loadWithVideoId:post.videoUrl];
        [self.mPlayerView playVideo];
        self.imageViewHeightConstraint.constant = 0;
        self.mVideoTitleLabelHeightConstraint.constant = 0;
        self.imageViewHeightConstraint.constant = 150;
        self.playerViewHeightConstraint.constant = 150;
        [self.mVideoPlayBtn setHidden:false];
        [self.mVideoImageView setHidden:false];
    }
    //Image present
    else if ([post.postType  isEqual: @"image"]){
        if(post.imageUrl != nil){
            [self showImageOnTheCell:self ForImageUrl:post.imageUrl];
        }
        self.playerViewHeightConstraint.constant = 0;
        self.mVideoTitleLabelHeightConstraint.constant = 0;
        self.imageViewHeightConstraint.constant = 150;
        [self.mVideoImageView setHidden:false];
    }
    //Only text message present
    else if (post.imageUrl == nil && post.videoUrl == nil){
        self.imageViewHeightConstraint.constant = 0;
        self.playerViewHeightConstraint.constant = 0;
    }
    
    [self.mVideoTitle setText:[NSString stringWithFormat:@"%@", post.content]];

    /*
    // Format date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *created_atFromString = [[NSDate alloc] init];
    created_atFromString = [dateFormatter dateFromString:post.created_at];
    NSString *ago = [created_atFromString formattedAsTimeAgo];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    NSLog(@"Output is: \"%@\"", ago);
    NSLog(@"Output is: \"%@\"", [dateFormatter2 stringFromDate:created_atFromString]);
    
    [_nameLabel setText:post.displayName];
    [_postContentTextView setText:post.content];
    [_timeLabel setText:ago];
    [_commentCount setText:[NSString stringWithFormat:@"%@ comments", post.commentCount]];
    _postContentTextView.translatesAutoresizingMaskIntoConstraints = false;
     */
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnVideoCommentBtn:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnCommentButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.dcPersonDelegate respondsToSelector:@selector(didTapCommentsButton:index:)]){
        [self.dcPersonDelegate didTapCommentsButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnVideoShareBtn:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnShareButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.dcPersonDelegate respondsToSelector:@selector(didTapShareButton:index:)]){
        [self.dcPersonDelegate didTapShareButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnVideoLikeBtn:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnLikeButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.dcPersonDelegate respondsToSelector:@selector(didTapAttendanceButton:index:)]){
        [self.dcPersonDelegate didTapAttendanceButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnVideoFavBtn:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionFavButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.dcPersonDelegate respondsToSelector:@selector(didTapFavoriteButton:index:)]){
        [self.dcPersonDelegate didTapFavoriteButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnPlayVideoBtn:(id)sender {
     NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
     NSLog(@"actionOnPlayVideoBtn: IndexPath.row: %ld", (long)indexPath.row);
     if([self.dcPersonDelegate respondsToSelector:@selector(playVideoButtonTapped:index:)]){
     [self.dcPersonDelegate playVideoButtonTapped:self index:indexPath.row];
     }
    
    /*
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnPlayVideoBtn: IndexPath.row: %ld", (long)indexPath.row);
    if([self.dcPersonDelegate respondsToSelector:@selector(playVideoForSelectedEpisode:index:)]){
        [self.dcPersonDelegate playVideoForSelectedEpisode:self index:indexPath.row];
    }
     */
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(DCInfluencersPersonDetailsTableViewCell *)cell ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.mVideoImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.mVideoImageView.image = image;
        
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
                                    cell.mVideoImageView.image = image;
                                    
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
