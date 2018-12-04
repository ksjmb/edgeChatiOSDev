//
//  DCNewPostViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/31/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECUser;

@protocol DCNewPostViewControllerDelegate <NSObject>
- (void)refreshPostStream;
@end

@interface DCNewPostViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) IBOutlet UITextView *postTextView;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, weak) id <DCNewPostViewControllerDelegate> delegate;
@end
