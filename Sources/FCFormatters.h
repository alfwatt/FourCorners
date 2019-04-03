#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FCLocation;

@interface CLLocationDistanceFormatter : NSFormatter

+ (instancetype) distanceFormatter;

+ (NSString*) distanceString:(CLLocationDistance) distance;
+ (NSString*) unitsString:(CLLocationDistance) distance;

@end

#pragma mark -

@interface CLLocationSpeedFormatter : NSFormatter

+ (instancetype) speedFormatter;

+ (NSString*) distanceString:(CLLocationDistance) distance;
+ (NSString*) unitsString:(CLLocationDistance) distance;

@end

#pragma mark -

@interface CLLocationCoordinateFormatter : NSFormatter

+ (instancetype) coordinateFormatter;

+ (NSString*) coordinateString:(CLLocationCoordinate2D)coordinates;

@end

#pragma mark -

@interface CLLocationDirectionFormatter : NSFormatter 

+ (instancetype) directionFormatter;

+ (NSString*) bearingString:(CLLocationDirection) direction;

@end

#pragma mark -

@interface CLLocationDirectionArrowFormatter : NSFormatter

+ (instancetype) directionFormatter;

+ (NSString*) bearingString:(CLLocationDirection) direction;


@end

#pragma mark -

@interface CLLocationDirectionKanjiFormatter : NSFormatter

+ (instancetype) directionFormatter;

+ (NSString*) bearingString:(CLLocationDirection) direction;

@end

#pragma mark -

@interface FCLocationLogFormatter : NSFormatter

+ (instancetype) logFormatter;

+ (NSString*) logString:(FCLocation*) location;

@end

/* Copyright 2010-2019, Alf Watt (alf@istumbler.net) All rights reserved. */
