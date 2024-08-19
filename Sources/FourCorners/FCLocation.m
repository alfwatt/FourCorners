#import "FCLocation.h"
#import "FCCoreLocationSource.h"

#include <string.h>
#include <math.h>
#include "geohash.h"

FCCardinal FCNorth = 'N';
FCCardinal FCSouth = 'S';
FCCardinal FCEast  = 'E';
FCCardinal FCWest  = 'W';

FCCardinal FCWestArrow  = 0x2190; // LEFTWARDS ARROW Unicode: U+2190, UTF-8: E2 86 90
FCCardinal FCNorthArrow = 0x2191; // UPWARDS ARROW Unicode: U+2191, UTF-8: E2 86 91
FCCardinal FCEastArrow  = 0x2192; // RIGHTWARDS ARROW Unicode: U+2192, UTF-8: E2 86 92
FCCardinal FCSouthArrow = 0x2193; // DOWNWARDS ARROW Unicode: U+2193, UTF-8: E2 86 93

FCCardinal FCNorthWestArrow = 0x2196; // NORTH WEST ARROW Unicode: U+2196 U+FE0E, UTF-8: E2 86 96 EF B8 8E
FCCardinal FCNorthEastArrow = 0x2197; // NORTH EAST ARROW Unicode: U+2197 U+FE0E, UTF-8: E2 86 97 EF B8 8E
FCCardinal FCSouthEastArrow = 0x2198; // SOUTH EAST ARROW Unicode: U+2198 U+FE0E, UTF-8: E2 86 98 EF B8 8E
FCCardinal FCSouthWestArrow = 0x2199; // SOUTH WEST ARROW Unicode: U+2199 U+FE0E, UTF-8: E2 86 99 EF B8 8E

FCCardinal FCNorthKanji = 0x5317; // Unicode: U+5317, UTF-8: E5 8C 97
FCCardinal FCSouthKanji = 0x5357; // Unicode: U+5357, UTF-8: E5 8D 97
FCCardinal FCEastKanji  = 0x6771; // Unicode: U+6771, UTF-8: E6 9D B1
FCCardinal FCWestKanji  = 0x897F; // Unicode: U+897F, UTF-8: E8 A5 BF

// compass and quarter directions
const CLLocationDirection FCDisoriented = -1;

const CLLocationDirection FCDueNorth  = 0;
const CLLocationDirection FCNorthEast = 45;
const CLLocationDirection FCDueEast   = 90;
const CLLocationDirection FCSouthEast = 135;
const CLLocationDirection FCDueSouth  = 180;
const CLLocationDirection FCSouthWest = 225;
const CLLocationDirection FCDueWest   = 270;
const CLLocationDirection FCNorthWest = 315;

// eight directions for bearing string
const CLLocationDirection FCNorthByNorthEast = 22.5;
const CLLocationDirection FCEastByNorthEast  = 67.5;
const CLLocationDirection FCEastBySouthEast  = 112.5;
const CLLocationDirection FCSouthBySouthEast = 157.5;
const CLLocationDirection FCSouthBySouthWest = 202.5;
const CLLocationDirection FCWestBySouthWest  = 247.5;
const CLLocationDirection FCWestByNorthWest  = 292.5;
const CLLocationDirection FCNorthByNorthWest = 337.5;

const CLLocationDirection FCCompassDegrees = 360;

const CLLocationDistance FCMeter = 1;
const CLLocationDistance FCKiloMeter = 1000;

// MARK: - WGS 84

const CLLocationDistance FCEarthRadius = 6378137.0;
const CLLocationDistance FCEarthSemiMinorAxis = 6356752.314245;
const CLLocationDistance FCEarthFlattening = 298.257223563;

// MARK: - Astronomic Distances

const CLLocationDistance FCEarthGeostationaryAltitude = 35786000;
const CLLocationDistance FCAstronomicalUnit = 149597870700;
const CLLocationDistance FCLightSecond = 299792458;
const CLLocationDistance FCLightYear = 9460730472580800;

// special locations
static FCLocation* FCNowhereLocation;
static FCLocation* FCAnywhereLocation;
static FCLocation* FCRestrictedLocation;

NSString* const FCLocationCLLocationType = @"Core Location";
NSString* const FCLocationNMEAType = @"NMEA";
NSString* const FCLocationSpecialType = @"Special";
NSString* const FCLocationSharedType = @"Shared";

NSString* const FCLocationTrackedNotification = @"LocationTracked";
NSString* const FCLocationUpdateNotification = @"LocationUpdate";
NSString* const FCLocationForgottenNotification  = @"LocationForgotten";
NSString* const FCLocationGeocodedNotification = @"FCLocationGeocodedNotification"; // the location was geocoded into place-marks

NSString* const FCLocationSourceKey = @"FCLocationSourceKey";
NSString* const FCLocationTrackedObjectKey = @"FCLocationTrackedObjectKey"; // the object that the location tracks
NSString* const FCLocationTrackedReplacesKey = @"FCLocationTrackedReplacesKey"; // the previous tracked location
NSString* const FCLocationGeocodedPlacemarksKey = @"FCLocationGeocodedPlacemarksKey"; // the previous tracked location
NSString* const FCLocationGeocodingErrorKey = @"FCLocationGeocodingErrorKey"; // the previous tracked location

// MARK: -

/** static const double FCWSG84Flattening = (1.0 / 298.257223563); // (WGS '84) */

/** DM to decimal degrees: dd.dddd = dd + mm.mmmm / 60
static inline double DMtoDeg( double deg, double min) {
    return deg + (min / 60);
} */

/** DMS to decimal degrees: dd.dddd= deg + (min / 60) + (sec / 60 / 60)
static inline double DMStoDeg( double deg, double min, double sec) {
    return deg + (min / 60) + (sec / 60 / 60);
} */

/** nautical miles to meters: M = NM * 1852
static inline double NMtoMeters( double knots) {
    return knots * 1852;
} */

/** meters to nautical miles: NM = M / 1852
static inline double metersToNM( double meters) {
    return meters / 1852;
} */

/** nautical miles to miles: MI = NM * 1.150779
static inline double NMtoMiles( double knots) {
    return knots * 1.150779;
} */

/** miles to nautical miles: NM = MI / 1.150779
static inline double milesToNM( double miles) {
    return miles / 1.150779;
} */

/** knots to KM/hr: KM/hr = Knots * 1.852
static inline double knotsToKMPH( double knots) {
    return knots * 1.852;
} */

/** KM/hr to knots: Knots = KM/hr
static inline double KMPHtoKnots( double kmph) {
    return kmph / 1.852;
} */

/**  knots to MI/hr: mph = Knots * 1.150779
static inline double knotsToMPH( double knots) {
    return knots * 1.150779;
} */

/**  MI/hr to knots: Knots = mph / 1.150779
static inline double MPHtoKnots( double mph) {
    return mph / 1.150779;
} */

// MARK: -

typedef double FCRadians;

static inline FCRadians deg2rad(CLLocationDirection deg) { return (deg * (M_PI / 180.0)); }

static inline CLLocationDirection rad2deg(FCRadians rad) { return (rad * (180.0 / M_PI)); }

// MARK: - Functions

CLLocationDirection FCRandomDirection(void) {
    CLLocationDirection randomDirection = FCDisoriented;
    UInt16 randomBits = 0; // two bytes of entropy is sufficient (thousands of directions)
    if (SecRandomCopyBytes(kSecRandomDefault, sizeof(UInt16), &randomBits) == errSecSuccess) {
        double randomPercent = (((double)randomBits / UINT16_MAX));
        randomDirection = (FCCompassDegrees * randomPercent);
    }
    return randomDirection;
}

CLLocationDirection FCBearingFrom(CLLocationCoordinate2D origin, CLLocationCoordinate2D destination) {
    double deltaLon = (destination.longitude - origin.longitude);
    double y = sin(deltaLon) * cos(destination.latitude);
    double x = cos(origin.latitude) * sin(destination.latitude) - sin(origin.latitude) * cos(destination.latitude) * cos(deltaLon);
    double bearingInRadians = atan2(y, x);
    return rad2deg(bearingInRadians);
}

CLLocationCoordinate2D FCCoordinateAtDistanceAndBearingFrom(CLLocationCoordinate2D start, CLLocationDistance distance, CLLocationDirection bearing) {
    CLLocationCoordinate2D target = {0, 0};
    
    double lat1 = deg2rad(start.latitude);
    double lon1 = deg2rad(start.longitude);
    double brng = deg2rad(bearing);

    double dist = (distance / FCEarthRadius);
    
    double lat2 = asin(sin(lat1) * cos(dist) + cos(lat1) * sin(dist) * cos(brng));
    double lon2 = lon1 + atan2(sin(brng) * sin(dist) * cos(lat1),
                               cos(dist) - sin(lat1) * sin(lat2));
    lon2 = (fmod((lon2 + 3 * M_PI), (2 * M_PI)) - M_PI);
    
    target.latitude = rad2deg(lat2);
    target.longitude = rad2deg(lon2);
    
    return target;
}

/// Circular Error Probable 50%
const FCCircularError FCCircularErrorCEP50 = 0.5;

/// Circular Error Distance Root Mean Square
const FCCircularError FCCircularErrorDRMS = 0.63213;

/// Circular Error 2 x Distance Root Mean Square
const FCCircularError FCCircularError2DRMS = 0.98169;

/// Circular Error Probable 95%
const FCCircularError FCCircularErrorR95 = 0.95;

/// Circular Error Probable 99.7%
const FCCircularError FCCircularErrorR997 = 0.997;

// https://en.wikipedia.org/wiki/Circular_error_probable#Conversion

/*
static double const RMS_TO_CEP = 1.1774;
static double const RMS_TO_DRMS = 1.4142;
static double const RMS_TO_R95 = 2.4477;
static double const RMS_TO_2DRMS = 2.8284;
static double const RMS_TO_R997 = 3.4086;
*/

// static double const CEP_TO_RMS = 0.8493;
static double const CEP_TO_DRMS = 1.2011;
static double const CEP_TO_R95 = 2.0789;
static double const CEP_TO_2DRMS = 2.4022;
static double const CEP_TO_R997 = 2.8950;

// static double const DRMS_TO_RMS = 0.7071;
static double const DRMS_TO_CEP = 0.8326;
static double const DRMS_TO_R95 = 1.7308;
static double const DRMS_TO_2DRMS = 2.0;
static double const DRMS_TO_R997 = 2.4103;

// static double const R95_TO_RMS = 0.4085;
static double const R95_TO_CEP = 0.4810;
static double const R95_TO_DRMS = 0.5778;
static double const R95_TO_2DRMS = 1.1555;
static double const R95_TO_R997 = 1.3926;

// static double const TWODRMS_TO_RMS = 0.3536;
static double const TWODRMS_TO_CEP = 0.4163;
static double const TWODRMS_TO_DRMS = 0.5;
static double const TWODRMS_TO_R95 = 0.8654;
static double const TWODRMS_TO_R997 = 1.2051;

// static double const R997_TO_RMS = 0.2934;
static double const R997_TO_CEP = 0.3454;
static double const R997_TO_DRMS = 0.4149;
static double const R997_TO_R95 = 0.7181;
static double const R997_TO_2DRMS = 0.8298;

extern CLLocationDistance FCCircularErrorProbable(
    CLLocationDistance errorDistance,
    FCCircularError fromCircle,
    FCCircularError toCircle) {
    CLLocationDistance distance = 0.0;
    double factor = 1.0;
    
    if (fromCircle == FCCircularErrorCEP50) {
        if      (toCircle == FCCircularErrorDRMS)   factor = CEP_TO_DRMS;
        else if (toCircle == FCCircularError2DRMS)  factor = CEP_TO_2DRMS;
        else if (toCircle == FCCircularErrorR95)    factor = CEP_TO_R95;
        else if (toCircle == FCCircularErrorR997)   factor = CEP_TO_R997;
    }
    else if (fromCircle == FCCircularErrorDRMS) {
        if      (toCircle == FCCircularErrorCEP50)  factor = DRMS_TO_CEP;
        else if (toCircle == FCCircularError2DRMS)  factor = DRMS_TO_2DRMS;
        else if (toCircle == FCCircularErrorR95)    factor = DRMS_TO_R95;
        else if (toCircle == FCCircularErrorR997)   factor = DRMS_TO_R997;
    }
    else if (fromCircle == FCCircularError2DRMS) {
        if      (toCircle == FCCircularErrorCEP50)  factor = TWODRMS_TO_CEP;
        else if (toCircle == FCCircularErrorDRMS)   factor = TWODRMS_TO_DRMS;
        else if (toCircle == FCCircularErrorR95)    factor = TWODRMS_TO_R95;
        else if (toCircle == FCCircularErrorR997)   factor = TWODRMS_TO_R997;
    }
    else if (fromCircle == FCCircularErrorR95) {
        if      (toCircle == FCCircularErrorCEP50)  factor = R95_TO_CEP;
        else if (toCircle == FCCircularErrorDRMS)   factor = R95_TO_DRMS;
        else if (toCircle == FCCircularError2DRMS)  factor = R95_TO_2DRMS;
        else if (toCircle == FCCircularErrorR997)   factor = R95_TO_R997;
    }
    else if (fromCircle == FCCircularErrorR997) {
        if      (toCircle == FCCircularErrorCEP50)  factor = R997_TO_CEP;
        else if (toCircle == FCCircularErrorDRMS)   factor = R997_TO_DRMS;
        else if (toCircle == FCCircularError2DRMS)  factor = R997_TO_2DRMS;
        else if (toCircle == FCCircularErrorR95)    factor = R997_TO_R95;
    }

    // TODO figure out how to directly compute instead of using the factor table
    distance = (distance * factor);
    
    return distance;
}


// MARK: -

@implementation FCCoordinate

// MARK: - NSCopying

- (id)copyWithZone:(NSZone*)zone {
    FCCoordinate* copy = nil;
    if ((copy = FCCoordinate.new)) {
        copy.latitude = self.latitude;
        copy.longitude = self.longitude;
        copy.altitude = self.altitude;
        copy.precision = self.precision;
    }
    return copy;
}

// MARK: - NSCoding

- (void) encodeWithCoder:(NSCoder*) coder {
    [coder encodeDouble:self.latitude forKey:@"lat"];
    [coder encodeDouble:self.longitude forKey:@"lon"];
    [coder encodeDouble:self.altitude forKey:@"alt"];
    [coder encodeDouble:self.precision forKey:@"pre"];
}

- (id) initWithCoder:(NSCoder*) decoder {
    if ((self = super.init)) {
        self.latitude = [decoder decodeDoubleForKey:@"lat"];
        self.longitude = [decoder decodeDoubleForKey:@"lon"];
        self.altitude = [decoder decodeDoubleForKey:@"alt"];
        self.precision = [decoder decodeDoubleForKey:@"pre"];
    }
    return self;
}

@end

// MARK: -

@implementation CLLocation (FCLocation)

// boxing properties for the underlying CLLocation
- (NSNumber*) altitudeValue { return @(self.altitude); }
- (NSNumber*) horizontalAccuracyValue { return @(self.horizontalAccuracy); }
- (NSNumber*) verticalAccuracyValue { return @(self.verticalAccuracy); }
- (NSNumber*) courseValue { return @(self.course); }
- (NSNumber*) speedValue { return @(self.speed); }

- (NSNumber*) distanceValue {
    NSNumber* distance = nil;
    
    if (FCCoreLocationSource.coreLocationSource.knowsCurrentLocation) {
        distance =  @([self distanceFromLocation:FCCoreLocationSource.coreLocationSource.currentLocation]);
    }

    return distance;
}

- (NSNumber*) directionValue {
    NSNumber* direction = nil;
    
    if (FCCoreLocationSource.coreLocationSource.knowsCurrentLocation) {
        direction =  @([FCCoreLocationSource.coreLocationSource.currentLocation directionTo:self]);
    }

    return direction;
}

// MARK: - Coordinate Components

- (FCCardinal)latitudeHemisphere {
    return (self.coordinate.latitude < 0 ? FCSouth : FCNorth);
}

- (CLLocationDegrees)latitudeDegrees {
    return floor(fabs(self.coordinate.latitude));
}

- (CLLocationDegrees)latitudeMinutes {
    return remainder((fabs(self.coordinate.latitude) * 60), 60);
}

- (CLLocationDegrees)latitudeSeconds {
    return remainder((fabs(self.coordinate.latitude) * 60 * 60), 60);
}

- (FCCardinal)longitudeHemisphere {
    return (self.coordinate.longitude < 0 ? FCWest: FCEast);
}

- (CLLocationDegrees)longitudeDegrees {
    return floor(fabs(self.coordinate.longitude));
}

- (CLLocationDegrees)longitudeMinutes {
    return remainder((fabs(self.coordinate.longitude) * 60), 60);
}

- (CLLocationDegrees)longitudeSeconds {
    return remainder((fabs(self.coordinate.longitude) * 60 * 60), 60);
}

// MARK: - Distance and Bearing

/** compute the great circle bearing to another point */
- (CLLocationDirection) directionTo:(CLLocation*) point {
    if ((self == [FCLocation nowhere]    || point == [FCLocation nowhere])
     || (self == [FCLocation anywhere]   || point == [FCLocation anywhere])
     || (self == [FCLocation restricted] || point == [FCLocation restricted])
     || [self isEqual:point]) {
        return FCDisoriented;
    }
    
    FCRadians lat1 = deg2rad( self.coordinate.latitude);
    FCRadians lon1 = deg2rad( self.coordinate.longitude);
    FCRadians lat2 = deg2rad( point.coordinate.latitude);
    FCRadians lon2 = deg2rad( point.coordinate.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    FCRadians radiansBearing = atan2(y, x);

    if (radiansBearing < 0.0) {
        radiansBearing += 2*M_PI;
    }
    
    return rad2deg(radiansBearing);
}

// MARK: - Coordinate Strings

- (NSString*) coordinateLatLonString {
    return [NSString stringWithFormat:@"%c%.0lf° %.4lf' %c%.0lf° %.4lf'",
        [self latitudeHemisphere],
        [self latitudeDegrees],
        [self latitudeMinutes],
        [self longitudeHemisphere],
        [self longitudeDegrees],
        [self longitudeMinutes]];
}

- (NSString*) coordinateAltitudeString {
    NSString *altStr = nil;
    if (self.altitude != 0.0) {
        altStr = [NSString stringWithFormat:@"MSL%+.1fm", self.altitude];
    }
    return altStr;
}

- (NSString*) coordinatePrecisionString {
    NSString* dopStr = nil;
    if (self.horizontalAccuracy != 0.0) {
        dopStr = [NSString stringWithFormat:@"~%.1fm", self.horizontalAccuracy];
    }
    return dopStr;
}

- (NSString*)coordinateString {
    NSString* latLon = [self coordinateLatLonString];
    NSString* altStr = [self coordinateAltitudeString];
    NSString* dopStr = [self coordinatePrecisionString];
    NSString* coords = nil;
    
    if (altStr && dopStr) {
        coords = [NSString stringWithFormat:@"%@ %@ %@", latLon, altStr, dopStr];
    }
    else if (altStr) {
        coords = [NSString stringWithFormat:@"%@ %@", latLon, altStr];
    }
    else if (dopStr) {
        coords = [NSString stringWithFormat:@"%@ %@", latLon, dopStr];
    }
    return coords;
}

- (NSString*) coordinateNEMAString {
    return [NSString stringWithFormat:@"%c%.0lf' %.4lf\" %c%.0lf %.4lf\" MSL%+.2lf",
        [self latitudeHemisphere],
        [self latitudeDegrees],
        [self latitudeMinutes],
        [self longitudeHemisphere],
        [self longitudeDegrees],
        [self longitudeMinutes],
        self.altitude];
}

/*
 1       ≤ 5,000km      ×      5,000km ~= 25000k km^2  (continents)
 2       ≤ 1,250km      ×      625km   ~= 781k   km^2
 3       ≤ 156km        ×      156km   ~= 24k    km^2
 4       ≤ 39.1km       ×      19.5km  ~= 764    km^2  (states or small countries)
 5       ≤ 4.89km       ×      4.89km  ~= 23.9   km^2  (large neighboring cities)
 6       ≤ 1.22km       ×      0.61km  ~= 0.74   km^2  (neighborhoods)
 7       ≤ 153m         ×      153m    ~= 0.02   km^2
 8       ≤ 38.2m        ×      19.1m   ~= 748.72 m^2   (large fields/buildings)
 9       ≤ 4.77m        ×      4.77m   ~= 22.75  m^2   (parcel of land)
 10      ≤ 1.19m        ×      0.596m  ~= 0.7    m^2   (distinguish trees)
 11      ≤ 149mm        ×      149mm   ~= 0.0221 m^2   (surveying)
 12      ≤ 37.2mm       ×      18.6mm  ~= 0.0007 m^2   (movement of tectonic plates)
*/
- (NSString*) coordinateGeoHash {
    char geoHashStr[64] = {0}; // eight characters provides 19 m^2 error https://en.wikipedia.org/wiki/Geohash
    int geohash_result = geohash_encode(self.coordinate.latitude, self.coordinate.longitude, geoHashStr, sizeof(geoHashStr));
    return (geohash_result == GEOHASH_OK ? [NSString stringWithCString:geoHashStr encoding:NSUTF8StringEncoding] : @"");
}

// MARK: - Location Notifications

- (void) notifyLocationUpdateFromSource:(FCLocationSource*) source {
    NSMutableDictionary* info = [NSMutableDictionary new];
    if (source) {
        [info setObject:source forKey:FCLocationSourceKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FCLocationUpdateNotification object:self userInfo:info];
}

- (void) notifyLocationTrackedReplacing:(CLLocation*) replaced withObject:(id) tracked {
    NSMutableDictionary* info = [NSMutableDictionary new];
    if (replaced) {
        [info setObject:replaced forKey:FCLocationTrackedReplacesKey];
    }
    
    if (tracked) {
        [info setObject:tracked forKey:FCLocationTrackedObjectKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FCLocationTrackedNotification object:self userInfo:info];
}

- (void) notifyLocationForgottenBySource:(FCLocationSource*) source {
    NSMutableDictionary* info = [NSMutableDictionary new];
    if( source) [info setObject:source forKey:FCLocationSourceKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:FCLocationForgottenNotification object:self userInfo:info];
}

@end

// MARK: -

@implementation FCLocation

/** */
+ (FCLocation*)coordinateWithString:(NSString*)str {
    return nil;
}

/** @return location with the coordinate specified at zero altitude with default dop and */
+ (FCLocation*) locationWithCoordinate:(CLLocationCoordinate2D) coordinate {
    return nil;
}

/** */
+ (FCLocation*) locationWithLocation:(CLLocation*) location; {
    return nil;
}

static FCLocation* FCLocationNowhere;

+ (FCLocation*)nowhere {
    if (!FCLocationNowhere) {
        FCLocationNowhere = [[FCLocation alloc] initWithCoordinate:kCLLocationCoordinate2DInvalid
                                                              name:@"Nowhere"
                                                              type:FCLocationSpecialType
                                                               url:nil
                                                              icon:nil];
    }
    return FCLocationNowhere;
}

static FCLocation* FCLocationAnywhere;

+ (FCLocation*)anywhere {
    if (!FCLocationAnywhere) {
        FCLocationAnywhere = [[FCLocation alloc] initWithCoordinate:kCLLocationCoordinate2DInvalid
                                                               name:@"Anywhere"
                                                               type:FCLocationSpecialType
                                                                url:nil
                                                               icon:nil];
    }
    return FCLocationAnywhere;
}

static FCLocation* FCLocationRestricted;

+ (FCLocation*)restricted {
    if (!FCLocationRestricted) {
        FCLocationRestricted = [[FCLocation alloc] initWithCoordinate:kCLLocationCoordinate2DInvalid
                                                                 name:@"Restricted"
                                                                 type:FCLocationSpecialType
                                                                  url:nil
                                                                 icon:nil];
    }
    return FCLocationRestricted;
}

// MARK: - Initializers

/// copy initializer for CLLocations
- (instancetype) initWithLocation:(CLLocation *)other {
    if (self = [super initWithCoordinate:other.coordinate
                                altitude:other.altitude
                      horizontalAccuracy:other.horizontalAccuracy
                        verticalAccuracy:other.verticalAccuracy
                               timestamp:other.timestamp]) {
        self.type = FCLocationCLLocationType;
    }
    return self;
}

- (instancetype) initWithCoordinate:(CLLocationCoordinate2D) coordinate
                               name:(NSString*) name
                               type:(NSString*) type
                                url:(NSURL*) url
                               icon:(ILImage*) icon {
    if (self = [super initWithCoordinate:coordinate altitude:0.0 horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:[NSDate date]]) {
        self.name = name;
        self.type = type;
        self.url = url;
        self.icon = icon;
    }
    return self;
}

/// long form initializer for the initWithNMEAString function
- (instancetype)initWithLongitudeHemisphere:(FCCardinal)longitudeHemisphere
                           longitudeDegrees:(CLLocationDegrees)longitudeDegrees
                           longitudeMinutes:(CLLocationDegrees)longitudeMinutes
                         latitudeHemisphere:(FCCardinal)latitudeHemisphere
                            latitudeDegrees:(CLLocationDegrees)latitudeDegrees
                            latitudeMinutes:(CLLocationDegrees)latitudeMinutes
                                   altitude:(CLLocationDistance)alt {
    CLLocationDegrees latitude = ((latitudeDegrees + (latitudeMinutes / 60.0)) * (latitudeHemisphere == FCWest ? -1.0 : 1.0));
    CLLocationDegrees longitude = ((longitudeDegrees + (longitudeMinutes / 60.0)) * (longitudeHemisphere == FCSouth ? -1.0 : 1.0));
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    
    return [super initWithCoordinate:coordinate
                            altitude:alt
                  horizontalAccuracy:0.0
                    verticalAccuracy:0.0
                           timestamp:[NSDate date]];
}

- (instancetype) initWithGeoHash:(NSString *)geoHash {
    FCLocation* location = nil;
    char* geoHashStr = (char*)[geoHash cStringUsingEncoding:NSUTF8StringEncoding];
    double hashLatitude = 0.0;
    double hashLongititue = 0.0;

    if (geohash_decode(geoHashStr, &hashLatitude, &hashLongititue)) {
        location = [[FCLocation alloc] initWithLatitude:hashLatitude longitude:hashLongititue];
    }

    return location;
}

/* Parses an NEMA format GPS string with MSL */
- (FCLocation*)initWithNMEAString:(NSString*)str {
    char longitudeHemisphere;
    CLLocationDegrees longitudeDegrees;
    CLLocationDegrees longitudeMinutes;
    char latitudeHemisphere;
    CLLocationDegrees latitudeDegrees;
    CLLocationDegrees latitudeMinutes;
    CLLocationDistance altitudeMeters;
    
    // TODO handle case without the MSL numbers
    sscanf([str cStringUsingEncoding:NSUTF8StringEncoding], "%c%lf' %lf\" %c%lf %lf\" MSL%lf",
           &longitudeHemisphere,
           &longitudeDegrees,
           &longitudeMinutes,
           &latitudeHemisphere,
           &latitudeDegrees,
           &latitudeMinutes,
           &altitudeMeters);
    
    if (self = [self initWithLongitudeHemisphere:longitudeHemisphere
                                longitudeDegrees:longitudeDegrees
                                longitudeMinutes:longitudeMinutes
                              latitudeHemisphere:latitudeHemisphere
                                 latitudeDegrees:latitudeDegrees
                                 latitudeMinutes:latitudeMinutes
                                        altitude:altitudeMeters]) {
        self.name = str;
        self.type = FCLocationNMEAType;
    }
    
    return self;
}

// MARK: - CLLocation Overrides

- (CLLocationDistance)distanceFromLocation:(const CLLocation *)location {
    if (self == [FCLocation nowhere]    || location == [FCLocation nowhere])    { return UINT64_MAX; } // nowhere is infinitely far away
    if (self == [FCLocation anywhere]   || location == [FCLocation anywhere])   { return 0; } // anywhere is right here
    if (self == [FCLocation restricted] || location == [FCLocation restricted]) { return NAN; } // not even a number
    
    return [super distanceFromLocation:location];
}

// MARK: - NSObject

/* Ordering is lat, lon then alt, dop disregarded */
- (NSComparisonResult) compare:(FCLocation*) other {
    NSComparisonResult result = NSOrderedDescending;
    if (self.coordinate.latitude == other.coordinate.latitude
     && self.coordinate.longitude == other.coordinate.longitude
     && self.altitude == other.altitude) {
        result = NSOrderedSame;
    }
    else if (self.coordinate.latitude == other.coordinate.latitude
          && self.coordinate.longitude == other.coordinate.longitude
          && self.altitude > self.altitude) {
        result = NSOrderedAscending;
    }
    else if (self.coordinate.latitude == other.coordinate.latitude
          && self.coordinate.longitude > other.coordinate.longitude) {
        result = NSOrderedAscending;
    }
    else if (self.coordinate.latitude > other.coordinate.latitude) {
        result = NSOrderedAscending;
    }

    return result;
}

- (BOOL) isEqual:(id)object {
    BOOL equal = NO;
    if ([object class] == NSClassFromString(@"CLLocation")) { // only the CLLocation objects
        CLLocation* other = (CLLocation*)object;
        if (self.coordinate.latitude == other.coordinate.latitude
         && self.coordinate.longitude == other.coordinate.longitude
         && self.altitude == other.altitude) {
            equal = YES;
        }
    }
    else if ([object isKindOfClass:self.class]) { // FCLocation or a subclass
        FCLocation* other = (FCLocation*) object;

        if (self.coordinate.latitude == other.coordinate.latitude
         && self.coordinate.longitude == other.coordinate.longitude
         && self.altitude == other.altitude
         && self.name == other.name
         && self.url == other.url
         && self.type == other.type
         && self.icon == other.icon) {
            equal = YES;
        }
    }

    return equal;
}

// MARK: - NSCopying

- (id)copyWithZone:(NSZone*)zone {
    FCLocation* other = [[FCLocation alloc] initWithCoordinate:self.coordinate
                                                      altitude:self.altitude
                                            horizontalAccuracy:self.horizontalAccuracy
                                              verticalAccuracy:self.verticalAccuracy
                                                     timestamp:self.timestamp];
    other.name = self.name;
    other.type = self.type;
    other.url = self.url;
    other.icon = self.icon;
    return other;
}

// MARK: - NSCoding

- (void) encodeWithCoder:(NSCoder*) coder {
    [coder encodeInt:100 forKey:@"ver"]; // encoded under version 100
    
    // CLLocation Properties
    [coder encodeDouble:self.coordinate.latitude forKey:@"lat"];
    [coder encodeDouble:self.coordinate.longitude forKey:@"lon"];
    [coder encodeDouble:self.altitude forKey:@"alt"];
    [coder encodeDouble:self.horizontalAccuracy forKey:@"hdop"];
    [coder encodeDouble:self.verticalAccuracy forKey:@"vdop"];
    [coder encodeObject:self.timestamp forKey:@"time"];
    
    // FCLocation Extensions
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.type forKey:@"type"];
#if IL_APP_KIT
    [coder encodeObject:[self.icon name] forKey:@"icon"];
#endif
}

- (id) initWithCoder:(NSCoder*) decoder {
    CLLocationDegrees latitude = 0.0;
    CLLocationDegrees longitude = 0.0;
    CLLocationDistance altitude = 0.0;
    CLLocationDistance hdop = 0.0;
    CLLocationDistance vdop = 0.0;
    NSDate* time = nil;
    
    if ([decoder decodeIntForKey:@"ver"] == 100) {
        latitude = [decoder decodeDoubleForKey:@"lat"];
        longitude = [decoder decodeDoubleForKey:@"lon"];
        altitude = [decoder decodeDoubleForKey:@"alt"];
        hdop = [decoder decodeDoubleForKey:@"hdop"];
        vdop = [decoder decodeDoubleForKey:@"vdop"];
        time = [decoder decodeObjectForKey:@"time"];
    }
    else { // use the legacy encoding to recover older data sets
        FCCoordinate* coords = [decoder decodeObjectForKey:@"location"];
        latitude = coords.latitude;
        longitude = coords.longitude;
        altitude = coords.altitude;
        hdop = coords.precision;
        vdop = coords.precision;
        time = NSDate.date;
    }
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    if (self = [super initWithCoordinate:coordinate
                                altitude:altitude
                      horizontalAccuracy:hdop
                        verticalAccuracy:vdop
                               timestamp:time]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.icon = [ILImage imageNamed:[decoder decodeObjectForKey:@"icon"]];
    }
    
    return self;
}

// MARK: - Geocoding

- (void) geocode {
    // TODO serialize these into a queue so that only one can
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:self completionHandler:^(NSArray* marks, NSError* error) {
        self.placemarks = marks;
        [[NSNotificationCenter defaultCenter] postNotificationName:FCLocationGeocodedNotification object:self userInfo:@{
            FCLocationGeocodedPlacemarksKey: self.placemarks,
            FCLocationGeocodingErrorKey: error
        }];
    }];
}

- (NSString*) placeName {
    return [self.placemarks.lastObject name];
}

- (NSString*) placeAddress {
#if IL_APP_KIT
    CLPlacemark* address = self.placemarks.lastObject;
    return [NSString stringWithFormat:@"%@, %@ %@",
            address.thoroughfare,
            address.locality,
            address.administrativeArea];
#else
    return @"";
#endif
}

@end
