//
//  DCSocialButtonTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
@class DCFeedItem;

@interface DCSocialButtonTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet CustomButton *facebookButton;
@property (nonatomic, strong) IBOutlet CustomButton *twitterButton;
@property (nonatomic, strong) IBOutlet CustomButton *instagramButton;

-(void)configure:(DCFeedItem *)feedItem;
@end
