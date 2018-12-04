//
//  DCPlaylistsTableViewController.h
//  EventChat
//
//  Created by Jigish Belani on 11/8/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"
@interface DCPlaylistsTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic) BOOL isFeedMode;
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@property (nonatomic, copy) NSString *feedItemId;
@end
