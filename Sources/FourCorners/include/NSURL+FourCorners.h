//
//  NSData+FourCorners.h
//  FourCorners
//
//  Created by Alf Watt on 3/22/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const FCGeoURLType;

@class FCLocation;

@interface NSURL (FourCorners)

/// @returns an RFC 2397 `data:` URL with the provided
/// @param latitude and
/// @param longitude as an `x-type/geo` three tupe with the latitude, longitude and altitude values
/// e.g. `data:x-type/geo,lat,lon`
+ (NSURL*) dataURLWithGeoLat:(double) latitude lon:(double) longitude;

/// @returns an RFC 2397 `data:` URL with the provided
/// @param latitude
/// @param longitude and
/// @param altitude as an `x-type/geo` two tupe with the latitude and longitude values
///
/// e.g. `data:x-type/geo,lat,lon,alt`
///
+ (NSURL*) dataURLWithGeoLat:(double) latitude lon:(double) longitude alt:(double) altitude;

/// @returns an RFC 2397 `data:` URL with the provided
/// @param latitude
/// @param longitude and
/// @param altitude as an `x-type/geo` two tupe with the latitude and longitude values
/// e.g. `data:x-type/geo,lat,lon,alt,time`
+ (NSURL*) dataURLWithGeoLat:(double) latitude lon:(double) longitude alt:(double) altitude time:(NSDate*) time;

+ (NSURL*) dataURLWithLocation:(FCLocation*) location;

+ (nullable FCLocation*) locationFromDataURL:(NSURL*) locationURL;

@end

NS_ASSUME_NONNULL_END
