//
//  DCPersonBlurbTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/26/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCPersonBlurbTableViewCell.h"

@implementation DCPersonBlurbTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithText:(NSString *)blurb{
    [_blurbTextView setText:blurb];
}

@end
