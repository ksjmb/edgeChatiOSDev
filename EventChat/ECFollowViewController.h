//
//  ECFollowViewController.h
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECFollowCell.h"
@class ECUser;

@interface ECFollowViewController : UIViewController
@property (nonatomic, strong)ECUser *dcUser;
@property (nonatomic, assign) BOOL showFollowing;
@property (nonatomic, strong) NSArray *usersArray;
@property (nonatomic, retain) NSString *mSelectedLoginUserId;
@property (nonatomic, assign) BOOL isComeFromProfile;

@end
