//
//  ECCustomYoutubePlayerViewController.h
//  EventChat
//
//  Created by Mindbowser on 09/05/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

//NS_ASSUME_NONNULL_BEGIN

@interface ECCustomYoutubePlayerViewController : UIViewController

@property (weak, nonatomic) IBOutlet YTPlayerView *mPlayerView;
@property (weak, nonatomic) IBOutlet UIView *topOverlayView;

@end

@implementation ECCustomYoutubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mPlayerView playVideo];
}


@end

//NS_ASSUME_NONNULL_END
