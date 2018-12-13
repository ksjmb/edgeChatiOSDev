//
//  DCSocialTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCSocialTableViewCell.h"
#import "ECCommonClass.h"
#import "ECColor.h"
#import "DCFeedItem.h"
#import "DCSocialEntity.h"
#import "DCSocialEntityObject.h"

@implementation DCSocialTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCell:(DCFeedItem *)feedItem{
    [self.facebookBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [self.twitterBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [self.instragramBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0f, 0, 0)];
    [self.facebookBtn.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:self.facebookBtn imageType:Facebook aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [self.twitterBtn.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:self.twitterBtn imageType:TWX aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [self.instragramBtn.layer addSublayer:[[ECCommonClass sharedManager] addImageToButton:self.instragramBtn imageType:Instagram aColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]] aSize:30.0]];
    [self.facebookBtn addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
    [self.twitterBtn addBorderForSide:Right color:[UIColor lightGrayColor] width:0.5];
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
        [self.facebookBtn setAttributedTitle:titleText forState:UIControlStateNormal];
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
        [self.twitterBtn setAttributedTitle:titleText forState:UIControlStateNormal];
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
        [self.instragramBtn setAttributedTitle:titleText forState:UIControlStateNormal];
    }
    
}

@end
