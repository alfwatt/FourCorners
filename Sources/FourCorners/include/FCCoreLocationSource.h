#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#if SWIFT_PACKAGE
#import "FCLocationSource.h"
#else
#import <FourCorners/FCLocationSource.h>
#endif

@interface FCCoreLocationSource : FCLocationSource <CLLocationManagerDelegate>
@property(nonatomic,retain) CLLocationManager* manager;
@property(nonatomic,retain) FCLocation* current; // you are here, or thereabouts
@property(nonatomic,retain) NSMutableArray* track; // array of locations tracked from this source

// MARK: -

+ (FCCoreLocationSource*) coreLocationSource;

@end
