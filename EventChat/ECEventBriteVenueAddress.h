#import "ECJSONModel.h"

@interface ECEventBriteVenueAddress : ECJSONModel
@property (nonatomic, copy) NSString *address_1;
@property (nonatomic, copy) NSString *address_2;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *postal_code;
@property (nonatomic, copy) NSString *country;
@end
