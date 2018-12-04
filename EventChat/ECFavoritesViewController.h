//
//  ECFavoritesViewController.h
//  EventChat
//
//  Created by Jigish Belani on 11/7/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECFavoritesCell.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"

@class ECEventBriteEvent;
@class ECFavoritesCell;

@interface ECFavoritesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ECFavoritesCellDelegate>
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@property (nonatomic, strong) NSMutableArray *favoriteList;
@property (nonatomic, copy) NSString *playlistId;
@property (nonatomic, weak) IBOutlet UITableView *favoritesListTableView;
@property (nonatomic, assign) BOOL canShare;
@end
