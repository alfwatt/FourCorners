#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FCLocation;

@interface CLLocationDistanceFormatter : NSFormatter

+ (instancetype) distanceFormatter;

+ (NSString*) distanceString:(CLLocationDistance) distance;
+ (NSString*) unitsString:(CLLocationDistance) distance;

@end

// MARK: -

@interface CLLocationSpeedFormatter : NSFormatter

+ (instancetype) speedFormatter;

+ (NSString*) distanceString:(CLLocationDistance) distance;
+ (NSString*) unitsString:(CLLocationDistance) distance;

@end

// MARK: -

@interface CLLocationCoordinateFormatter : NSFormatter

+ (instancetype) coordinateFormatter;

+ (NSString*) coordinateString:(CLLocationCoordinate2D)coordinates;

@end

// MARK: -

@interface CLLocationDirectionFormatter : NSFormatter 

+ (instancetype) directionFormatter;

+ (NSString*) bearingString:(CLLocationDirection) direction;

@end

// MARK: -

@interface CLLocationDirectionArrowFormatter : NSFormatter

+ (instancetype) directionFormatter;

+ (NSString*) bearingString:(CLLocationDirection) direction;


@end

// MARK: -

@interface CLLocationDirectionKanjiFormatter : NSFormatter

+ (instancetype) directionFormatter;

+ (NSString*) bearingString:(CLLocationDirection) direction;

@end

// MARK: -

@interface FCLocationLogFormatter : NSFormatter

+ (instancetype) logFormatter;

+ (NSString*) logString:(FCLocation*) location;

@end
