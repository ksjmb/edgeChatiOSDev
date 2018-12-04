//
//  DCDigital.h
//  EventChat
//
//  Created by Jigish Belani on 7/17/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECJSONModel.h"

@interface DCDigital : ECJSONModel
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *series;
@property (nonatomic, copy) NSString *seriesDescription;
@property (nonatomic, copy) NSString *seasonNumber;
@property (nonatomic, copy) NSString *episodeNumber;
@property (nonatomic, copy) NSString *episodeTitle;
@property (nonatomic, copy) NSString *episodeDescription;
@property (nonatomic, copy) NSString *director;
@property (nonatomic, copy) NSString *starring;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *videoUrl;
@end
