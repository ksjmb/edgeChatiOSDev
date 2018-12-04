#import "ECJSONModel.h"

@interface ECAppInfo : ECJSONModel

@property (nonatomic, copy) NSString *activeServerVersion;
@property (nonatomic, copy) NSString *activeServerBuild;
@property (nonatomic, copy) NSString *activeAppVersion;
@property (nonatomic, copy) NSString *activeAppBuild;

@end
