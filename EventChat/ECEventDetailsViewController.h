//
//  ECEventDetailsViewController.h
//  EventChat
//
//  Created by Jigish Belani on 2/15/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "ECEventBriteEvent.h"

@class ECEventBriteEvent;

@interface ECEventDetailsViewController : SLKTextViewController
@property (nonatomic, strong)ECEventBriteEvent *selectedEvent;
@property (nonatomic, strong)NSString *eventId;
@end
