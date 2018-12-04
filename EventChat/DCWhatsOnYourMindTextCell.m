//
//  DCWhatsOnYourMindTextCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/30/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCWhatsOnYourMindTextCell.h"
#import "ECUser.h"

@implementation DCWhatsOnYourMindTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithUser:(ECUser *)user{
    [_whatsOnYourMindTextView setText:user.whatsOnYourMind];
}

@end
