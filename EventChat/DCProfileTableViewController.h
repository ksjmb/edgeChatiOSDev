//
//  DCProfileTableViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCommentOrPostCell.h"
#import "DCFollowOrMessageCell.h"
#import "DCNewPostViewController.h"
#import "DCUserPostCell.h"
@class ECUser;

@interface DCProfileTableViewController : UITableViewController <DCCommentOrPostCellDelegate, DCFollowOrMessageCellDelegate, DCNewPostViewControllerDelegate, DCUserPostCellDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *profilePic;
@property (nonatomic, weak) IBOutlet UILabel *givenName;
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@property (nonatomic, strong) NSMutableArray *userPostsArray;
@property (nonatomic, strong) NSArray *followingUsersArray;
@property (nonatomic, strong) NSArray *followerUsersArray;
@property (nonatomic) int selectedSegment;
@end
