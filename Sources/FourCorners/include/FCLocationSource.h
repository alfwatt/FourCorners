#import <Foundation/Foundation.h>

#if SWIFT_PACKAGE
#import "FCLocation.h"
#else
#import <FourCorners/FCLocation.h>
#endif


/* user info dictionary keys for the above notification */
extern NSString* const FCLocationSourceKey;

/*! @class
    
    @brief Provides an interface for objects which can provide
    an FCLocation for the current position or translate a string
    into an FCLocation.
 
    @discussion  FCLocationSource is an abstract base class for
    all the location sources in the FourCorners framework it provides
    a generic interface for determining the current location converting
    location description strings to GPS locations and providing position
    and course updates for some location sources.

    Location sources are either singletons tied to the current location of
    the computer and able to convert provided strings into FCLocation objects
    or are tied to a specific local device or network service
*/
@interface FCLocationSource : NSObject

@property(nonatomic,assign) BOOL shouldTrackLocation;

// MARK: - Class Methods

+ (NSArray*) locationSources;

/*
    @method     
    @abstract   Returns an FCLocationSource for a GPS Device
    @discussion Given a BSD device name attempts to open an
    NMEA serial device to read current GPS location data.
+ (FCLocationSource*) GPSLocationSource:(NSString*) deviceName;

    @method
    @abstract   Returns an FCLocationSource for a GPSD Server
    @discussion Given a gpsd url in the form gpsd:host:port
    attempts to open a connection to the GPSD service and read
    GPS location data from the remote host.
+ (FCLocationSource*) GPSDLocationSource:(NSString*) gpsd_url;

    @method
    @abstract   Returns GPS Coordinates for a hostname
    @discussion Requests GPS information from the DNS
    system for a particular hostname. Hostnames in the
    local domain are resolved via mDNS, FQDNs are 
    resolved via unicast DNS.
+ (FCLocationSource*) DNSLocationSource:(NSString*) hostname;
*/

/*
 @method
 @abstract Returns a location source which uses CoreLocation for it's location data
 @discussion Requests GPS Location from CoreLocation
 */
+ (FCLocationSource*) CoreLocationSource;

/**
 @method
 @abstract a location source which uses NSNetServices to browse for other 
*/
+ (FCLocationSource*) NetServiceSource;

// MARK: - Instance Methods

// these methods provide meta information for the location source
- (NSString*) sourceName;
- (NSString*) sourceType;
- (CLLocationDistance) horizontalAccuracy;
- (CLLocationDistance) verticalAccuracy;

// some sources know the current coordinates of the device
- (BOOL) knowsCurrentLocation;
- (FCLocation*) currentLocation;

// some sources track objects
- (NSArray*) trackedLocations;

// determines if the source provides updates of the current location or tracked objects
- (BOOL) providesLocationUpdates;
- (void) startUpdatingLocation;
- (void) stopUpdatingLocation;

@end
