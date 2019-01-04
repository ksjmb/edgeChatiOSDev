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
    [self.mVideoDescription setText:nil];
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
    /*
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnPlayVideoBtn: IndexPath.row: %ld", (long)indexPath.row);
    if([self.dcPersonDelegate respondsToSelector:@selector(playVideoForSelectedEpisode:index:)]){
        [self.dcPersonDelegate playVideoForSelectedEpisode:self index:indexPath.row];
    }
     */
}

@end
