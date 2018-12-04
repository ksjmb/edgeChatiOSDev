//
//  TestTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 2/18/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface TestTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet CustomButton *likeButton;
@property (nonatomic, weak) IBOutlet CustomButton *commentButton;
@property (nonatomic, weak) IBOutlet CustomButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIView *container;
@end
