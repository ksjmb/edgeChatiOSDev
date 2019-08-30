//
//  ECFollowCell.m
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECFollowCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ECFollowCell()
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profilePic;
@end

@implementation ECFollowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithUser:(ECUser *)ecUser{
    [self.userNameLabel setText:[NSString stringWithFormat:@"%@ %@", ecUser.firstName, ecUser.lastName]];
    
    /*
    // Set profile pic
    if(ecUser.profilePicUrl != nil){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ecUser.profilePicUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [self.profilePic setImage:image];
    }
    */
     
    if(ecUser.profilePicUrl != nil){
        [self showProfilePicImage:ecUser.profilePicUrl];
    }
}

-(void)showProfilePicImage:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage) {
        self.profilePic.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.profilePic.image = image;
        
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
                                    self.profilePic.image = image;
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
