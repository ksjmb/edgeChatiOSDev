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
#import "AddToPlaylistPopUpViewController.h"

@interface DCEventTableViewController : UIViewController <DCEventTableViewCellDelegate, SignUpLoginViewControllerDelegate, FBSDKSharingDelegate, RegisterViewControllerDelegate, AddToPlaylistDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (nonatomic, strong) DCFeedItem *saveEventFeedItem;

@end
