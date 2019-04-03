#import <KitBridge/KitBridge.h>
#import <CoreLocation/CoreLocation.h>

typedef const unichar FCCardinal;

#pragma mark - Cardinal Directions

extern FCCardinal FCNorth;
extern FCCardinal FCSouth;
extern FCCardinal FCEast;
extern FCCardinal FCWest;

extern FCCardinal FCNorthArrow;
extern FCCardinal FCSouthArrow;
extern FCCardinal FCEastArrow;
extern FCCardinal FCWestArrow;

extern FCCardinal FCNorthWestArrow;
extern FCCardinal FCNorthEastArrow;
extern FCCardinal FCSouthEastArrow;
extern FCCardinal FCSouthWestArrow;

extern FCCardinal FCNorthKanji;
extern FCCardinal FCSouthKanji;
extern FCCardinal FCEastKanji;
extern FCCardinal FCWestKanji;

#pragma mark - Compass Directions

extern const CLLocationDirection FCDisoriented;

extern const CLLocationDirection FCDueNorth;
extern const CLLocationDirection FCNorthEast;
extern const CLLocationDirection FCDueEast;
extern const CLLocationDirection FCSouthEast;
extern const CLLocationDirection FCDueSouth;
extern const CLLocationDirection FCSouthWest;
extern const CLLocationDirection FCDueWest;
extern const CLLocationDirection FCNorthWest;

extern const CLLocationDirection FCNorthByNorthEast;
extern const CLLocationDirection FCEastByNorthEast;
extern const CLLocationDirection FCEastBySouthEast;
extern const CLLocationDirection FCSouthBySouthEast;
extern const CLLocationDirection FCSouthBySouthWest;
extern const CLLocationDirection FCWestBySouthWest;
extern const CLLocationDirection FCWestByNorthWest;
extern const CLLocationDirection FCNorthByNorthWest;

#pragma mark - Usefull Distances

extern const CLLocationDistance FCMeter; // 1;
extern const CLLocationDistance FCKiloMeter; // 1000;
extern const CLLocationDistance FCEarthRadius; // = 6378135;
extern const CLLocationDistance FCEarthSemiMinorAxis; // WGS 84
extern const CLLocationDistance FCEarthFlattening; // WGS 84
extern const CLLocationDistance FCGeostationayAltitude; // = 35786000;
extern const CLLocationDistance FCAstronomicalUnit; // = 149597871000;

extern const CLLocationDistance FCLightSecond; // = 299792458
extern const CLLocationDistance FCLightYear; // = 9460730472580800;

#pragma mark - Location Types

extern NSString* const FCLocationSpecialType;
extern NSString* const FCLocationSharedType;
extern NSString* const FCLoactionNMEAType;
extern NSString* const FCLocationCLLocationType;

#pragma mark - Notifications

extern NSString* const FCLocationUpdateNotification; // the location of this device updated
extern NSString* const FCLocationForgottenNotification; // the location was forgotten
extern NSString* const FCLocationTrackedNotification; // the location of a tracked object updated
extern NSString* const FCLocationGeocodedNotification; // the location was geocoded into placemarks

#pragma mark - Keys

extern NSString* const FCLocationSourceKey; // the source of the location
extern NSString* const FCLocationTrackedObjectKey; // the object that the location tracks
extern NSString* const FCLocationTrackedReplacesKey; // the previous tracked location
extern NSString* const FCLocationGeocodedPlacemarksKey; // the location placemarks
extern NSString* const FCLocationGeocodingErrorKey; // geocoding error

#pragma mark - Functions

/*! @returns a random CLLocationDirection between 0 and 360 or FCDisoriented */
extern CLLocationDirection FCRandomDirection(void);

/*! @returns the CLLocationDirection from the origin to the destination or FCDisoriented */
extern CLLocationDirection FCBearingFrom(CLLocationCoordinate2D origin, CLLocationCoordinate2D destination);

/*! @returns a new CLLocationCoordinate2D at the specified distance and bearing from the start point */
extern CLLocationCoordinate2D FCCoordincateAtDistanceAndBearingFrom(CLLocationCoordinate2D start, CLLocationDistance distance, CLLocationDirection bearing);

@class FCLocationSource;

#pragma mark -

/*! @class legacy for un-archiving old FCLocation instances */
@interface FCCoordinate : NSObject <NSCopying, NSCoding>
@property(assign) CLLocationDegrees latitude;
@property(assign) CLLocationDegrees longitude;
@property(assign) CLLocationDistance altitude;
@property(assign) CLLocationDistance precision;

@end

#pragma mark -

/*! @brief FCLocation extentions to CLLocation */
@interface CLLocation (FCLocation)

// boxing properties for the underlying CLLocation
@property(nonatomic,readonly) NSNumber* altitueValue;
@property(nonatomic,readonly) NSNumber* horizontalAccuracyValue;
@property(nonatomic,readonly) NSNumber* verticalAccuracyValue;
@property(nonatomic,readonly) NSNumber* courseValue;
@property(nonatomic,readonly) NSNumber* speedValue;
@property(nonatomic,readonly) NSNumber* distanceValue; // distance from CLLocation's notition of 'here'
@property(nonatomic,readonly) NSNumber* directionValue; // breaing from CLLocations's notion of 'here'

@property(nonatomic,readonly) FCCardinal latitudeHemisphere;
@property(nonatomic,readonly) CLLocationDegrees latitudeDegrees;
@property(nonatomic,readonly) CLLocationDegrees latitudeMinutes;
@property(nonatomic,readonly) CLLocationDegrees latitudeSeconds;

@property(nonatomic,readonly) FCCardinal longitudeHemisphere;
@property(nonatomic,readonly) CLLocationDegrees longitudeDegrees;
@property(nonatomic,readonly) CLLocationDegrees longitudeMinutes;
@property(nonatomic,readonly) CLLocationDegrees longitudeSeconds;

#pragma mark - Direction Calcs

- (CLLocationDirection) directionTo:(CLLocation*) point;

#pragma mark - Coordinate String Conversions

@property(nonatomic,readonly) NSString* coordinateLatLonString;
@property(nonatomic,readonly) NSString* coordinateAltitudeString;
@property(nonatomic,readonly) NSString* coordinatePrecisionString;
@property(nonatomic,readonly) NSString* coordinateString;
@property(nonatomic,readonly) NSString* coordinateNEMAString;
@property(nonatomic,readonly) NSString* coordinateGeoHash;

#pragma mark - Location Notifications

- (void) notifyLocationUpdateFromSource:(FCLocationSource*) source;
- (void) notifyLocationTrackedReplacing:(CLLocation*) location withObject:(id) tracked;
- (void) notifyLocationForgottenBySource:(FCLocationSource*) source;

@end

#pragma mark -

/** FCLocation extends CLLocation adding a name, URL, type and icon fields */
@interface FCLocation : CLLocation
@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSURL* url;
@property(nonatomic,retain) NSString* type;
@property(nonatomic,retain) ILImage* icon;

#pragma mark - Geocoding

@property(nonatomic,retain) NSArray* placemarks;

#pragma mark - Special Locations

+ (FCLocation*) nowhere;
+ (FCLocation*) anywhere;
+ (FCLocation*) restricted;

#pragma mark - Initilizers

- (instancetype) initWithLocation:(CLLocation*) location;

- (instancetype) initWithNMEAString:(NSString*)str;

- (instancetype) initWithCoordinate:(CLLocationCoordinate2D) coordinate
                               name:(NSString*) name
                               type:(NSString*) type
                                url:(NSURL*) url
                               icon:(ILImage*) icon;

- (instancetype) initWithGeoHash:(NSString*) geoHash;


#pragma mark - Geocoding

- (void) geocode;

@end

/* Copyright 2010-2018, Alf Watt (alf@istumbler.net) All rights reserved. */
