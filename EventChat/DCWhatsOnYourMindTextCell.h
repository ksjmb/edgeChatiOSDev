//
//  DCWhatsOnYourMindTextCell.h
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECUser;

@interface DCWhatsOnYourMindTextCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UITextView *whatsOnYourMindTextView;

;- (void)configureWithUser:(ECUser *)user;
@end
