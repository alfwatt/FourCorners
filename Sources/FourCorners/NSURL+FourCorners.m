#if __has_include(<FourCorners/FCLocation.h>)
#import <FourCorners/FCLocation.h>
#else
#import "FCLocation.h"
#endif

#import "NSURL+FourCorners.h"

NSString* const FCGeoURLType = @"x-type:geo";

@implementation NSURL (FourCorners)

+ (nonnull NSURL *)dataURLWithGeoLat:(double)latitude lon:(double)longitude {
    return [NSURL URLWithString:[NSString stringWithFormat:@"data:%@,%f,%f", FCGeoURLType, latitude, longitude]];
}

+ (NSURL *)dataURLWithGeoLat:(double)latitude lon:(double)longitude alt:(double)altitude {
    return [NSURL URLWithString:[NSString stringWithFormat:@"data:%@,%f,%f,%f", FCGeoURLType, latitude, longitude, altitude]];
}

+ (nonnull NSURL *)dataURLWithGeoLat:(double)latitude lon:(double)longitude alt:(double)altitude time:(nonnull NSDate *)time {
    return [NSURL URLWithString:[NSString stringWithFormat:@"data:%@,%f,%f,%f,%f", FCGeoURLType, latitude, longitude, altitude, time.timeIntervalSince1970]];
}

+ (NSURL *)dataURLWithLocation:(nonnull FCLocation *)location {
    return [self dataURLWithGeoLat:location.coordinate.latitude lon:location.coordinate.longitude alt:location.altitude];
}

+ (nullable FCLocation *)locationFromDataURL:(nonnull NSURL *)locationURL {
    NSArray<NSString *> *components = [locationURL.absoluteString componentsSeparatedByString:@","];

    // check to make sure it's a valid geo URL
    if (components[0] != nil && ![components[0] isEqualToString:@"data:x-type:geo"]) {
        return nil;
    }

    if (components.count < 3) {
        return nil;
    }

    double latitude = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    double altitude = (components.count > 2 ? [components[2] doubleValue] : 0.0);
    double timeInterval = (components.count > 3 ? [components[3] doubleValue] : 0.0);
    NSDate* timestamp = (timeInterval != 0.0 ? [NSDate dateWithTimeIntervalSince1970:timeInterval] : [NSDate date]);

    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(latitude, longitude);
    return [FCLocation.alloc initWithCoordinate:coords
                                       altitude:altitude
                             horizontalAccuracy:0
                               verticalAccuracy:0
                                      timestamp:timestamp];
}


@end
