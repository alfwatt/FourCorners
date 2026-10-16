#import <CoreLocation/CoreLocation.h>

#import "FCLocation.h"
#import "FCLocationSource.h"
#import "FCCoreLocationSource.h"

__strong static FCCoreLocationSource* sharedSource;

@implementation FCCoreLocationSource

+ (CLLocation*) FCLocationToCLLocation:(FCLocation*) fcLocation {
    return nil;
}

+ (FCCoreLocationSource*) coreLocationSource {
	@synchronized(self) {
        if (!sharedSource) {
            sharedSource = [FCCoreLocationSource new];
        }
    }

    return sharedSource;
}

// MARK: -

- (id) init {
    if ((self = [super init])) {
        self.manager = [CLLocationManager new];
        self.manager.delegate = self;
        self.current = nil;
        self.track = [NSMutableArray new];
    }
    return self;
}

// MARK: - Instance Methods

// these methods provide meta information for the location source
- (NSString*) sourceName {
    return @"Core Location";
}

- (NSString*) sourceType {
    return @"Wi-Fi";
}

- (CLLocationDistance) horizontalAccuracy; {
    return 10.0; // core-location is about this accurate in wifi mode
}

// determines if the source knows the current location
- (BOOL) knowsCurrentLocation {
    BOOL isAuthorized = (
      (self.manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways)
#if IL_UI_KIT
      || (self.manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
#elif IL_APP_KIT
      || (self.manager.authorizationStatus == kCLAuthorizationStatusAuthorized)
#endif
    );
    return isAuthorized && self.currentLocation && CLLocationCoordinate2DIsValid(self.currentLocation.coordinate)
        && (self.currentLocation.coordinate.latitude != 0 && self.currentLocation.coordinate.longitude != 0)
        && (self.currentLocation.coordinate.latitude != -180 && self.currentLocation.coordinate.longitude != -180);
}

- (FCLocation*) currentLocation {
    return self.current;
}

- (BOOL) tracksLocations {
    return YES;
}

- (NSArray*) trackedLocations {
    return [NSArray arrayWithArray:self.track];
}

- (BOOL) providesLocationUpdates {
    return YES;
}

- (void) startUpdatingLocation {
    if (self.manager.authorizationStatus == kCLAuthorizationStatusNotDetermined) { // prompt, updates start when it's granted
        [self.manager requestWhenInUseAuthorization];
    }
#if TARGET_OS_TV
    [self.manager requestLocation]; // tvOS gives one location at a time
#else
    [self.manager startUpdatingLocation];
#endif
}

- (void) stopUpdatingLocation {
#if !TARGET_OS_TV
    [self.manager stopUpdatingLocation];
#endif
}

// MARK: -

- (void) updateCurrentLocation:(FCLocation*) location {
    self.current = location;
    [self.track addObject:location];
    
    if (![location.type isEqual:FCLocationSpecialType]) {
        location.name = NSProcessInfo.processInfo.hostName;
        location.icon = [ILImage systemImageNamed:@"mappin"];
    }
    
    [location notifyLocationUpdateFromSource:self];
}

// MARK: - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)theManager didUpdateLocations:(NSArray<CLLocation*>*)locations {
    if (locations.lastObject) {
        [self updateCurrentLocation:[FCLocation.alloc initWithLocation:locations.lastObject]];
    }
}

- (void)locationManager:(CLLocationManager *)theManager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied && theManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        return; // reported while the authorization prompt is waiting for an answer
    }
    else if ([error code] == kCLErrorDenied) {
        [self updateCurrentLocation:FCLocation.restricted]; // we've moved to a restricted location
    }
    else if ([error code] == kCLErrorLocationUnknown) {
        [self updateCurrentLocation:FCLocation.anywhere]; // we could be anywhere!
    }
    else {
#if IL_APP_KIT
	    NSLog(@"locationManager:%@ didFailWithError:%@", theManager, error);
        [NSApp presentError:error];
#endif
    }
}

@end
