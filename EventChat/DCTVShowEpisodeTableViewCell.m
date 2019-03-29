//
//  DCTVShowEpisodeTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/8/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCTVShowEpisodeTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "IonIcons.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DCTVShowEpisodeTableViewCell()
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end
@implementation DCTVShowEpisodeTableViewCell

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

- (void)configureWithFeedItem:(DCFeedItem *)feedItem{
    [_episodeTitle setText:[NSString stringWithFormat:@"E%@ - %@", feedItem.digital.episodeNumber, feedItem.digital.episodeTitle]];
    [_episodeDescription setText:feedItem.digital.episodeDescription];
    [self.playSelectedEpisodeButton setBackgroundImage:[IonIcons imageWithIcon:ion_play  size:50.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    if([feedItem.commentCount intValue] > 0){
        UIImage *image = [UIImage imageNamed:@"ECComment_On.png"];
        [self.commentsButton setBackgroundImage:image forState:UIControlStateNormal];
        self.commentsButton.enabled = FALSE;
        self.commentsButton.enabled = TRUE;
    }
    else{
        UIImage *image = [UIImage imageNamed:@"ECComment_Off.png"];
        [self.commentsButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    [self.commentsButton setTitle:nil forState:UIControlStateNormal];
    [self.commentsButton setNeedsLayout];
    
    if(feedItem.digital.imageUrl != nil){
        [self showImageOnTheCell:self ForImageUrl:feedItem.digital.imageUrl isFromDownloadButton:NO];
    }
}

- (IBAction)didTapPlayVideo:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);

    if([self.delegate respondsToSelector:@selector(playVideoForSelectedEpisode:index:)]){
        [self.delegate playVideoForSelectedEpisode:self index:indexPath.row];
    }
}

- (IBAction)didTapCommentsButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(didTapCommentsButton:index:)]){
        [self.delegate didTapCommentsButton:self index:indexPath.row];
    }
}

#pragma mark - SDWebImage
// Displaying Image on Cell
-(void)showImageOnTheCell:(DCTVShowEpisodeTableViewCell *)cell ForImageUrl:(NSString *)url isFromDownloadButton:(BOOL)downloadFlag{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage){
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
                                        NSLog(@"Problem downloading Image, play try again");
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
