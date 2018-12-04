//
//  DCFeedItemDetailsWebViewController.h
//  EventChat
//
//  Created by Jigish Belani on 10/18/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "DCMediaEntity.h"
#import "DCMediaEntityObject.h"

@interface DCFeedItemDetailsWebViewController : UIViewController
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)IBOutlet UIWebView *webView;
@end
