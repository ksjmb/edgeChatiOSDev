//
//  ECIndividualProfileTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 16/07/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECIndividualProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *mUserNameLabel;

- (void)configureCellWithUserItem:(NSString *)fullName profileURL:(NSString *)profileURL  cellIndex:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
