//
//  DCFollowFavoriteButtonCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCFollowFavoriteButtonCell.h"
#import "ECAPI.h"
#import "ECColor.h"

@implementation DCFollowFavoriteButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithUser:(ECUser *)aProfileUser signedInUser:(ECUser *)signedInUser isSignedInUser:(BOOL)isSignedInUser{
    self.profileUser = aProfileUser;
    _isSignedInUser = isSignedInUser;
    self.signedInUser = signedInUser;
    [self loadFollowing:(NSInteger)[self.profileUser.followeeIds count]];
    [self loadFollowers:(NSInteger)[self.profileUser.followerIds count]];
    [self loadFavorites];
}

#pragma mark - API Delegate
- (void)loadFollowing:(NSInteger)count{
    NSString *followingCount = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    // Setup the string
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWING", followingCount]];
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followingCount length])];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor mainThemeColor] range:NSMakeRange(0, [followingCount length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followingCount length])];
    
    // Normal font for the rest of the text
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followingCount length], 10)];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followingCount length], 10)];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followingCount length], 10)];
    [self.followingButton setAttributedTitle:titleText forState:UIControlStateNormal];
    
}

- (void)loadFollowers:(NSInteger)count{
    NSString *followersCount = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    // Setup the string
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWERS", followersCount]];
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followersCount length])];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor mainThemeColor] range:NSMakeRange(0, [followersCount length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followersCount length])];
    
    // Normal font for the rest of the text
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followersCount length], 10)];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followersCount length], 10)];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followersCount length], 10)];
    [self.followersButton setAttributedTitle:titleText forState:UIControlStateNormal];
}

- (void)loadFavorites{
    NSString *favoritesCount;
    if(self.isSignedInUser){
        favoritesCount = [NSString stringWithFormat:@"%d", self.signedInUser.favoriteCount];
    }
    else{
        favoritesCount = [NSString stringWithFormat:@"%d", self.profileUser.favoriteCount];
    }
    
    // Setup the string
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFAVORITES", favoritesCount]];
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [favoritesCount length])];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor mainThemeColor] range:NSMakeRange(0, [favoritesCount length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [favoritesCount length])];
    
    // Normal font for the rest of the text
    [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([favoritesCount length], 10)];
    [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([favoritesCount length], 10)];
    [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([favoritesCount length], 10)];
    [self.favoritesButton setAttributedTitle:titleText forState:UIControlStateNormal];
}

@end
