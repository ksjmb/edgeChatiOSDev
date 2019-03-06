//
//  ECPlaylistDetailsTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 23/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECPlaylistDetailsTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "IonIcons.h"
#import "ECUser.h"
#import "ECColor.h"
#import "ECCommonClass.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ECPlaylistDetailsTableViewCell()
@property (nonatomic, strong) AFHTTPRequestOperationManager *mOperationMgr;
@end

@implementation ECPlaylistDetailsTableViewCell

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
    [self.playlistTitleLabel setText:nil];
    [self.playlistMsgLabel setText:nil];
//    [self.playlistImageView setImage:[UIImage new]];
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnCommentButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"ECPlaylistDetailsTableViewCell: IndexPath.row: %ld", (long)indexPath.row);
    if([self.mPlaylistDelegate respondsToSelector:@selector(didTapCommentsButton:index:)]){
        [self.mPlaylistDelegate didTapCommentsButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnShareButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"ECPlaylistDetailsTableViewCell: IndexPath.row: %ld", (long)indexPath.row);
    if([self.mPlaylistDelegate respondsToSelector:@selector(mainFeedDidTapShareButton:index:)]){
        [self.mPlaylistDelegate mainFeedDidTapShareButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnLikeButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"ECPlaylistDetailsTableViewCell: IndexPath.row: %ld", (long)indexPath.row);
    if([self.mPlaylistDelegate respondsToSelector:@selector(mainFeedDidTapAttendanceButton:index:)]){
        [self.mPlaylistDelegate mainFeedDidTapAttendanceButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnFavButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"ECPlaylistDetailsTableViewCell: IndexPath.row: %ld", (long)indexPath.row);
    if([self.mPlaylistDelegate respondsToSelector:@selector(mainFeedDidTapFavoriteButton:index:)]){
        [self.mPlaylistDelegate mainFeedDidTapFavoriteButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnPlayButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"ECPlaylistDetailsTableViewCell: IndexPath.row: %ld", (long)indexPath.row);
    if([self.mPlaylistDelegate respondsToSelector:@selector(playVideoForSelectedEpisode:index:)]){
        [self.mPlaylistDelegate playVideoForSelectedEpisode:self index:indexPath.row];
    }
}

#pragma mark:- AF

- (AFHTTPRequestOperationManager *)operationManager {
    if (!self.mOperationMgr){
        self.mOperationMgr = [[AFHTTPRequestOperationManager alloc] init];
        self.mOperationMgr.responseSerializer = [AFImageResponseSerializer serializer];
    };
    return self.mOperationMgr;
}

#pragma mark:- Configure Cell

- (void)configureCellFeedItemWith:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending indexPath:(NSIndexPath *)indexPath{
    self.feedItem = feedItem;
    self.playButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
//    [self.favBtn setHidden:YES];
    
    //Title and description label
    [self.playlistTitleLabel setText:[NSString stringWithFormat:@"E%@ - %@", feedItem.digital.episodeNumber, feedItem.digital.episodeTitle]];
    
    if (![feedItem.digital.episodeDescription  isEqual: @""]){
        [self.playlistMsgLabel setText:feedItem.digital.episodeDescription];
    }else{
        [self.playlistTitleLabel setText:[NSString stringWithFormat:@"%@", feedItem.person.name]];
        [self.playlistMsgLabel setText:feedItem.person.blurb];
    }
    
    //Comments Button
    if([feedItem.commentCount intValue] > 0){
        NSString *mCommentCount = [NSString stringWithFormat:@"%@", feedItem.commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.commentCountLabel setText:mCommentCount];
        self.commentCountButton.enabled = TRUE;
    }
    else{
        [self.commentCountLabel setText:@"00 comments"];
        self.commentCountButton.enabled = FALSE;
        //Remove Later
        self.commentCountButton.enabled = TRUE;
    }
    
    /*
    //Fav button
    if(isFavorited){
//        [self.favBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
        [self.favBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    else{
//        [self.favBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [self.favBtn setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    
    //like button
    if(isAttending){
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //share button
    [self.shareBtn setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    */
    
    //Fav button
    if(isFavorited){
        UIImage *btnImage = [UIImage imageNamed:@"thumb_blue"];
        [self.favBtn setTintColor:[UIColor colorWithRed:(67/255.0) green:(114/255.0) blue:(199/255.0) alpha:1]];
        [self.favBtn setImage:[self imageWithImage:btnImage scaledToSize:CGSizeMake(27.0, 27.0)] forState:UIControlStateNormal];
        
//        [self.favBtn setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        UIImage *btnImage = [UIImage imageNamed:@"thumb_white"];
        [self.favBtn setTintColor:[UIColor darkTextColor]];
        [self.favBtn setImage:[self imageWithImage:btnImage scaledToSize:CGSizeMake(27.0, 27.0)] forState:UIControlStateNormal];
        
//        [self.favBtn setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    [self.likeButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor darkTextColor]] forState:UIControlStateNormal];
    //share button
    [self.shareBtn setImage:[IonIcons imageWithIcon:ion_heart  size:30.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.shareBtn setUserInteractionEnabled:NO];
    
    if(feedItem.digital.imageUrl != nil){
        if (![feedItem.digital.imageUrl  isEqual: @""]){
            [self showImageOnTheCell:self ForImageUrl:feedItem.digital.imageUrl isFromDownloadButton:NO];
        }else{
            if(feedItem.person.profilePic_url != nil){
                [self showImageOnTheCell:self ForImageUrl:feedItem.person.profilePic_url isFromDownloadButton:NO];
            }
        }
    }
    [self layoutIfNeeded];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark:- SDWebImage

-(void)showImageOnTheCell:(ECPlaylistDetailsTableViewCell *)cell ForImageUrl:(NSString *)url isFromDownloadButton:(BOOL)downloadFlag{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.playlistImageView.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.playlistImageView.image = image;
        
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
                                    cell.playlistImageView.image = image;
                                    cell.playlistImageView.layer.borderWidth = 1.0;
                                    cell.playlistImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again")
                                        ;
                                        if (downloadFlag) {
                                            //cell.downloadButton.hidden = NO;
                                        }
                                        return;
                                    }
                                }
                            }];
    }
}

@end
