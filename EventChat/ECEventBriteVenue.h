#import "ECJSONModel.h"
#import "ECEventBriteVenueAddress.h"

@class ECEventBriteVenueAddress;

@interface ECEventBriteVenue : ECJSONModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) ECEventBriteVenueAddress *address;
@end
