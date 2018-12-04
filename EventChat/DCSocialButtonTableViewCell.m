//
//  DCSocialButtonTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCSocialButtonTableViewCell.h"
#import "ECCommonClass.h"
#import "ECColor.h"
#import "DCFeedItem.h"
#import "DCSocialEntity.h"
#import "DCSocialEntityObject.h"

@implementation DCSocialButtonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configure:(DCFeedItem *)feedItem{
    [_facebookButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
     [_twitterButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_instagramButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [_facebookButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_facebookButton imageType:Facebook aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [_twitterButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_twitterButton imageType:TWX aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [_instagramButton.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:_instagramButton imageType:Instagram aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [_facebookButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [_twitterButton addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [self loadFacebookData:feedItem];
    [self loadTwitterData:feedItem];
    [self loadInstagramData:feedItem];
}

#pragma mark - API Delegate
- (void)loadFacebookData:(DCFeedItem *)feedItem{
    NSString *likesCount = feedItem.social.facebook.like_count;
    if(likesCount != nil){
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nLIKES", likesCount]];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [likesCount length])];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] range:NSMakeRange(0, [likesCount length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [likesCount length])];
        
        // Normal font for the rest of the text
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([likesCount length], 6)];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([likesCount length], 6)];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([likesCount length], 6)];
        [_facebookButton setAttributedTitle:titleText forState:UIControlStateNormal];
    }
}

- (void)loadTwitterData:(DCFeedItem *)feedItem{
    NSString *followerCount = feedItem.social.twitter.follower_count;
    if(followerCount != nil){
        // Setup the string
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWERS", followerCount]];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followerCount length])];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] range:NSMakeRange(0, [followerCount length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followerCount length])];
        
        // Normal font for the rest of the text
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followerCount length], 10)];
        [_twitterButton setAttributedTitle:titleText forState:UIControlStateNormal];
    }
}

- (void)loadInstagramData:(DCFeedItem *)feedItem{
    NSString *followerCount = feedItem.social.instagram.follower_count;
    if(followerCount != nil){
        // Setup the string
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWERS", followerCount]];
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0] forKey:NSFontAttributeName] range:NSMakeRange(0, [followerCount length])];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] range:NSMakeRange(0, [followerCount length])];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [followerCount length])];
        
        // Normal font for the rest of the text
        [titleText addAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0] forKey:NSFontAttributeName] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSForegroundColorAttributeName value:[ECColor ecSubTextGrayColor] range:NSMakeRange([followerCount length], 10)];
        [titleText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange([followerCount length], 10)];
        [_instagramButton setAttributedTitle:titleText forState:UIControlStateNormal];
    }
    
}

@end
