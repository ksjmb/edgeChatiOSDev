//
//  ECUserProfileSocialTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 14/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECUserProfileSocialTableViewCell.h"
#import "ECColor.h"
#import "DCFeedItem.h"
#import "DCSocialEntity.h"
#import "DCSocialEntityObject.h"
#import "ECAPI.h"
#import "SVProgressHUD.h"

@implementation ECUserProfileSocialTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userEmailStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.mFacebookButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [self.mTwitterButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Configure Cell

-(void)configureSocialCell:(ECUser *)user :(ECUser *)loginUser{
//    [self.mFacebookButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
//    [self.mTwitterButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [self loadFacebookData:user];
    [self loadTwitterData:user];
    [self loadInstagramData:user :loginUser];
}

#pragma mark - API Delegate

- (void)loadFacebookData:(ECUser *)user{
    NSString *likesCount = [NSString stringWithFormat:@"%lu", (unsigned long)[user.followeeIds count]];
    if(likesCount != nil){
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWING", likesCount]];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [likesCount length])];
        [titleText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [likesCount length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [likesCount length])];
        
        // Normal font for the rest of the text
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([likesCount length], 10)];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([likesCount length], 10)];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([likesCount length], 10)];
        [self.mFacebookButton setAttributedTitle:titleText forState:UIControlStateNormal];
    }
}

- (void)loadTwitterData:(ECUser *)user{
    NSString *followerCount = [NSString stringWithFormat:@"%lu", (unsigned long)[user.followerIds count]];;
    if(followerCount != nil){
        // Setup the string
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWERS", followerCount]];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followerCount length])];
        [titleText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [followerCount length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followerCount length])];
        
        // Normal font for the rest of the text
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followerCount length], 10)];
        [self.mTwitterButton setAttributedTitle:titleText forState:UIControlStateNormal];
    }
}

- (void)loadInstagramData:(ECUser *)user :(ECUser *)signInUser{
    NSString *followerCount;
//    if(self.userEmailStr != nil){
//        followerCount = [NSString stringWithFormat:@"%d", signInUser.favoriteCount];
//    }
//    else{
        followerCount = [NSString stringWithFormat:@"%d", user.favoriteCount];
//    }
    
    if(followerCount != nil){
        // Setup the string
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFAVORITES", followerCount]];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followerCount length])];
        [titleText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [followerCount length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followerCount length])];
        
        // Normal font for the rest of the text
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followerCount length], 10)];
        [self.mInstagramButton setAttributedTitle:titleText forState:UIControlStateNormal];
    }
}

@end
