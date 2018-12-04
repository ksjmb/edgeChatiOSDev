//
//  TestTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 2/18/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "TestTableViewCell.h"
#import "ECCommonClass.h"
#import "ECColor.h"
#import "IonIcons.h"

@implementation TestTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _likeButton.layer.cornerRadius = _likeButton.frame.size.width /2;
    _likeButton.layer.masksToBounds = YES;
    _likeButton.layer.borderWidth = 0.5;
    _likeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_likeButton setImage:[IonIcons imageWithIcon:ion_ios_upload_outline size:25.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    _favoriteButton.layer.cornerRadius = _favoriteButton.frame.size.width /2;
    _favoriteButton.layer.masksToBounds = YES;
    _favoriteButton.layer.borderWidth = 0.5;
    _favoriteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_favoriteButton setImage:[IonIcons imageWithIcon:ion_heart size:25.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    
    self.container.layer.shadowOpacity = 1;
    self.container.layer.shadowRadius = 1.0;
    self.container.layer.shadowOffset = CGSizeMake(0, 0);
    self.container.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
