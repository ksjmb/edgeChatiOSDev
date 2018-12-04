//
//  DCYTPlayerTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/27/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@class DCFeedItem;

@interface DCYTPlayerTableViewCell : UITableViewCell
@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;

- (void)configureWithFeedItem:(DCFeedItem *)feedItem;
@end
