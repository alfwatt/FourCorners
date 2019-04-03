#import "FCLocationSource.h"

#import "FCCoreLocationSource.h"

@implementation FCLocationSource

#pragma mark Class Methods

+ (NSArray*) locationSources
{
    return @[[FCLocationSource CoreLocationSource]];
}

+ (FCLocationSource*) CoreLocationSource
{
	return [FCCoreLocationSource coreLocationSource];
}

+ (FCLocationSource*) NetServiceSource
{
    return nil;
}

#pragma mark Instance Methods

- (NSString*) sourceName
{
    return @"";
}

- (NSString*) sourceType
{
    return @"";
}

- (CLLocationDistance) horizontalAccuracy
{
    return -1;
}

- (CLLocationDistance) verticalAccuracy
{
    return -1;
}

- (BOOL) knowsCurrentLocation
{
    return NO;
}

- (FCLocation*) currentLocation
{
    return [FCLocation anywhere];
}

- (NSArray*) trackedLocations
{
    return nil;
}

- (BOOL) providesLocationUpdates
{
    return NO;
}

- (void) startUpdatingLocation
{
    @throw [NSException exceptionWithName:@"AbstractMethodNotImplemented" 
                                   reason:@"startLocationUpdates not implemented in subclass" 
                                 userInfo:nil];
}

- (void) stopUpdatingLocation
{
    @throw [NSException exceptionWithName:@"AbstractMethodNotImplemented" 
                                   reason:@"stopLocationUpdates not implemented in subclass" 
                                 userInfo:nil];
}

@end

/* Copyright 2010-2019, Alf Watt (alf@istumbler.net) All rights reserved. */
