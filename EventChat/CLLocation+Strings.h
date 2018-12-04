//
//  CLLocation (Strings).h
//  TabBarWithSplitView
//
//  Created by Jigish Belani on 3/23/12.
//  Copyright (c) 2012 Mota Motors, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>


@interface CLLocation (Strings)

- (NSMutableArray *)localizedCoordinateString;

- (NSString *)localizedAltitudeString;

- (NSString *)localizedHorizontalAccuracyString;

- (NSString *)localizedVerticalAccuracyString;

- (NSString *)localizedCourseString;

- (NSString *)localizedSpeedString;

@end