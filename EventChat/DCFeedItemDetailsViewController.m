//
//  DCFeedItemDetailsViewController.m
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "DCFeedItemDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ECAPI.h"
#import "ECColor.h"
#import "ECTopicViewController.h"
#import "ECUser.h"
#import "ECEventTopicCommentsViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YTPlayerView.h"
#import "DCFeedItemDetailsWebViewController.h"
#import "IonIcons.h"

@interface DCFeedItemDetailsViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *feedItemThumbnail;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTitle;
@property (nonatomic, weak) IBOutlet UILabel *feedItemTitleTopSub;
@property (nonatomic, weak) IBOutlet UILabel *feedItemBottomMain;
@property (nonatomic, weak) IBOutlet UILabel *feedItemBottomSub;
@property (nonatomic, weak) IBOutlet UITextView *feedItemDescription;
@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareButton *shareButton;
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) NSMutableString* directionsURL;
@property (nonatomic, strong) UIAlertView *directionsAlertView;
@property BOOL canHandleGoogleMaps;
@property (nonatomic, strong) NSMutableArray *topics;
@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@end

@implementation DCFeedItemDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load Video
    if([self.selectedFeedItem.media.youtube.videoUrl rangeOfString:@"watch"].location == NSNotFound){
        [self.playerView loadWithVideoId:@"tPWtOzOynAQ"];
    }
    else{
        [self.playerView loadWithVideoId:[self.selectedFeedItem.media.youtube.videoUrl componentsSeparatedByString:@"="][1]];
    }
    
    _canHandleGoogleMaps = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]];
    // Do any additional setup after loading the view.
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    [self.feedItemTitle setText:self.selectedFeedItem.title];
//    [self.feedItemTitleTopSub setText:[NSString stringWithFormat:@"%@ - S%@ E%@ - %@", self.selectedFeedItem.digital.series, self.selectedFeedItem.digital.season, self.selectedFeedItem.digital.episode, self.selectedFeedItem.time.duration]];
    [self.feedItemTitleTopSub setText:self.selectedFeedItem.influencer];
    [self.feedItemDescription setText:self.selectedFeedItem.itemDescription];
    
    // Load event image
    self.feedItemThumbnail.layer.masksToBounds = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.selectedFeedItem.mainImage_url]]];
    [self.feedItemThumbnail setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"bg.png"]
     
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      _feedItemThumbnail.image = image;
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}
     ];
    
    self.shareDialog = [[FBSDKShareDialog alloc] init];
    self.content = [[FBSDKShareLinkContent alloc] init];
    self.content.contentURL = [NSURL URLWithString:self.selectedFeedItem.website_url];
    self.content.contentTitle = @"EventChat";
    self.content.contentDescription = self.selectedFeedItem.title;
    
    self.shareButton = [[FBSDKShareButton alloc] init];
    self.shareButton.shareContent = self.content;
    self.shareButton.frame = CGRectMake(0, 160, 70, 30);
    [self.shareButton addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:self.shareButton];
    [self.navigationItem.rightBarButtonItem setImage:[IonIcons imageWithIcon:ion_ios_redo  size:30.0 color:[UIColor whiteColor]]];
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

#pragma mark - Facebook Delegate Methods
- (IBAction)shareToFacebook:(id)sender {
    NSLog(@"Share to Facebook");
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
        [self.shareDialog setMode:FBSDKShareDialogModeNative];
    }
    else {
        [self.shareDialog setMode:FBSDKShareDialogModeAutomatic];
    }
    //[self.shareDialog setMode:FBSDKShareDialogModeShareSheet];
    [self.shareDialog setShareContent:self.content];
    [self.shareDialog setFromViewController:self];
    [self.shareDialog setDelegate:self];
    [self.shareDialog show];
    //[FBSDKShareDialog showFromViewController:self withContent:self.content delegate:self];
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary *)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

#pragma mark - MapView Delegate Methods

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        NSLog(@"Clicked Pizza Shop");
    }
    if(_canHandleGoogleMaps){
        _directionsAlertView = [[UIAlertView alloc] initWithTitle:@"Directions" message:@"Would you like to get directions to this event?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Apple Maps", @"Google Maps", nil];
    }
    else{
        _directionsAlertView = [[UIAlertView alloc] initWithTitle:@"Directions" message:@"Would you like to get directions to this event?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    
    [_directionsAlertView show];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.calloutOffset = CGPointMake(0, 32);
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            // Add an image to the left callout.
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
            pinView.leftCalloutAccessoryView = iconView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    CGRect visibleRect = [mapView annotationVisibleRect];
    for (MKAnnotationView *view in views){
        CGRect endFrame = view.frame;
        endFrame.origin.y -= 15.0f;
        endFrame.origin.x += 8.0f;
        CGRect startFrame = endFrame;
        startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
        view.frame = startFrame;
        
        [UIView beginAnimations:@"drop" context:NULL];
        [UIView setAnimationDuration:0.2];
        
        view.frame = endFrame;
        [mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
        
        [UIView commitAnimations];
    }
}

#pragma mark Zoom

- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender {
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Controller methods
- (IBAction)didTapTopics:(id)sender{
    //    ECTopicViewController *ecTopicViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECTopicViewController"];
    //    ecTopicViewController.selectedEvent = self.selectedEvent;
    //    ecTopicViewController.eventId = self.selectedEvent.id;
    //
    //    [self.navigationController pushViewController:ecTopicViewController animated:YES];
    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    [[ECAPI sharedManager] fetchTopicsByEventId:self.selectedEvent.id callback:^(NSArray *topics, NSError *error)  {
//        if(error){
//            NSLog(@"Error: %@", error);
//        }
//        else{
//            
//            NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
//            self.topics = [[NSMutableArray alloc] initWithArray:topics];
//            
//            // Push to comments view controller directly
//            ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
//            ECTopic *topic = [self.topics objectAtIndex:1];
//            ecEventTopicCommentsViewController.selectedEvent = self.selectedEvent;
//            ecEventTopicCommentsViewController.selectedTopic = topic;
//            ecEventTopicCommentsViewController.topicId = topic.topicId;
//            
//            [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
//        }
//        
//    }];
}

- (IBAction)didTapFavorite:(id)sender{
//    NSLog(@"%@", self.selectedEvent);
//    [[ECAPI sharedManager] setFavoriteEvent:self.selectedEvent.eventId userId:self.signedInUser.userId callback:^(ECUser *ecUser, NSError *error) {
//        if(error){
//            NSLog(@"Error: %@", error);
//        }
//        else{
//            self.signedInUser = ecUser;
//            UIAlertView *alertView = [[UIAlertView alloc]
//                                      initWithTitle:@"Favorite Saved"
//                                      message:@"Favorited events will appear at the top of your feed list. You can manage your favorites from \"More -> Favorites\"."
//                                      delegate:nil
//                                      cancelButtonTitle:@"Okay"
//                                      otherButtonTitles:nil];
//            [alertView show];
//        }
//    }];
}

- (IBAction)didLoadWebView:(id)sender{
    DCFeedItemDetailsWebViewController *dcFeedItemDetailsWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCFeedItemDetailsWebViewController"];
    [dcFeedItemDetailsWebViewController setSelectedFeedItem:_selectedFeedItem];
    dcFeedItemDetailsWebViewController.providesPresentationContextTransitionStyle = YES;
    dcFeedItemDetailsWebViewController.definesPresentationContext = YES;
    [dcFeedItemDetailsWebViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:dcFeedItemDetailsWebViewController] animated:YES completion: nil];
}

#pragma mark - Action sheet
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self didTapTopics:nil];
                    break;
                case 1:
                    [self didTapFavorite:nil];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Action sheet
- (IBAction)didTapMoreOptionsButton:(id)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Comments", @"Set as Favorite",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - AlertView Delegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://maps.apple.com/maps?%@", _directionsURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    else if (buttonIndex == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://maps.google.com/maps?%@", _directionsURL] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

@end
