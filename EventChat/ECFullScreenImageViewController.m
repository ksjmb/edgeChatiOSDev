//
//  ECFullScreenImageViewController.m
//  EventChat
//
//  Created by Mindbowser on 4/14/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECFullScreenImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ImageScrollView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ECCommonClass.h"
@interface ECFullScreenImageViewController ()
{
    MPMoviePlayerController * theMoviPlayer;
}
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonClicked:(UIButton *)sender;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ECFullScreenImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
    if (isInternetAvailable) {
        [self displayImageInFullView];
        
    } else {
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)displayImageInFullView{
    
    __weak ECFullScreenImageViewController *weakSelf = self;
    self.imageView  = [[UIImageView alloc] initWithFrame:self.view.frame];
    NSURL *imageURL = [NSURL URLWithString:self.imagePath];
   // hud  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[self.imageView bringSubviewToFront:hud];
    
    
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    

    [self.imageView sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [activityView removeFromSuperview];
        NSLog(@"");
        if (error) {
            NSLog(@"Error for not displaying image = %@",error.localizedDescription);
        }
        ImageScrollView *scrollView = [[ImageScrollView alloc] initWithFrame:weakSelf.view.frame];
        [scrollView configureDisplayImage:image];
        scrollView.index = 1;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [weakSelf.view addSubview:scrollView];
        
        [weakSelf.view bringSubviewToFront:weakSelf.closeButton];

    }];
//    [self.imageView setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        NSLog(@"");
//        if (error) {
//            NSLog(@"Error for not displaying image = %@",error.localizedDescription);
//        }
//        ImageScrollView *scrollView = [[ImageScrollView alloc] initWithFrame:weakSelf.view.frame];
//        [scrollView configureDisplayImage:image];
//        scrollView.index = 1;
//        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [weakSelf.view addSubview:scrollView];
//        
//        [weakSelf.view bringSubviewToFront:weakSelf.closeButton];
//        
//        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLikeCount" object:nil];
//    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
}

-(void)Playvideo
{
    NSString *moviePath = self.videoPath;
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath] ;
    
    
    theMoviPlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    theMoviPlayer.controlStyle = MPMovieControlStyleFullscreen;
    theMoviPlayer.view.transform = CGAffineTransformConcat(theMoviPlayer.view.transform, CGAffineTransformMakeRotation(M_PI_2));
    UIView *backgroundWindow = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    [theMoviPlayer.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [backgroundWindow addSubview:theMoviPlayer.view];
    [theMoviPlayer beginSeekingForward];
    [theMoviPlayer play];
    [self.view addSubview:backgroundWindow];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
