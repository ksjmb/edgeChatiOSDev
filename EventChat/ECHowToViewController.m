//
//  ECHowToViewController.m
//  EventChat
//
//  Created by Jigish Belani on 12/20/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECHowToViewController.h"
#import "IonIcons.h"

@interface ECHowToViewController ()
@property (nonatomic, strong) IBOutlet UIImageView *mainImageView;
@property (strong, nonatomic) NSArray *overlayImages;
@property NSInteger currentIndex;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@end

@implementation ECHowToViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentIndex = 1;
    self.overlayImages = [[NSArray alloc] initWithObjects:@"Overlay1.png", @"Overlay2.png", @"Overlay3.png", nil];
    [self.mainImageView setUserInteractionEnabled:YES];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImage:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImage:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    //[self.mainImageView addGestureRecognizer:swipeLeft];
    //[self.mainImageView addGestureRecognizer:swipeRight];
    [_closeButton setImage:[IonIcons imageWithIcon:ion_ios_close_outline size:50.0 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    _currentIndex = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"HasSeenOverlay"];
    [defaults synchronize];
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view.frame = frame;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.70f];
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

- (IBAction)closeOverlay:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showImageAtIndex:(NSInteger)index
{
    NSString *imageName = [self.overlayImages objectAtIndex:index];
    
    UIImage* image = [UIImage imageNamed:imageName];
    
    NSLog(@"%@", image);
    
    self.mainImageView.image = image;
}

-(void)swipeImage:(UISwipeGestureRecognizer*)recognizer
{
    NSInteger index = _currentIndex;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        index++;
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        index--;
    }
    
    if (index > -1 && index <= ([_overlayImages count] - 1))
    {
        _currentIndex = index;
        self.pageControl.currentPage = index;
        [self showImageAtIndex:_currentIndex];
    }
    else
    {
        NSLog(@"Reached the end, swipe in opposite direction");
    }
    
}

@end
