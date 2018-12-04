 //
//  VideoTrimmerViewController.m
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "VideoTrimmerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GPUImage.h"
#import "ECVideoRangeSlider.h"
//#import "YGVVideoConstants.h"
//#import "AddMediaDetailsController.h"
//#import "AppUserData.h"
//#import "MediaSharedData.h"
//#import "S3AmazonService.h"
#import "ECCommonClass.h"
#import <AVFoundation/AVFoundation.h>
#import "ECConstants.h"
#import "SVProgressHUD.h"
#import "S3Constants.h"
#import "Message.h"
#import "ECAPINames.h"
#import "ECVideoConstants.h"
#import "S3UploadVideo.h"
#import "ECAPI.h"
#import "ECSharedmedia.h"
#import "ECVideoData.h"
#import "ECEventTopicCommentsViewController.h"
#import <MBProgressHUD.h>
#import "ECUser.h"
//#import "S3AmazonService.h"

@interface VideoTrimmerViewController () <ECVideoRangeSliderDelegate, UINavigationControllerDelegate> {
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    
    GPUImageMovie *secondMovieFile;
    GPUImageOutput<GPUImageInput> *secondFilter;
    GPUImageMovieWriter *secondMovieWriter;
    NSUInteger selectedFilterTag;
    BOOL shouldUpload;
    ECVideoData *sharedData;
    MBProgressHUD *hud;

    
}

@property (strong, nonatomic) IBOutlet UIView *trimmingSliderStrip;
@property (strong, nonatomic) IBOutlet GPUImageView *playerView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *videoStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *showTrimButton;
@property (strong, nonatomic) IBOutlet UIScrollView *previewFiltersScrollView;
@property (weak, nonatomic) IBOutlet GPUImageView *secondPlayerView;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (nonatomic, strong)ECUser *signedInUser;


@property (strong, nonatomic) ECVideoRangeSlider *videoRangeSlider;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;

@property (strong, nonatomic) AVPlayer *mainPlayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (weak, nonatomic) NSTimer *exportProgressBarTimer;
@property (weak, nonatomic) NSTimer *moviePlayerTimer;
@property (strong, nonatomic) NSString *filterName;

@property (strong, nonatomic) UIView *selectionView;
//@property (strong, nonatomic) NavigationView *navigationView;

@property (strong, nonatomic) NSURL *trimVideoURL;
@property (strong, nonatomic) NSURL *trimVideoOutputURL;
@property (strong, nonatomic) NSURL *appliedFiltersVideoURL;

@property (strong, nonatomic) UIImageView *playImageView;
@property (strong, nonatomic) NSDictionary *uploadVideoInfo;
@end

@implementation VideoTrimmerViewController

#pragma mark - ViewController Life Cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedData = [ECVideoData sharedInstance];
    self.moviePlayerTimer = [NSTimer scheduledTimerWithTimeInterval:kMaximumVideoDuration target:self selector:@selector(playVideoFromStartTime) userInfo:nil repeats:YES];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    [self setupMoviePlayer];
    
//    self.videoStatusLabel.text = @"Applying video filter...";
    
    self.secondPlayerView.hidden = true;
    self.showTrimButton.hidden = true;
    self.videoStatusLabel.hidden = true;
}


- (UIImage *)generateCompressedThumbnailImage {
    // Get the thumnail image form video and make it of small size
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.movieURL options:nil];
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = true;
    UIImage *tmpThumbnailImage = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
    
    // Compress the image with aspect fit
    CGSize aspectSize = CGSizeMake(100, 100);
    CGSize imageViewSize = CGSizeMake(100, 100);
    CGFloat aspect = tmpThumbnailImage.size.width / tmpThumbnailImage.size.height;
    if (imageViewSize.width / aspect <= imageViewSize.height) {
        aspectSize = CGSizeMake(imageViewSize.width, imageViewSize.width / aspect);
    } else {
        aspectSize = CGSizeMake(imageViewSize.height * aspect, imageViewSize.height);
    }
    
    UIGraphicsBeginImageContext(aspectSize);
    [tmpThumbnailImage drawInRect:CGRectMake(0, 0, aspectSize.width, aspectSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.progressView.hidden = true;
    self.videoStatusLabel.hidden = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

//Video status when application goes in background
- (void)applicationWillResignActive {
    [self pauseVideo];
    
    if (secondMovieWriter) {
        [secondMovieFile cancelProcessing];
        [secondMovieWriter cancelRecording];
        
        secondMovieFile = nil;
        secondMovieWriter = nil;
    }
    
    self.progressView.progress = 0.0;
    
    self.progressView.hidden = true;
    self.videoStatusLabel.hidden = true;
    self.secondPlayerView.hidden = true;
}


//Video status when application enters in foreground
- (void)applicationWillEnterForeground {
    // Pop to edit video screen if video is not ready for upload
    // Beacause GPUImage view will not run in background resulting in uncompletion of applyign filters
    if (![[ECVideoConstants sharedInstance] isecVideoReadyForUpload]) {
        if ([self.navigationController.viewControllers containsObject:self]) {
            [self.navigationController popToViewController:self animated:YES];
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self setupVideoRangeSlider];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self pauseVideo];
    [super viewWillDisappear:YES];
}

- (void)tearDownAllSetup {
    self.progressView = nil;
    movieFile = nil;
    filter = nil;
    movieWriter = nil;
    
    if (secondMovieWriter) {
        [secondMovieFile cancelProcessing];
        [secondMovieWriter cancelRecording];
    }
    
    [self pauseVideo];
    [self.mainPlayer pause];
    
    secondMovieFile = nil;
    secondFilter = nil;
    secondMovieWriter = nil;
    
    @try {
        [self.playerItem removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification];
    } @catch (NSException *exception) {
        
    }
    
    self.mainPlayer = nil;
    self.playerItem = nil;
}

- (void)lockAllControls:(BOOL)status {
    status = !status;
    self.navigationController.navigationBar.userInteractionEnabled = status;
    self.previewFiltersScrollView.userInteractionEnabled = status;
    self.videoRangeSlider.userInteractionEnabled = status;
    //self.showFiltersButton.enabled = status;
    self.showTrimButton.enabled = status;
    }

#pragma mark - Button Outlets

-(void)performUpload: (NSURL *)videoURL
{
    // Show add media details screen
    [self pauseVideo];
    [self uploadVideoAtURL:self.movieURL];
    
    if (self.isPhoneLibraryVideo) {
        shouldUpload = YES;
        self.trimVideoURL = self.movieURL;
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Preparing to upload";
        hud.detailsLabelText = @"  ";
        [self trimVideo];
        
    } else {
    }
    
}

- (IBAction)nextBarButtonClicked:(id)sender {
    [self performUpload: self.movieURL];
}

#pragma mark - Video Filter Methods

- (void)setupMoviePlayer {
    self.mainPlayer = [[AVPlayer alloc] init];
    
    // AVPlayerItem is initialized with required url
    self.playerItem = [[AVPlayerItem alloc] initWithURL:self.movieURL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    [self.mainPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    
    //GPUImageMovie is initialized with AVPlayerItem
    movieFile = [[GPUImageMovie alloc] initWithPlayerItem:self.playerItem];
    movieFile.runBenchmark = NO;
    movieFile.playAtActualSpeed = YES;
    
    // Adding targets for movieFile and filter
    filter = [[GPUImageFilter alloc] init];
    [self setRotationForFilter:filter];
    
    secondFilter = [[GPUImageFilter alloc] init];
    [self setRotationForFilter:secondFilter];
    
    [movieFile addTarget:filter];
    [filter addTarget:self.playerView];
    
    [movieFile startProcessing];
    [self.mainPlayer play];
}

- (void)setRotationForFilter:(GPUImageOutput<GPUImageInput> *)filterRef {
    UIInterfaceOrientation orientation = [self orientationForTrack:self.playerItem.asset];
    if (orientation == UIInterfaceOrientationPortrait) {
        [filterRef setInputRotation:kGPUImageRotateRight atIndex:0];
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        [filterRef setInputRotation:kGPUImageRotate180 atIndex:0];
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [filterRef setInputRotation:kGPUImageRotateLeft atIndex:0];
    }
}

- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}


- (void)uploadVideoAtURL:(NSURL *)videoURL {
    
    NSString *uniqId = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];;
    
    sharedData.mediaURL            = kS3VideoURLPath(uniqId, uniqId);
    sharedData.mediaThumbImageURL  = kS3VideoTImageURLPath(uniqId, uniqId);
    sharedData.mediaDataFilePath   = videoURL;
    sharedData.mediaUniqueId       = uniqId;
    
    UIImage *thumbnailImage = [[ECVideoConstants sharedInstance] thumbnailImageFromVideoAtURL:videoURL];
    thumbnailImage = [[ECVideoConstants sharedInstance] compressImage:thumbnailImage];
    
    //Converting image to data
    NSData *data = UIImagePNGRepresentation(thumbnailImage);
    
    //Path for the documentDirectory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"Thumbnail.png"] atomically:YES];

    //Assigning thumbImage to singleton class
    sharedData.mediaThumbImage = [[ECVideoConstants sharedInstance] compressImage:thumbnailImage];
}



-(void)playMovie:(NSURL *)movieURL {
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [theMovie.moviePlayer play];
}


#pragma mark - Video Range Slider

- (void)setupVideoRangeSlider {
    double videoDuration = CMTimeGetSeconds(self.playerItem.asset.duration);
    if (videoDuration > kMaximumVideoDuration) {
        if (self.videoRangeSlider == nil) {
            self.videoRangeSlider = [[ECVideoRangeSlider alloc] initWithFrame:CGRectMake(20, 15, self.view.frame.size.width-40, 50) videoUrl:self.movieURL];
            self.videoRangeSlider.minGap = kMaximumVideoDuration;
            
            double maxDuration = videoDuration < kMaximumVideoDuration ? videoDuration : kMaximumVideoDuration;
            
            self.videoRangeSlider.maxGap = maxDuration;
            self.videoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
            self.videoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
            self.videoRangeSlider.delegate = self;
            [self.trimmingSliderStrip addSubview:self.videoRangeSlider];
        }
    } else {
       //self.constraintShowFiltersButtonWidth.constant = self.view.frame.size.width;
       
        self.showTrimButton.hidden = true;
        //directly upload thr video
        [self uploadVideoAtURL:self.movieURL];
    }
}

- (void)videoRange:(ECVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.startTime = leftPosition;
    self.stopTime = rightPosition;
    
    [self.moviePlayerTimer invalidate];
    CMTime startTime = CMTimeMakeWithSeconds(self.startTime, NSEC_PER_SEC);
    [self.mainPlayer seekToTime:startTime];
    
    CGFloat remainingTime = self.stopTime - self.startTime;
    self.moviePlayerTimer = [NSTimer scheduledTimerWithTimeInterval:remainingTime target:self selector:@selector(playVideoFromStartTime) userInfo:nil repeats:YES];
}

#pragma mark - Video Player Methods

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self playVideoFromStartTime];
}

- (void)playVideoFromStartTime {
    
    [self.moviePlayerTimer invalidate];
    self.moviePlayerTimer = nil;
    
    CGFloat remainingTime = kMaximumVideoDuration - self.startTime;
    self.moviePlayerTimer = [NSTimer scheduledTimerWithTimeInterval:remainingTime target:self selector:@selector(playVideoFromStartTime) userInfo:nil repeats:YES];
    
    CMTime startTime = CMTimeMakeWithSeconds(self.startTime, NSEC_PER_SEC);
    [self.mainPlayer seekToTime:startTime];
    [self.mainPlayer play];
}

- (IBAction)handlePlayPauseTap:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint touchPoint = [tapRecognizer locationInView:self.playerView];
    CGFloat bottomViewHeight = CGRectGetHeight(self.playerView.frame) - CGRectGetHeight(self.previewFiltersScrollView.frame);
    if (touchPoint.y < bottomViewHeight) {
        if (self.mainPlayer.rate > 0) {
            [self pauseVideo];
            // Show play icon
            if (self.playImageView == nil) {
                self.playImageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
                self.playImageView.center = self.view.center;
                self.playImageView.image = [UIImage imageNamed:@"Play1.png"];
            }
            [self.view addSubview:self.playImageView];
        } else {
            [self playVideo];
            // Hide play icon
            [self.playImageView removeFromSuperview];
        }
    }
}

- (void)playVideo {
    CGFloat currentTime = CMTimeGetSeconds(self.mainPlayer.currentTime);
    CGFloat remainingTime = kMaximumVideoDuration - (currentTime - self.startTime);
    if (!isnan(remainingTime)) {
        self.moviePlayerTimer = [NSTimer scheduledTimerWithTimeInterval:remainingTime target:self selector:@selector(playVideoFromStartTime) userInfo:nil repeats:YES];
        [self.mainPlayer play];
    }
}

- (void)pauseVideo {
    [self.moviePlayerTimer invalidate];
    [self.mainPlayer pause];
}

#pragma mark - Extra Support Methods

- (void)logEditedVideoFileSize:(NSString *)videoPath {
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:&attributesError];
    NSString *string = [NSByteCountFormatter stringFromByteCount:[fileAttributes fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    NSLog(@"%@",string);
}

#pragma mark - Video Trimmer

-(void)trimVideo{
{
    // Add background task handler so that trimming will not be interrupted when app goes in background
    UIApplication * application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        //Clean up code. Tell the system that we are done.
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.trimVideoURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
    
    NSString *temporaryDirectoryPath = NSTemporaryDirectory();
    NSString *outputURLPath = [temporaryDirectoryPath stringByAppendingPathComponent:@"output.mp4"];
    NSURL *outputURL = [NSURL fileURLWithPath:outputURLPath];
    self.trimVideoOutputURL = outputURL;
    
    
    
    
    // Remove Existing File
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:outputURLPath error:nil];
    
    exportSession.outputURL = outputURL;
    exportSession.shouldOptimizeForNetworkUse = NO;
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    double videoDuration = CMTimeGetSeconds(asset.duration);
    if (videoDuration > kMaximumVideoDuration) {
        videoDuration = kMaximumVideoDuration;
    }
    
    CMTime start = CMTimeMakeWithSeconds(self.videoRangeSlider.leftPosition, asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(videoDuration, asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
        
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted: {
                if (shouldUpload) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                     });
                    NSLog(@"Event Chat video ready for upload");
                    ECVideoConstants *sharedVideoConstants = [ECVideoConstants sharedInstance];
                    sharedVideoConstants.ecVideoReadyForUpload = YES;
                    sharedVideoConstants.outputURL = outputURL;
                    sharedData.videoURL = outputURL;
                    AVURLAsset *asset1 = [AVURLAsset URLAssetWithURL:outputURL options:nil];
                    
                    NSTimeInterval durationInSeconds = 0.0;
                    if (asset1)
                        durationInSeconds = CMTimeGetSeconds(asset1.duration);
                    NSLog(@"Duration = %f",durationInSeconds);
                    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:durationInSeconds] forKey:ECMediaLength];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadVideoToS3" object:nil];
                     dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                    for (UIViewController *aViewController in allViewControllers) {
                        if ([aViewController isKindOfClass:[ECEventTopicCommentsViewController class]]) {
                            [self.navigationController popToViewController:aViewController animated:YES];
                        }
                    }
                });
                    [hud hide:YES];
                } else {
                    // Do not call this method, when application is in background mode.
                    [hud hide:YES];
                }
                
                [application endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid;
                
                break;
            }
            case AVAssetExportSessionStatusFailed: {
                NSDictionary *userInfo = [exportSession.error userInfo];
                NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
                NSLog(@"Underlyign Error : %@",errorString);
                NSLog(@"Failed:%@",exportSession.error);
                break;
            }
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",exportSession.error);
                break;
            default:
                break;
        }
    }];
}
    
    
    
}

- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender {
    
    [self tearDownAllSetup];
    [self.navigationController popViewControllerAnimated:YES];
}
@end





