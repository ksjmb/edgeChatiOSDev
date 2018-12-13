//
//  DCSocialTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@class DCFeedItem;

NS_ASSUME_NONNULL_BEGIN

@interface DCSocialTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CustomButton *facebookBtn;
@property (weak, nonatomic) IBOutlet CustomButton *twitterBtn;
@property (weak, nonatomic) IBOutlet CustomButton *instragramBtn;

-(void)configureCell:(DCFeedItem *)feedItem;

@end

NS_ASSUME_NONNULL_END
