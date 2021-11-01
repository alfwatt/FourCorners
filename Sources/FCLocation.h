#import <KitBridge/KitBridge.h>
#import <CoreLocation/CoreLocation.h>

typedef const unichar FCCardinal;

// MARK: - Cardinal Directions

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

// MARK: - Compass Directions

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

// MARK: - Usefull Distances

/// One meter
extern const CLLocationDistance FCMeter;

/// One Thousand Meters (1 Km)
extern const CLLocationDistance FCKiloMeter;

// MARK: - WGS 84

/// The Radius of the Earth, in Meters per WGS 84: 6,378,137.0 Meters
extern const CLLocationDistance FCEarthRadius;

/// The Semi-Minor Axis of the Earh, in Meters per WGS 84: 6,356,752.314245 Meters
extern const CLLocationDistance FCEarthSemiMinorAxis;

/// The 1/F Flattening of the Earth per WGS 84: 298.257223563
extern const CLLocationDistance FCEarthFlattening;

// MARK: - Astronomical Distances

/// The Altitude of the Geostaionaly Clark Orbits: 35,786 Kilometers
/// @link https://en.wikipedia.org/wiki/Geostationary_orbit
extern const CLLocationDistance FCGeostationayAltitude;

/// The Mean distance between the Earth and the Sun: 149,597,870,700 Meters
/// @link https://en.wikipedia.org/wiki/Astronomical_unit
extern const CLLocationDistance FCAstronomicalUnit;

/// The distance a photon travels in vacuum per second: 299,792,458 Meters
/// @link https://en.wikipedia.org/wiki/Light-second
extern const CLLocationDistance FCLightSecond;

/// The distance a photon travels in vacuum per Julian year: 9,460,730,472,580,800 Meters
/// @link https://en.wikipedia.org/wiki/Light-year
extern const CLLocationDistance FCLightYear;

// MARK: - Location Types

extern NSString* const FCLocationSpecialType;
extern NSString* const FCLocationSharedType;
extern NSString* const FCLoactionNMEAType;
extern NSString* const FCLocationCLLocationType;

// MARK: - Notifications

extern NSString* const FCLocationUpdateNotification; // the location of this device updated
extern NSString* const FCLocationForgottenNotification; // the location was forgotten
extern NSString* const FCLocationTrackedNotification; // the location of a tracked object updated
extern NSString* const FCLocationGeocodedNotification; // the location was geocoded into placemarks

// MARK: - Keys

extern NSString* const FCLocationSourceKey; // the source of the location
extern NSString* const FCLocationTrackedObjectKey; // the object that the location tracks
extern NSString* const FCLocationTrackedReplacesKey; // the previous tracked location
extern NSString* const FCLocationGeocodedPlacemarksKey; // the location placemarks
extern NSString* const FCLocationGeocodingErrorKey; // geocoding error

// MARK: - Circular Error

/// Circular Error Probability
typedef double FCCircularError;

/// Circular Error Probable 50%
extern const FCCircularError FCCircularErrorCEP50; // = 0.5;

/// Circular Error Distance Root Mean Square
extern const FCCircularError FCCircularErrorDRMS; // = 0.63213;

/// Circular Error 2 x Distance Root Mean Square
extern const FCCircularError FCCircularError2DRMS; // = 0.98169;

/// Circular Error Probable 95%
extern const FCCircularError FCCiruclarErrorR95; // 0.95;

/// Circular Error Probable 99.7%
extern const FCCircularError FCCircularErrorR997; // 0.997

// MARK: - Functions

/// @return a random CLLocationDirection between 0 and 360 or FCDisoriented */
extern CLLocationDirection FCRandomDirection(void);

/// @return the CLLocationDirection from the origin to the destination or FCDisoriented */
extern CLLocationDirection FCBearingFrom(CLLocationCoordinate2D origin, CLLocationCoordinate2D destination);

/// @return a new CLLocationCoordinate2D at the specified distance and bearing from the start point */
extern CLLocationCoordinate2D FCCoordincateAtDistanceAndBearingFrom(CLLocationCoordinate2D start, CLLocationDistance distance, CLLocationDirection bearing);

/// converts an horizontal accuracy distance in meters from one cicurcle error
extern CLLocationDistance FCCircularErrorProbable(CLLocationDistance errorDistance, FCCircularError fromCircle, FCCircularError toCircle);

// MARK: -

@class FCLocationSource;

/*! @class legacy for un-archiving old FCLocation instances */
@interface FCCoordinate : NSObject <NSCopying, NSCoding>
@property(assign) CLLocationDegrees latitude;
@property(assign) CLLocationDegrees longitude;
@property(assign) CLLocationDistance altitude;
@property(assign) CLLocationDistance precision;

@end

// MARK: -

/*! @brief FCLocation extensions to CLLocation */
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

// MARK: - Direction Calcs

- (CLLocationDirection) directionTo:(CLLocation*) point;

// MARK: - Coordinate String Conversions

@property(nonatomic,readonly) NSString* coordinateLatLonString;
@property(nonatomic,readonly) NSString* coordinateAltitudeString;
@property(nonatomic,readonly) NSString* coordinatePrecisionString;
@property(nonatomic,readonly) NSString* coordinateString;
@property(nonatomic,readonly) NSString* coordinateNEMAString;
@property(nonatomic,readonly) NSString* coordinateGeoHash;

// MARK: - Location Notifications

- (void) notifyLocationUpdateFromSource:(FCLocationSource*) source;
- (void) notifyLocationTrackedReplacing:(CLLocation*) location withObject:(id) tracked;
- (void) notifyLocationForgottenBySource:(FCLocationSource*) source;

@end

// MARK: -

/** FCLocation extends CLLocation adding a name, URL, type and icon fields */
@interface FCLocation : CLLocation
@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSURL* url;
@property(nonatomic,retain) NSString* type;
@property(nonatomic,retain) ILImage* icon;

// MARK: - Geocoding

@property(nonatomic,retain) NSArray* placemarks;

// MARK: - Special Locations

+ (FCLocation*) nowhere;
+ (FCLocation*) anywhere;
+ (FCLocation*) restricted;

// MARK: - Initilizers

- (instancetype) initWithLocation:(CLLocation*) location;

- (instancetype) initWithNMEAString:(NSString*)str;

- (instancetype) initWithCoordinate:(CLLocationCoordinate2D) coordinate
                               name:(NSString*) name
                               type:(NSString*) type
                                url:(NSURL*) url
                               icon:(ILImage*) icon;

- (instancetype) initWithGeoHash:(NSString*) geoHash;


// MARK: - Geocoding

- (void) geocode;

// MARK: - NSObject Overrides

- (NSComparisonResult) compare:(FCLocation*) other;

@end

/* Copyright © 2010-2020, Alf Watt (alf@istumbler.net) All rights reserved. */
