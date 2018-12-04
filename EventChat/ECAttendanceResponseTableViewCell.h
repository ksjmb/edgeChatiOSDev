//
//  ECAttendanceResponseTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECEventBriteStart.h"
#import "ECEventBriteLogo.h"
#import "ECEventBriteName.h"
#import "ECUser.h"
#import "ECAttendee.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"

@class ECAttendee;
@class ECEventBriteEvent;

@class ECAttendanceResponseTableViewCell;
@protocol ECAttendanceResponseTableViewCellDelegate <NSObject>
- (void)attendListDidUpdateAttendanceReponse:(ECAttendanceResponseTableViewCell *)ecAttendanceResponseTableViewCell;
@end

@interface ECAttendanceResponseTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *feedItemThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTitle;
@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UILabel *feedItemStartTime;
@property (nonatomic, weak) IBOutlet UILabel *feedItemDetails;
@property (nonatomic, weak) IBOutlet UISegmentedControl *attendanceResponse;
//@property (nonatomic, strong) ECEventBriteEvent *selectedEvent;
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, weak) id <ECAttendanceResponseTableViewCellDelegate> delegate;
@property (nonatomic, weak) NSArray *questionOptions;

- (void)configureWithFeedItem:(DCFeedItem *)selectedFeedItem;
@end
