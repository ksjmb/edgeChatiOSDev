//
//  DCNewPostViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/31/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCNewPostViewController.h"
#import "AppDelegate.h"
#import "ECAPI.h"
#import "ECUser.h"
#import "DCPost.h"

@interface DCNewPostViewController ()

@end

@implementation DCNewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self addPlaceHolderText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addPlaceHolderText{
    
    _postTextView.text = NSLocalizedString(@"What's on your mind?", @"placeholder");
    _postTextView.textColor = [UIColor lightGrayColor];
    self.showPlaceHolder = YES; //we save the state so it won't disappear in case you want to re-edit it
}

- (void)textViewDidBeginEditing:(UITextView *)txtView
{
    if (self.showPlaceHolder == YES)
    {
        _postTextView.textColor = [UIColor blackColor];
        _postTextView.text = @"";
        self.showPlaceHolder = NO;
    }
}

- (IBAction)didTapCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)didTapPost:(id)sender{
    self.signedInUser.whatsOnYourMind = _postTextView.text;
    DCPost *post = [[DCPost alloc] init];
    post.userId = self.signedInUser.userId;
    post.displayName = self.signedInUser.firstName;
    post.content = _postTextView.text;
    post.parentId = @"0";
    post.postType = @"text";
    
    [[ECAPI sharedManager] addPost:post callback:^(NSDictionary *jsonDictionary, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
            if([self.delegate respondsToSelector:@selector(refreshPostStream)]){
                [self.delegate refreshPostStream];
            }
        }
    }];
}

@end
