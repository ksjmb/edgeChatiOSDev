//
//  VideoTrimmerViewController.h
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECTopic.h"

@interface VideoTrimmerViewController : UIViewController
@property (strong, nonatomic) NSURL *movieURL;
@property (strong, nonatomic) NSString *movieName;
@property (assign) BOOL isPhoneLibraryVideo;

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender;
-(void)performUpload: (NSURL *)videoURL;

@end
