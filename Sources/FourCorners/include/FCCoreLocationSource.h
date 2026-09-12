#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#if __has_include(<FourCorners/FCLocationSource.h>)
#import <FourCorners/FCLocationSource.h>
#else
#import "FCLocationSource.h"
#endif

@interface FCCoreLocationSource : FCLocationSource <CLLocationManagerDelegate>
@property(nonatomic,retain) CLLocationManager* manager;
@property(nonatomic,retain) FCLocation* current; // you are here, or thereabouts
@property(nonatomic,retain) NSMutableArray* track; // array of locations tracked from this source

// MARK: -

+ (FCCoreLocationSource*) coreLocationSource;

@end
