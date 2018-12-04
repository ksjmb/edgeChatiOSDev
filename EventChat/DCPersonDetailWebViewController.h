//
//  DCPersonDetailWebViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/28/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "DCMediaEntity.h"
#import "DCMediaEntityObject.h"
#import "DCSocialEntity.h"
#import "DCSocialEntityObject.h"

@interface DCPersonDetailWebViewController : UIViewController
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)IBOutlet UIWebView *webView;
@end
