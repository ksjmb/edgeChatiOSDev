#import "ECJSONModel.h"
#import "ECEventBritePagination.h"
#import "ECEventBriteLocation.h"

@class ECEventBriteLocation;

@interface ECEventBriteSearchResult : ECJSONModel

@property (nonatomic, strong) ECEventBritePagination *pagination;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) ECEventBriteLocation *location;

@end
