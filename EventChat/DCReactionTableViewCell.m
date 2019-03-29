//
//  DCReactionTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 22/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCReactionTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"

@implementation DCReactionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configureWithAttendee:(ECAttendee *)attendee{
    [self.mNameLabel setText:[NSString stringWithFormat:@"%@ %@", attendee.user.firstName, attendee.user.lastName]];
    [self.mResponseLabel setText:[attendee.response uppercaseString]];
    
    self.mProfileImageView.layer.cornerRadius = 20.0;
    self.mProfileImageView.clipsToBounds = YES;
    if (attendee.user.profilePicUrl != nil){
        [self showProfileImage:attendee.user.profilePicUrl];
    }else{
        self.mProfileImageView.image = [UIImage imageNamed:@"missing-profile.png"];
    }
}

#pragma mark:- SDWebImage

-(void)showProfileImage:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    
    if (inMemoryImage){
        self.mProfileImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.mProfileImageView.image = image;
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
                                    self.mProfileImageView.image = image;
                                    self.mProfileImageView.layer.borderWidth = 1.0;
                                    self.mProfileImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again");
                                        return;
                                    }
                                }
                            }];
    }
}

@end
