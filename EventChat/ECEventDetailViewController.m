#import "ECEventDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ECAPI.h"
#import "ECColor.h"
#import "ECTopicViewController.h"
#import "ECEventBriteName.h"
#import "ECEventBriteLogo.h"
#import "ECEventBriteDescription.h"
#import "ECEventBriteEvent.h"
#import "ECUser.h"
#import "ECEventTopicCommentsViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YTPlayerView.h"

@interface ECEventDetailViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *eventPic;
@property (nonatomic, weak) IBOutlet UILabel *eventTitle;
@property (nonatomic, weak) IBOutlet UILabel *eventStartEndTime;
@property (nonatomic, weak) IBOutlet UILabel *eventVenueName;
@property (nonatomic, weak) IBOutlet UILabel *eventVenueAddress;
@property (nonatomic, weak) IBOutlet UITextView *eventDescriptionTextView;
@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) FBSDKShareLinkContent *content;
@property (nonatomic, strong) FBSDKShareDialog *shareDialog;
@property (nonatomic, strong) FBSDKShareButton *shareButton;
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) NSMutableString* directionsURL;
@property (nonatomic, strong) UIAlertView *directionsAlertView;;
@property BOOL canHandleGoogleMaps;
@property (nonatomic, strong) NSMutableArray *topics;
@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@end

@implementation ECEventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playerView loadWithVideoId:@"tPWtOzOynAQ"];
    _canHandleGoogleMaps = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]];
    // Do any additional setup after loading the view.
    NSLog(@"%@", self.selectedEvent.url);
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //The Z at the end of your string represents Zulu which is UTC
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate* newTime = [dateFormatter dateFromString:self.selectedEvent.start.utc];
    NSLog(@"original time: %@", newTime);
    
    //Add the following line to display the time in the local time zone
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"EEE, MMM d 'at' h:mm a"];
    NSString* finalTime = [dateFormatter stringFromDate:newTime];
    NSLog(@"%@", finalTime);
    
    [self.eventTitle setText:self.selectedEvent.name.text];
    [self.eventStartEndTime setText:finalTime];
    NSLog(@"Description: %@", self.selectedEvent.eventDescription.text);
    [self.eventDescriptionTextView setText:self.selectedEvent.eventDescription.text];
    
    // Load event image
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.selectedEvent.logo.url]]];
    [self.eventPic setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"bg.png"]
     
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      _eventPic.image = image;
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}
     ];
    // Get Venue address
    [[ECAPI sharedManager] getEventVenueDetailsById:self.selectedEvent.venue_id callback:^(ECEventBriteVenue *venue, NSError *error) {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            NSLog(@"%@", venue.address);
            [self.eventVenueName setText:venue.name];
            [self.eventVenueAddress setText:[NSString stringWithFormat:@"%@, %@, %@ %@" ,venue.address.address_1, venue.address.city, venue.address.region, venue.address.postal_code]];
            
            // Get Long/Lat
            [[ECAPI sharedManager] getLongitudeLatitudeFromAddress:[self.eventVenueAddress.text stringByReplacingOccurrencesOfString:@" " withString:@"+"] callback:^(NSString *lat, NSString *lng, NSError *error){
                
                MKCoordinateRegion region = { {0.0, 0.0}, {0.0, 0.0} };
                region.center.latitude = [lat doubleValue];
                region.center.longitude = [lng doubleValue];
                region.span.latitudeDelta = 0.01f;
                region.span.longitudeDelta = 0.01f;
                [self.mapView setRegion:region animated:YES];
                MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
                ann.coordinate = region.center;
                ann.title = venue.address.address_1;
                
                [self.mapView addAnnotation:ann];
                //self.directionsURL = [NSMutableString   stringWithString:@"http://maps.apple.com/maps?"];
               
                self.directionsURL = [NSMutableString stringWithString:@"saddr=Current Location"];
                [self.directionsURL appendFormat:@"&daddr=%f,%f", region.center.latitude, region.center.longitude];
            }];
        }
    }];
    
    // Setup event location mapview
//    self.mapView.delegate = self;
//    self.mapView.mapType = MKMapTypeStandard;
//    self.mapView.showsUserLocation = NO;
//
//    
//    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
//    myAnnotation.coordinate = CLLocationCoordinate2DMake(33.887294, -117.966390);
//    myAnnotation.title = @"Matthews Pizza";
//    myAnnotation.subtitle = @"Best Pizza in Town";
//    [self.mapView addAnnotation:myAnnotation];
    
//    MKCoordinateRegion region = { {0.0, 0.0}, {0.0, 0.0} };
//    region.center.latitude = 33.887257;
//    region.center.longitude = -117.966346;
//    region.span.latitudeDelta = 0.01f;
//    region.span.longitudeDelta = 0.01f;
//    [self.mapView setRegion:region animated:YES];
//    ECMapPinAnnotation *ann = [[ECMapPinAnnotation alloc] init];
//    ann.title = @"Title";
//    ann.subtitle = @"Subtitle";
//    ann.coordinate = region.center;
//    [self.mapView addAnnotation:ann];
    
    self.shareDialog = [[FBSDKShareDialog alloc] init];
    self.content = [[FBSDKShareLinkContent alloc] init];
    self.content.contentURL = [NSURL URLWithString:self.selectedEvent.url];
    self.content.contentTitle = @"EventChat";
    self.content.contentDescription = self.selectedEvent.name.text;
    
    self.shareButton = [[FBSDKShareButton alloc] init];
    self.shareButton.shareContent = self.content;
    self.shareButton.frame = CGRectMake(0, 160, 70, 30);
    [self.shareButton addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:self.shareButton];
    
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
    
    NSLog(@"%@", self.selectedEvent.id);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:self.selectedfee callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            
            NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
            self.topics = [[NSMutableArray alloc] initWithArray:topics];
            
            // Push to comments view controller directly
            ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
            ECTopic *topic = [self.topics objectAtIndex:1];
            ecEventTopicCommentsViewController.selectedEvent = self.selectedEvent;
            ecEventTopicCommentsViewController.selectedTopic = topic;
            ecEventTopicCommentsViewController.topicId = topic.topicId;
            
            [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
        }
        
    }];
}

- (IBAction)didTapFavorite:(id)sender{
    NSLog(@"%@", self.selectedEvent);
    [[ECAPI sharedManager] setFavoriteEvent:self.selectedEvent.eventId userId:self.signedInUser.userId callback:^(ECUser *ecUser, NSError *error) {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.signedInUser = ecUser;
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Favorite Saved"
                                      message:@"Favorited events will appear at the top of your feed list. You can manage your favorites from \"More -> Favorites\"."
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
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
