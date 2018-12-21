//
//  DCEventTableViewController.h
//  EventChat
//
//  Created by Jigish Belani on 2/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCEventTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "SignUpLoginViewController.h"
#import "RegisterViewController.h"

@interface DCEventTableViewController : UITableViewController <DCEventTableViewCellDelegate, SignUpLoginViewControllerDelegate, FBSDKSharingDelegate, RegisterViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (nonatomic, strong) DCFeedItem *saveEventFeedItem;

@end
