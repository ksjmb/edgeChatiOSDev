//
//  DCStreamingPlayerViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/8/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCStreamingPlayerViewController : UIViewController
@property (nonatomic, strong) NSString *playbackUrl;
@property (nonatomic, strong) NSString *episodeTitle;

- (void)canRotate;
@end
