//
//  ECNewPlaylistTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECNewPlaylistTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFHTTPRequestOperationManager.h"

@interface ECNewPlaylistTableViewCell()
@property (nonatomic, strong) AFHTTPRequestOperationManager *mOperationManager;
@end

@implementation ECNewPlaylistTableViewCell

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
    self.playlistTitleLabel.text = @"";
    [self.playlistCoverImageView setImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.playlistProfilePhotoImageView setImage:[UIImage imageNamed:@"missing-profile.png"]];
}

#pragma mark:- AF

- (AFHTTPRequestOperationManager *)operationManager {
    if (!self.mOperationManager)
    {
        self.mOperationManager = [[AFHTTPRequestOperationManager alloc] init];
        self.mOperationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    return self.mOperationManager;
}

#pragma mark:- Configure TableViewCell

- (void)configureTableViewCellWithItem:(DCPlaylist *)playlistItem indexPath:(NSIndexPath *)indexPath{
    self.playlistProfilePhotoImageView.layer.cornerRadius = self.playlistProfilePhotoImageView.frame.size.width / 2;
    self.playlistProfilePhotoImageView.layer.borderWidth = 3;
    self.playlistProfilePhotoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.playlistProfilePhotoImageView.layer.masksToBounds = YES;
    
    self.playlistCoverImageView.layer.cornerRadius = 5.0;
    self.playlistCoverImageView.layer.masksToBounds = YES;
    self.playlistCoverImageView.layer.borderWidth = 5;
    self.playlistCoverImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.playlistTitleLabel setText:playlistItem.playlistName];
    if(playlistItem.coverImageUrl != nil){
        [self showImageOnTheCell:self ForImageUrl:playlistItem.coverImageUrl];
    }
    // Also set the profile Image i.e. playlistItem.thumbnailImageUrl
    // [self.playlistUserNameLabel setText:@""];
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(ECNewPlaylistTableViewCell *)cell ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.playlistCoverImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.playlistCoverImageView.image = image;
        
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
                                    cell.playlistCoverImageView.image = image;
                                    
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
