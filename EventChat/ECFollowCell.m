//
//  ECFollowCell.m
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECFollowCell.h"

@interface ECFollowCell()
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profilePic;
@end

@implementation ECFollowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithUser:(ECUser *)ecUser{
    [self.userNameLabel setText:[NSString stringWithFormat:@"%@ %@", ecUser.firstName, ecUser.lastName]];
    
    // Set profile pic
    if(ecUser.profilePicUrl != nil){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ecUser.profilePicUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [self.profilePic setImage:image];
    }
}

@end
