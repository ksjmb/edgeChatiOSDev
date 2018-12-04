//
//  CLLocation (Strings).m
//  TabBarWithSplitView
//
//  Created by Jigish Belani on 3/23/12.
//  Copyright (c) 2012 Mota Motors, Inc. All rights reserved.
//

#import "CLLocation+Strings.h"


@implementation CLLocation (Strings)

- (NSMutableArray *)localizedCoordinateString {
    //NSString *latString = (self.coordinate.latitude < 0) ? NSLocalizedString(@"South", @"South") : NSLocalizedString(@"North", @"North");
    //NSString *lonString = (self.coordinate.longitude < 0) ? NSLocalizedString(@"West", @"West") : NSLocalizedString(@"East", @"East");
//    return [NSString stringWithFormat:NSLocalizedString(@"Lat:", @"Lat:"),fabs(self.coordinate.latitude), fabs(self.coordinate.longitude)];
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];
    NSString *latString = [NSString stringWithFormat:@"%g", self.coordinate.latitude];
    NSString *lonString = [NSString stringWithFormat:@"%g", self.coordinate.longitude];
    [coordinates addObject:latString];
    [coordinates addObject:lonString];
    return coordinates;
}

- (NSString *)localizedAltitudeString {
    if (self.verticalAccuracy < 0) {
        return NSLocalizedString(@"DataUnavailable", @"DataUnavailable");
    }
    NSString *seaLevelString = (self.altitude < 0) ? NSLocalizedString(@"BelowSeaLevel", @"BelowSeaLevel") : NSLocalizedString(@"AboveSeaLevel", @"AboveSeaLevel");
    return [NSString stringWithFormat:NSLocalizedString(@"AltitudeFormat", @"AltitudeFormat"), fabs(self.altitude), seaLevelString];
}

- (NSString *)localizedHorizontalAccuracyString {
    if (self.horizontalAccuracy < 0) {
        return NSLocalizedString(@"DataUnavailable", @"DataUnavailable");
    }
    return [NSString stringWithFormat:NSLocalizedString(@"AccuracyFormat", @"AccuracyFormat"), self.horizontalAccuracy];
}

- (NSString *)localizedVerticalAccuracyString {
    if (self.verticalAccuracy < 0) {
        return NSLocalizedString(@"DataUnavailable", @"DataUnavailable");
    }
    return [NSString stringWithFormat:NSLocalizedString(@"AccuracyFormat", @"AccuracyFormat"), self.verticalAccuracy];
}    

- (NSString *)localizedCourseString {
    if (self.course < 0) {
        return NSLocalizedString(@"DataUnavailable", @"DataUnavailable");
    }
    return [NSString stringWithFormat:NSLocalizedString(@"CourseFormat", @"CourseFormat"), self.course];
}

- (NSString *)localizedSpeedString {
    if (self.speed < 0) {
        return NSLocalizedString(@"DataUnavailable", @"DataUnavailable");
    }
    return [NSString stringWithFormat:NSLocalizedString(@"SpeedFormat", @"SpeedFormat"), self.speed];
}

@end