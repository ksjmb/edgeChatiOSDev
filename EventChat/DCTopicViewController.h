//
//  DCTopicViewController.h
//  EventChat
//
//  Created by Jigish Belani on 7/23/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"

@interface DCTopicViewController : UIViewController
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)NSString *eventId;

@end
