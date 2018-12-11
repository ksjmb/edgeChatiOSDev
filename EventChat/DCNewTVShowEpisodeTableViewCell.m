//
//  DCNewTVShowEpisodeTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 15/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCNewTVShowEpisodeTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "IonIcons.h"
#import "ECUser.h"
#import "ECColor.h"
#import "ECCommonClass.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DCNewTVShowEpisodeTableViewCell()
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@end

@implementation DCNewTVShowEpisodeTableViewCell

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
    [_episodeTitle setText:nil];
    [_episodeDescription setText:nil];
    [_episodeImageView setImage:[UIImage new]];
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnPlayEpisodeVideo:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"DCNewTVShowEpisodeTableViewCell: IndexPath.row: %ld", (long)indexPath.row);
    if([self.delegate respondsToSelector:@selector(playVideoForSelectedEpisode:index:)]){
        [self.delegate playVideoForSelectedEpisode:self index:indexPath.row];
    }
}

- (IBAction)actionOnCommentButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnCommentButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapShareButton:index:)]){
        [self.delegate didTapCommentsButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnShareButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnShareButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapShareButton:index:)]){
        [self.delegate mainFeedDidTapShareButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnLikeButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnLikeButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapAttendanceButton:index:)]){
        [self.delegate mainFeedDidTapAttendanceButton:self index:indexPath.row];
    }
}

- (IBAction)actionFavButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionFavButton: IndexPath.row: %ld", (long)indexPath.row);
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFavoriteButton:index:)]){
        [self.delegate mainFeedDidTapFavoriteButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnViewMoreButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    
    ECCommonClass *instance = [ECCommonClass sharedManager];
    
    if (instance.indexPathRowArray == nil){
        instance.indexPathRowArray = [[NSMutableArray alloc] init];
    }
    
    _isExpanded = !_isExpanded;
    self.episodeDescription.numberOfLines = self.isExpanded ? 0 : 2;
    self.episodeDescription.contentMode = NSLineBreakByWordWrapping;
    [self.viewMoreButton setTitle: self.isExpanded ? @"View less..." : @"View more..." forState:UIControlStateNormal];
    
    CGSize labelSize = [self.episodeDescription.text sizeWithFont:self.episodeDescription.font
                                constrainedToSize:self.episodeDescription.frame.size
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat labelHeight = labelSize.height;
    self.episodeDescriptionLabelHeightConstraint.constant = self.isExpanded ? labelHeight : 30;
    
    NSString *newVal = [NSString stringWithFormat:@"%lu", (unsigned long)indexPath.row];
    if ([instance.indexPathRowArray containsObject:newVal]){
        [instance.indexPathRowArray removeObject:newVal];
    }else{
        [instance.indexPathRowArray addObject:newVal];
    }
    
    if([self.delegate respondsToSelector:@selector(viewMoreButtonTapped:)]){
        [self.delegate viewMoreButtonTapped:self];
    }
}

#pragma mark:- AF

- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager)
    {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return _operationManager;
}

- (void)configureWithFeedItemWith:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending indexPath:(NSIndexPath*)indexPath{
    
    self.feedItem = feedItem;
    _playSelectedEpisodeButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    
    [_episodeTitle setText:[NSString stringWithFormat:@"E%@ - %@", feedItem.digital.episodeNumber, feedItem.digital.episodeTitle]];
    
    [_episodeDescription setText:feedItem.digital.episodeDescription];
    
    //Comments Button
//    NSLog(@"[feedItem.commentCount intValue] : %d", [feedItem.commentCount intValue]);
    if([feedItem.commentCount intValue] > 0){
        NSString *mCommentCount = [NSString stringWithFormat:@"%@", feedItem.commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.commentCountLabel setText:mCommentCount];
        self.commentButton.enabled = TRUE;
    }
    else{
        [self.commentCountLabel setText:@"00 comments"];
        self.commentButton.enabled = FALSE;
        //Remove Later
        self.commentButton.enabled = TRUE;
    }
    
    //Fav button
    if(isFavorited){
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }
    else{
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //like button
    if(isAttending){
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //share button
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    
    if(feedItem.digital.imageUrl != nil){
        [self showImageOnTheCell:self ForImageUrl:feedItem.digital.imageUrl isFromDownloadButton:NO];
    }
    
    //Episode description label
    NSString *stringVal = [NSString stringWithFormat:@"%lu", (unsigned long)indexPath.row];
    ECCommonClass *instance = [ECCommonClass sharedManager];
    
    if ([instance.indexPathRowArray containsObject:stringVal]){
        self.episodeDescription.numberOfLines = 0;
        [self.viewMoreButton setTitle: @"View less..." forState:UIControlStateNormal];
        //        self.episodeDescriptionLabelHeightConstraint.constant = 50;
        self.isExpanded = true;
    }else{
        self.isExpanded = false;
        self.episodeDescription.numberOfLines = 2;
        [self.viewMoreButton setTitle: @"View more..." forState:UIControlStateNormal];
        self.episodeDescriptionLabelHeightConstraint.constant = 30;
    }
    [self layoutIfNeeded];
}

/*
- (void)configureWithFeedItem:(DCFeedItem *)feedItem isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending {
    self.feedItem = feedItem;
    
    _playSelectedEpisodeButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    
    [_episodeTitle setText:[NSString stringWithFormat:@"E%@ - %@", feedItem.digital.episodeNumber, feedItem.digital.episodeTitle]];
    
    [_episodeDescription setText:feedItem.digital.episodeDescription];
    
    //Comments Button
    if([feedItem.commentCount intValue] > 0){
//        UIImage *image = [UIImage imageNamed:@"comment"];
//        [self.commentButton setBackgroundImage:image forState:UIControlStateNormal];
        NSString *mCommentCount = [NSString stringWithFormat:@"%@", feedItem.commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.commentCountLabel setText:mCommentCount];
        self.commentButton.enabled = TRUE;
    }
    else{
//        UIImage *image = [UIImage imageNamed:@"comment"];
//        [self.commentButton setBackgroundImage:image forState:UIControlStateNormal];
        self.commentButton.enabled = FALSE;
        //Remove Later
        self.commentButton.enabled = TRUE;
    }
//    [self.commentButton setContentMode:UIViewContentModeScaleAspectFit];
    
    //Fav button
    if(isFavorited){
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }
    else{
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //like button
    if(isAttending){
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //share button
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    
    if(feedItem.digital.imageUrl != nil){
        [self showImageOnTheCell:self ForImageUrl:feedItem.digital.imageUrl isFromDownloadButton:NO];
    }
}
*/

#pragma mark:- SDWebImage
// Displaying Image on Cell
-(void)showImageOnTheCell:(DCNewTVShowEpisodeTableViewCell *)cell ForImageUrl:(NSString *)url isFromDownloadButton:(BOOL)downloadFlag{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.episodeImageView.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.episodeImageView.image = image;
        
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
                                    cell.episodeImageView.image = image;
                                    cell.episodeImageView.layer.borderWidth = 1.0;
                                    cell.episodeImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                    
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
