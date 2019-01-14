//
//  ECUserProfileSocialTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 14/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "ECUser.h"

@class ECUser;

NS_ASSUME_NONNULL_BEGIN

@interface ECUserProfileSocialTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CustomButton *mFacebookButton;
@property (weak, nonatomic) IBOutlet CustomButton *mTwitterButton;
@property (weak, nonatomic) IBOutlet CustomButton *mInstagramButton;

@property (nonatomic, strong) NSArray *followingUsersArray;
@property (nonatomic, strong) NSArray *followerUsersArray;
@property (nonatomic, assign) NSString *userEmailStr;

-(void)configureSocialCell:(ECUser *)user :(ECUser *)loginUser;

@end

NS_ASSUME_NONNULL_END
