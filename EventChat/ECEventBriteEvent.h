#import "ECJSONModel.h"
@class ECEventBriteName;
@class ECEventBriteLogo;
@class ECEventBriteStart;
@class ECEventBriteDescription;

@protocol ECEventBriteEvent;

@interface ECEventBriteEvent : ECJSONModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) ECEventBriteName *name;
@property (nonatomic, strong) ECEventBriteLogo *logo;
@property (nonatomic, strong) ECEventBriteStart *start;
@property (nonatomic, strong) ECEventBriteDescription *eventDescription;
@property (nonatomic, strong) NSString *venue_id;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) BOOL isFavorited;
@property (nonatomic, strong) NSString *venueName;
@end
