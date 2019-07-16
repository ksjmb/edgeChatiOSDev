//
//  ECIndividualProfileTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 16/07/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECIndividualProfileTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ECAPI.h"
#import "ECColor.h"
#import "ECEvent.h"
#import "DCFeedItem.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSObject+AssociatedObject.h"
#import "IonIcons.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomButton.h"

@implementation ECIndividualProfileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Configure TableViewCell

- (void)configureCellWithUserItem:(NSString *)fullName profileURL:(NSString *)profileURL  cellIndex:(NSIndexPath *)indexPath{
    
    self.mUserNameLabel.text = fullName;
    if( profileURL != nil){
        [self showImageOnTheCell:self ForImageUrl:profileURL];
    }
}

#pragma mark - SDWebImage

-(void)showImageOnTheCell:(ECIndividualProfileTableViewCell *)cell ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.mProfileImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.mProfileImageView.image = image;
        
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
                                    cell.mProfileImageView.image = image;
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, please try again")
                                        ;
                                        return;
                                    }
                                }
                            }];
        }
}

@end
