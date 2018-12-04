//
//  ECUserListCell.h
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECUser.h"

@interface ECUserListCell : UITableViewCell
- (void)configureWithUser:(ECUser *)ecUser;
@end
