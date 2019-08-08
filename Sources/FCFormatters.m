#import <KitBridge/KitBridge.h>

#import "FCFormatters.h"
#import "FCLocation.h"

#define NSAS    NSAttributedString
#define NSMAS   NSMutableAttributedString

static CGFloat unit_scale = 0.8;

@interface FCFormatter : NSObject

+ (NSDictionary*) unitsAttrs:(NSDictionary*) attrs;
+ (NSDictionary*) cardinalAttrs:(NSDictionary*) attrs;

@end

@implementation FCFormatter

+ (NSDictionary*) unitsAttrs:(NSDictionary*) attrs
{
    ILFont* fullSize = attrs[NSFontAttributeName];
    ILFont* halfSize = [ILFont fontWithName:[fullSize fontName] size:([fullSize pointSize]*unit_scale)];
    ILColor* textColor = attrs[NSForegroundColorAttributeName]; // if it's the controlTextColor we expect, make it disalbed, otherwise passthrough
    NSMutableDictionary* unitsAttrs = [attrs mutableCopy];
    unitsAttrs[NSForegroundColorAttributeName] = ([textColor isEqual:[ILColor controlTextColor]]?[ILColor grayColor]:textColor);
    unitsAttrs[NSFontAttributeName] = halfSize;
    return unitsAttrs;
}

+ (NSDictionary*) cardinalAttrs:(NSDictionary*) attrs
{
    ILColor* textColor = attrs[NSForegroundColorAttributeName]; // if it's the controlTextColor we expect, make it disalbed, otherwise passthrough
    NSMutableDictionary* cardinalAttrs = [attrs mutableCopy];
    cardinalAttrs[NSForegroundColorAttributeName] = ([textColor isEqual:[ILColor controlTextColor]]?[ILColor grayColor]:textColor);
    return cardinalAttrs;
}

+ (NSDictionary*) monospaceAttrs:(NSDictionary*) attrs
{
    NSMutableDictionary* monoAttrs = [attrs mutableCopy];
    ILFont* attrsFont = attrs[NSFontAttributeName];
    ILFont* monoFont = [ILFont userFixedPitchFontOfSize:[attrsFont pointSize]];
    monoAttrs[NSFontAttributeName] = monoFont;
    return monoAttrs;
}

@end

#pragma mark -

@implementation CLLocationDistanceFormatter

+ (instancetype) distanceFormatter
{
    static CLLocationDistanceFormatter* formatter = nil;
    if (!formatter) {
        formatter = [CLLocationDistanceFormatter new];
    }
    return formatter;
}

+ (NSString*) distanceString:(CLLocationDistance) distance
{
	NSString* distanceString = @"";
    
	if (distance == 0 || isnan(distance)) {
		distanceString = @"";
    }
	else if (distance < 0.25) { // then express it in mm, w/0 rounding
		distanceString = [NSString stringWithFormat:@"%.0f", (distance*1000)];
    }
	else if (distance < 2500) { // then express it in meters with one decimals of precision
		distanceString = [NSString stringWithFormat:@"%.1f", distance];
    }
	else { // express it in km
		distanceString = [NSString stringWithFormat:@"%.2f", (distance/1000)];
    }
    
	return distanceString;
}

+ (NSString*) unitsString:(CLLocationDistance) distance
{
	NSString* unitsString = @"";
	// if the distance is less than 1k try meters
	if (distance == 0 || isnan(distance)) {
		unitsString = NSLocalizedString(@"here", @"here");
    }
	else if (distance < 0.25) { // then express it in mm
		unitsString = NSLocalizedString(@"mm", @"mm");
    }
	else if (distance < 2500) { // then express it in meters
		unitsString = NSLocalizedString(@"m", @"m");
    }
	else { // express it in km
		unitsString = NSLocalizedString(@"km", @"km");
    }
    
	return unitsString;
}

- (NSString*) stringForObjectValue:(id) object
{
	return [[[self class] distanceString:[object doubleValue]] stringByAppendingString:[[self class] unitsString:[object doubleValue]]];
}

- (NSAttributedString*) attributedStringForObjectValue:(id) object withDefaultAttributes:(NSDictionary*) attrs
{
    attrs = [FCFormatter monospaceAttrs:attrs];
    NSDictionary* unitsAttrs = [FCFormatter unitsAttrs:attrs];
    
    NSMAS* valueString = [[NSMAS alloc] initWithString:[[self class] distanceString:[object doubleValue]] attributes:attrs];
    NSAS* unitsString = [[NSAS alloc] initWithString:[[self class] unitsString:[object doubleValue]] attributes:unitsAttrs];
    [valueString appendAttributedString:unitsString];
    return valueString;
}

@end

#pragma mark -

@implementation CLLocationSpeedFormatter

+ (instancetype) speedFormatter
{
    static CLLocationSpeedFormatter* formatter = nil;
    if (!formatter) {
        formatter = [CLLocationSpeedFormatter new];
    }
    
    return formatter;
}

+ (NSString*) distanceString:(CLLocationDistance) distance
{
	NSString* distanceString = @"";
    
	if (distance == -1) { // still or no speed indication from Core Location
		distanceString = @"";
    }
	else if (distance < 0.25) { // then express it in mm, w/0 rounding
		distanceString = [NSString stringWithFormat:@"%.0f", (distance*1000)];
    }
	else if (distance < 2500) { // then express it in meters with one decimals of precision
		distanceString = [NSString stringWithFormat:@"%.1f", distance];
    }
	else { // express it in km
		distanceString = [NSString stringWithFormat:@"%.2f", (distance/1000)];
    }
    
	return distanceString;
}

+ (NSString*) unitsString:(CLLocationDistance) distance
{
	NSString* unitsString = @"";
	// if the distance is less than 1k try meters
	if (distance == -1) {
		unitsString = NSLocalizedString(@"still", @"still");
    }
	else if (distance < 0.25) { // then express it in mm
		unitsString = NSLocalizedString(@"mm/s", @"mm/s");
    }
	else if (distance < 2500) { // then express it in meters
		unitsString = NSLocalizedString(@"m/s", @"m/s");
    }
	else { // express it in km
		unitsString = NSLocalizedString(@"km/s", @"km/s");
    }
    
	return unitsString;
}

- (NSString*) stringForObjectValue:(id) object
{
	return [[[self class] distanceString:[object doubleValue]] stringByAppendingString:[[self class] unitsString:[object doubleValue]]];
}

- (NSAttributedString*) attributedStringForObjectValue:(id) object withDefaultAttributes:(NSDictionary*) attrs
{
    attrs = [FCFormatter monospaceAttrs:attrs];
    NSDictionary* unitsAttrs = [FCFormatter unitsAttrs:attrs];
    
    NSMAS* valueString = [[NSMAS alloc] initWithString:[[self class] distanceString:[object doubleValue]] attributes:attrs];
    NSAS* unitsString = [[NSAS alloc] initWithString:[[self class] unitsString:[object doubleValue]] attributes:unitsAttrs];
    [valueString appendAttributedString:unitsString];
    return valueString;
}

@end

#pragma mark -

@implementation CLLocationCoordinateFormatter

+ (instancetype) coordinateFormatter
{
    static CLLocationCoordinateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [CLLocationCoordinateFormatter new];
    }
    
    return formatter;
}

+ (NSString*) coordinateString:(CLLocationCoordinate2D)coordinates
{
    return [NSString stringWithFormat:@"%2.4f, %2.4f", coordinates.latitude, coordinates.longitude];
}

#pragma mark -

- (BOOL) getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing *)error
{
    *obj = [[FCLocation alloc] initWithNMEAString:string];
    return *obj != nil;
}

- (NSString *)stringForObjectValue:(id)anObject
{
    return [anObject description];
}

enum FCLocationFormat
{
    FCCoordicateDMSFormat,
    FCLocationDM4Format
};

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attrs
{
    NSMutableAttributedString* formatted = [NSMutableAttributedString new];
    attrs = [FCFormatter monospaceAttrs:attrs];

    if ([anObject isKindOfClass:[FCLocation class]]) {
        FCLocation* location = (FCLocation*) anObject;
        attrs = [FCFormatter monospaceAttrs:attrs];
        NSDictionary* cardinalAttrs = [FCFormatter cardinalAttrs:attrs];
        
        /* [NSString stringWithFormat:@"%c%.0lf° %.4lf' %c%.0lf° %.4lf'%@",
                [self latitudeHemisphere],
                [self latitudeDegrees],
                [self latitudeMinutes],
                [self longitudeHemisphere],
                [self longitudeDegrees],
                [self longitudeMinutes], */
        
        // TODO format options for dd° mm' ss" instead of dd° mm.mmmm'
        
        [formatted appendAttributedString:[[NSAS alloc] initWithString:
            [NSString stringWithFormat:@"%c", [location latitudeHemisphere]] attributes:cardinalAttrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:
            [NSString stringWithFormat:@"%.0lf", [location latitudeDegrees]] attributes:attrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:@"°\u00a0" attributes:cardinalAttrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:
            [NSString stringWithFormat:@"%2.4lf", [location latitudeMinutes]] attributes:attrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:@"' " attributes:cardinalAttrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:
            [NSString stringWithFormat:@"%c", [location longitudeHemisphere]] attributes:cardinalAttrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:
            [NSString stringWithFormat:@"%.0lf", [location longitudeDegrees]] attributes:attrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:@"°\u00a0" attributes:cardinalAttrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:
            [NSString stringWithFormat:@"%2.4lf", [location longitudeMinutes]] attributes:attrs]];
        [formatted appendAttributedString:[[NSAS alloc] initWithString:@"'" attributes:cardinalAttrs]];
        
        /*
        if ([anObject altitude] != 0.0) {
            NSDictionary* unitsAttrs = [FCFormatter unitsAttrs:attrs];

            [formatted appendAttributedString:[[NSAS alloc] initWithString:@" MSL" attributes:unitsAttrs]];
            if ([anObject altitude] > 0) { // the fomatter below won't inlcude the '+' char, which we want in the unitsAttrs, when above MSL
                [formatted appendAttributedString:[[NSAS alloc] initWithString:@"+" attributes:unitsAttrs]];
            }
            [formatted appendAttributedString:[[NSAS alloc] initWithString:[CLLocationDistanceFormatter distanceString:[anObject altitude]] attributes:attrs]];
            [formatted appendAttributedString:[[NSAS alloc] initWithString:[CLLocationDistanceFormatter unitsString:[anObject altitude]] attributes:unitsAttrs]];
        }
        */
    }
    return formatted;
}

@end

#pragma mark -

@implementation CLLocationDirectionFormatter

+ (instancetype) directionFormatter
{
    static CLLocationDirectionFormatter* formatter = nil;
    if (!formatter) {
        formatter = [CLLocationDirectionFormatter new];
    }
    
    return formatter;
}

+ (NSString*) bearingString:(CLLocationDirection) direction
{
	NSString* bearingString = @"-";
    
	if ((direction > FCNorthByNorthWest) || (direction < FCNorthByNorthEast)) {
		bearingString = NSLocalizedString(@"N", @"North");
    }
	else if ((direction > FCNorthByNorthEast) && (direction < FCEastByNorthEast)) {
 		bearingString = NSLocalizedString(@"NE", @"North East");
    }
	else if ((direction > FCEastByNorthEast) && (direction < FCEastBySouthEast)) {
		bearingString = NSLocalizedString(@"E", @"East");
    }
	else if ((direction > FCEastBySouthEast) && (direction < FCSouthBySouthEast)) {
		bearingString = NSLocalizedString(@"SE", @"South East");
    }
	else if ((direction > FCSouthBySouthEast) && (direction < FCSouthBySouthWest)) {
		bearingString = NSLocalizedString(@"S", @"South");
    }
	else if ((direction > FCSouthBySouthWest) && (direction < FCWestBySouthWest)) {
		bearingString = NSLocalizedString(@"SW", @"South West");
    }
	else if ((direction > FCWestBySouthWest) && (direction < FCWestByNorthWest)) {
		bearingString = NSLocalizedString(@"W", @"West");
    }
	else if ((direction > FCWestByNorthWest) && (direction < FCNorthByNorthWest)) {
		bearingString = NSLocalizedString(@"NW", @"North West");
	}
    
	return bearingString;
}

- (NSString*) stringForObjectValue:(id) object
{
    NSNumber* bearing = (NSNumber*) object;
    NSString* bearingString = @"-";

	if ([bearing intValue] != -1) {
		bearingString = [NSString stringWithFormat:@"%@ ~ %i°", [[self class] bearingString:[bearing doubleValue]], [bearing intValue]];
    }
    
    return bearingString;
}

- (NSAttributedString*) attributedStringForObjectValue:(id) anObject withDefaultAttributes:(NSDictionary*) attrs
{
    NSNumber* bearing = (NSNumber*) anObject;
    attrs = [FCFormatter monospaceAttrs:attrs];
    NSDictionary* cardinalAttrs = [FCFormatter cardinalAttrs:attrs];
    NSAS* valueString = nil;
    
	if ([bearing intValue] == -1) {
		valueString = [[NSAS alloc] initWithString:@"~" attributes:cardinalAttrs];
    }
	else {
		NSMAS* bearingString = [[NSMAS alloc] initWithString:[[self class] bearingString:[bearing doubleValue]] attributes:cardinalAttrs];
        [bearingString appendAttributedString:[[NSAS alloc] initWithString:@" ~ " attributes:cardinalAttrs]];
        [bearingString appendAttributedString:[[NSAS alloc] initWithString:[NSString stringWithFormat:@"%i",[bearing intValue]] attributes:attrs]];
        [bearingString appendAttributedString:[[NSAS alloc] initWithString:@"°" attributes:cardinalAttrs]];

        valueString = bearingString;
    }
    
    return valueString;
}

@end

#pragma mark -

@implementation CLLocationDirectionArrowFormatter

+ (instancetype) directionFormatter
{
    static CLLocationDirectionArrowFormatter* formatter = nil;

    if (!formatter) {
        formatter = [CLLocationDirectionArrowFormatter new];
    }
    
    return formatter;
}

/*
extern FCCardinal FCNorthArrow;
extern FCCardinal FCSouthArrow;
extern FCCardinal FCEastArrow;
extern FCCardinal FCWestArrow;

extern FCCardinal FCNorthWestArrow;
extern FCCardinal FCNorthEastArrow;
extern FCCardinal FCSouthEastArrow;
extern FCCardinal FCSouthWestArrow;
*/

+ (NSString*) bearingString:(CLLocationDirection) direction
{
	unichar arrowChar = 0;
    
	if ((direction == 0) || (direction > FCNorthByNorthWest) || (direction < FCNorthByNorthEast)) {
		arrowChar = FCNorthArrow;
    }
	else if ((direction > FCNorthByNorthEast) && (direction < FCEastByNorthEast)) {
		arrowChar = FCNorthEastArrow;
    }
	else if ((direction > FCEastByNorthEast) && (direction < FCEastBySouthEast)) {
		arrowChar = FCEastArrow;
    }
	else if ((direction > FCEastBySouthEast) && (direction < FCSouthBySouthEast)) {
		arrowChar = FCSouthEastArrow;
    }
	else if ((direction > FCSouthBySouthEast) && (direction < FCSouthBySouthWest)) {
		arrowChar = FCSouthArrow;
    }
	else if ((direction > FCSouthBySouthWest) && (direction < FCWestBySouthWest)) {
		arrowChar = FCSouthWestArrow;
    }
	else if ((direction > FCWestBySouthWest) && (direction < FCWestByNorthWest)) {
		arrowChar = FCWestArrow;
    }
	else if ((direction > FCWestByNorthWest) && (direction < FCNorthByNorthWest)) {
		arrowChar = FCNorthWestArrow;
    }
	
	return [NSString stringWithCharacters:&arrowChar length:1];
}

- (NSString*) stringForObjectValue:(id) object
{
    NSNumber* bearing = (NSNumber*) object;
	if( [bearing intValue] == -1)
		return @"-";
	else
		return [[self class] bearingString:[bearing doubleValue]];
}

- (NSAttributedString*) attributedStringForObjectValue:(id) anObject withDefaultAttributes:(NSDictionary*) attrs
{
    NSNumber* bearing = (NSNumber*) anObject;
    attrs = [FCFormatter monospaceAttrs:attrs];
    NSDictionary* unitsAttrs = [FCFormatter unitsAttrs:attrs];
    NSDictionary* cardinalAttrs = [FCFormatter cardinalAttrs:attrs];
    
	if( [bearing intValue] == -1)
		return [[NSAS alloc] initWithString:@"-" attributes:unitsAttrs];
	else
		return [[NSAS alloc] initWithString:[[self class] bearingString:[bearing doubleValue]] attributes:cardinalAttrs];
}

@end

#pragma mark -

@implementation CLLocationDirectionKanjiFormatter

+ (instancetype) directionFormatter
{
    static CLLocationDirectionKanjiFormatter* formatter = nil;
    if (!formatter) {
        formatter = [CLLocationDirectionKanjiFormatter new];
    }
    
    return formatter;
}

/*
 extern FCCardinal FCNorthKanji;
 extern FCCardinal FCSouthKanji;
 extern FCCardinal FCEastKanji;
 extern FCCardinal FCWestKanji;
*/

+ (NSString*) bearingString:(CLLocationDirection) direction
{
	unichar arrowChar = 0;
    
	if( direction == 0 || direction > FCNorthWest || direction < FCNorthEast )
		arrowChar = FCNorthKanji;
	else if ( direction > FCNorthEast && direction < FCSouthEast )
		arrowChar = FCEastKanji;
	else if ( direction > FCSouthEast && direction < FCSouthWest )
		arrowChar = FCSouthKanji;
	else if ( direction > FCSouthWest && direction < FCNorthWest )
		arrowChar = FCWestKanji;
	
	return [NSString stringWithCharacters:&arrowChar length:1];
}

- (NSString*) stringForObjectValue:(id) object
{
    NSNumber* bearing = (NSNumber*) object;
	if( [bearing intValue] == -1)
		return @"-";
	else
		return [[self class] bearingString:[bearing doubleValue]];
}

- (NSAttributedString*) attributedStringForObjectValue:(id) anObject withDefaultAttributes:(NSDictionary*) attrs
{
    NSNumber* bearing = (NSNumber*) anObject;
    attrs = [FCFormatter monospaceAttrs:attrs];
    NSDictionary* unitsAttrs = [FCFormatter unitsAttrs:attrs];
    NSDictionary* cardinalAttrs = [FCFormatter cardinalAttrs:attrs];

	if( [bearing intValue] == -1)
		return [[NSAS alloc] initWithString:@"-" attributes:unitsAttrs];
	else
		return [[NSAS alloc] initWithString:[[self class] bearingString:[bearing doubleValue]] attributes:cardinalAttrs];
}

@end

#pragma mark -

@implementation FCLocationLogFormatter

+ (instancetype) logFormatter
{
    static FCLocationLogFormatter* formatter = nil;
    if (!formatter)
        formatter = [FCLocationLogFormatter new];
    
    return formatter;
}

+ (NSString*) logString:(FCLocation*) location
{
    if( !location) {
        return @"lat,lon,alt,hdop,vdop,speed,course,name,type";
    }
    else {
        return [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f,%f,%@,%@",
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.altitude,
                location.horizontalAccuracy,
                location.verticalAccuracy,
                location.speed,
                location.course,
                location.name,
                location.type];
    }
}

- (NSString*) stringForObjectValue:(id) object
{
    return [FCLocationLogFormatter logString:object];
}

@end

/* Copyright © 2010-2019, Alf Watt (alf@istumbler.net) All rights reserved. */
