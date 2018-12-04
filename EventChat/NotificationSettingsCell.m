//
//  NotificationSettingsCell.m
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "NotificationSettingsCell.h"

@interface NotificationSettingsCell()
@property (nonatomic, weak) IBOutlet UILabel *settingLabel;
@property (nonatomic, weak) IBOutlet UISwitch *settingSwitch;
@end

@implementation NotificationSettingsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithData:(NSString *)settingKey{
    [self.settingLabel setText:settingKey];
}

@end
