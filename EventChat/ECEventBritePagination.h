#import "ECJSONModel.h"
@protocol ECEventBritePagination;

@interface ECEventBritePagination : ECJSONModel
@property (nonatomic, copy) NSString *object_count;
@property (nonatomic, copy) NSString *page_count;
@property (nonatomic, copy) NSString *page_number;
@property (nonatomic, copy) NSString *page_size;
@end
