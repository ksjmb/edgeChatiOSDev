//
//  DCFollowFavoriteButtonCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "ECUser.h"

@interface DCFollowFavoriteButtonCell : UITableViewCell
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@property (nonatomic, strong) IBOutlet UIButton *followingButton;
@property (nonatomic, strong) IBOutlet UIButton *followersButton;
@property (nonatomic, strong) IBOutlet UIButton *favoritesButton;

- (void)configureWithUser:(ECUser *)aProfileUser signedInUser:(ECUser *)signedInUser isSignedInUser:(BOOL)isSignedInUser;

@end
