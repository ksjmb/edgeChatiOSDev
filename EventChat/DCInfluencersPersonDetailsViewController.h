//
//  DCInfluencersPersonDetailsViewController.h
//  EventChat
//
//  Created by Mindbowser on 13/12/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpLoginViewController.h"
@class DCFeedItem;

NS_ASSUME_NONNULL_BEGIN

@interface DCInfluencersPersonDetailsViewController : UIViewController <SignUpLoginViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mBKImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mProfilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *mPersonTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mPersonDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *mFollowbtn;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
//
@property (nonatomic, strong) DCFeedItem *mSelectedDCFeedItem;
@property (nonatomic, strong) DCFeedItem *saveSelectedFeedItem;

- (void)pushToSignInViewController :(NSString*)stbIdentifier;
@end

NS_ASSUME_NONNULL_END
