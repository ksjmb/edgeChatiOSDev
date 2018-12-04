//
//  VideoBrowserViewController.m
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "VideoBrowserViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoTrimmerViewController.h"
#import "ECCommonClass.h"
#define RadiansToDegrees(radians) ((radians) * (180.0 / M_PI))
@interface VideoBrowserViewController ()
{
     int checkValue;
}
@property (strong, nonatomic) NSArray *videoAssets;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) ALAssetsLibrary *assetLibrary;

@property (strong, nonatomic) ALAsset *selectedAsset;



@end

@implementation VideoBrowserViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    checkValue = 0;
    self.title = @"Select Video";
    [self fetchAllVideosFromLibrary];
    
    //[self setUpNavigation];
}

- (IBAction)cancelButtonClicked:(id)sender {
   
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)setUpNavigation {
//    
//    CustomNavigationView *navigationView = [[CustomNavigationView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
//    
//    // Add back button
//    [navigationView.leftButton setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
//    [[navigationView leftButton] addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    
//    navigationView.titleLabel.text = @"SELECT VIDEO";
//    [self.view addSubview:navigationView];
//}
//
- (void)fetchAllVideosFromLibrary {
    
    NSMutableArray *mutableVideoAssets = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    void (^enumerate)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset) {
                    [mutableVideoAssets addObject:asset];
                }
            }];
        } else if (group == nil) {
            // Block stops here
            self.videoAssets = [NSArray arrayWithArray:mutableVideoAssets];
            [self refreshData];
        }
    };
    
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                     usingBlock:enumerate
                                   failureBlock:^(NSError *error) {
                                       if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                                           NSLog(@"user denied access, code: %li",(long)error.code);
                                           self.collectionView.hidden = true;
                                       } else {
                                           NSLog(@"Other error code: %li",(long)error.code);
                                       }
                                   }];
}

- (void)refreshData {
    [self.collectionView reloadData];
}

- (UIInterfaceOrientation)videoOrientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform txf = [videoTrack preferredTransform];
    CGFloat videoAngleInDegree = RadiansToDegrees(atan2(txf.b, txf.a));
    
    UIInterfaceOrientation orientation = 0;
    switch ((int)videoAngleInDegree) {
        case 0:
            orientation = UIInterfaceOrientationLandscapeRight;
            break;
        case 90:
            orientation = UIInterfaceOrientationPortrait;
            break;
        case 180:
            orientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case -90:
            orientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        default:
            orientation = UIInterfaceOrientationUnknown;
            break;
    }
    return orientation;
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

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (checkValue!=0) {
        
        if (self.videoAssets.count==0) {
            //[[GlobalConstants sharedInstance] alertViewTitle:MGVAppName message:@"Oops! \n You do not have any videos \n in your phone gallery."];
        }
        
    }
    checkValue ++;
    return self.videoAssets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [self.videoAssets objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:87];
    imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    UILabel *durationLabel = (UILabel *)[cell viewWithTag:89];
    double duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
    durationLabel.text = [self timeFormatted:duration];
    
    return cell;
}

- (NSString *)timeFormatted:(double)totalSeconds
{
    NSTimeInterval timeInterval = totalSeconds;
    long seconds = lroundf(timeInterval); // Modulo (%) operator below needs int or long
    int hour = 0;
    int minute = seconds/60.0f;
    int second = seconds % 60;
    if (minute > 59) {
        hour = minute/60;
        minute = minute%60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    }
    else{
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.selectedAsset = [self.videoAssets objectAtIndex:indexPath.row];
    
    NSLog(@"Video File Name : %@",self.selectedAsset.defaultRepresentation.filename);
    
    [self performSegueWithIdentifier:@"VideoProcessor" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"VideoProcessor"]) {
        VideoTrimmerViewController *trimVideoViewController = segue.destinationViewController;
        trimVideoViewController.movieURL = self.selectedAsset.defaultRepresentation.url;
        trimVideoViewController.movieName = self.selectedAsset.defaultRepresentation.filename;
        trimVideoViewController.isPhoneLibraryVideo = YES;
    }
    

}

@end
