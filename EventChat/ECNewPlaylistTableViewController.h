//
//  ECNewPlaylistTableViewController.h
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"

@interface ECNewPlaylistTableViewController : UITableViewController
@property (nonatomic) BOOL isFeedMode;
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@property (nonatomic, copy) NSString *feedItemId;
@property (nonatomic, strong) NSMutableArray *playlistArray;

@property (strong, nonatomic) IBOutlet UITableView *playlistTableView;

@end
