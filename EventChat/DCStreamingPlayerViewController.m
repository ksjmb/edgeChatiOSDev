//
//  DCStreamingPlayerViewController.m
//  EventChat
//
//  Created by Jigish Belani on 1/8/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCStreamingPlayerViewController.h"
#import "KSVideoPlayerView.h"
#import "IonIcons.h"

@interface DCStreamingPlayerViewController ()
@property (strong, nonatomic) KSVideoPlayerView* player;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleBarButton;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@end

@implementation DCStreamingPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_arrow_back  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapClose:)];
    self.titleBarButton = [[UIBarButtonItem alloc] initWithTitle:_episodeTitle style:UIBarButtonItemStylePlain target:self action:nil];

    [self.titleBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"VOYAGER-LIGHT" size:17.0], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.player = [[KSVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) contentURL:[NSURL URLWithString:_playbackUrl]];
    [self.view addSubview:self.player];
    [self.player.topToolBar setItems:@[self.backBarButtonItem]];
    self.player.tintColor = [UIColor redColor];
    [self.player play];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [UIView animateWithDuration:duration animations:^{
        if(UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
            self.player.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        } else {
            self.player.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)canRotate{
    
}

-(void)viewDidAppear:(BOOL)animated{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)didTapClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLayoutSubviews
{
    NSLog(@"layout subviews called");
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;
    
    NSLog(@"%d x %d",width, height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
