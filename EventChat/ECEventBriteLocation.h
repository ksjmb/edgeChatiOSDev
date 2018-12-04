#import "ECJSONModel.h"
@protocol ECEventBriteLocation;

@interface ECEventBriteLocation : ECJSONModel
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *within;
@property (nonatomic, copy) NSString *longitude;

@end
