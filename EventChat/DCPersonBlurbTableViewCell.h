//
//  DCPersonBlurbTableViewCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPersonBlurbTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UITextView *blurbTextView;

-(void)configureWithText:(NSString *)blurb;
@end
