//
//  ECAttendanceDetailsViewController.h
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECAttendanceResponseTableViewCell.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "DCPost.h"

@class ECEventBriteEvent;
@class ECAttendanceResponseTableViewCell;
@class DCFeedItem;
@class DCPost;

@interface ECAttendanceDetailsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ECAttendanceResponseTableViewCellDelegate>

//@property (nonatomic, strong)ECEventBriteEvent *selectedEvent;
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)DCPost *selectedPostItem;
@property (nonatomic, strong) NSArray *attendeeList;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, weak) IBOutlet UITableView *attendeeListTableView;
@property (nonatomic, assign) BOOL isPost;

@end
