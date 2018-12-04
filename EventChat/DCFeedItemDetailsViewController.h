#import <UIKit/UIKit.h>
#import "ECEventBriteEvent.h"
#import "ECEventBriteName.h"
#import "ECEventBriteLogo.h"
#import "ECEventBriteStart.h"
#import "ECEventBriteVenue.h"
#import "ECEventBriteVenueAddress.h"
#import "ECEventBriteDescription.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ECMapPinAnnotation.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCTime.h"
#import "DCMediaEntity.h"
#import "DCMediaEntityObject.h"

@class ECEventBriteEvent;

@interface DCFeedItemDetailsViewController : UIViewController<MKMapViewDelegate, FBSDKSharingDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong)DCFeedItem *selectedFeedItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end
