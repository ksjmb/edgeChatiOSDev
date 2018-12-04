//
//  DCTVShowHeaderTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/7/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
@interface DCTVShowHeaderTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *topImageView;

- (void)configureWithFeedItem:(DCFeedItem *)feedItem;
@end
