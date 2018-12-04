//
//  DCPersonDetailTableViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DCFeedItem;

@interface DCPersonDetailTableViewController : UITableViewController <UIScrollViewDelegate>
@property (nonatomic, strong) DCFeedItem *selectedFeedItem;
- (void)pushToSignInVC;
@end
