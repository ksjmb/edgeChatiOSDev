//
//  ECProfileTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECProfileCell : UITableViewCell

- (void)configureWithData:(NSString *)key value:(NSString *)value;
@end
