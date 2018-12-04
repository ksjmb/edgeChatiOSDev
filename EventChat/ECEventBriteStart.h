#import "ECJSONModel.h"

@interface ECEventBriteStart : ECJSONModel
@property (nonatomic, copy) NSString *timezone;
@property (nonatomic, copy) NSString *local;
@property (nonatomic, copy) NSString *utc;
@end
