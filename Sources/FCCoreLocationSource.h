#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <FourCorners/FCLocationSource.h>

@interface FCCoreLocationSource : FCLocationSource <CLLocationManagerDelegate>
@property(nonatomic,retain) CLLocationManager* manager;
@property(nonatomic,retain) FCLocation* current; // you are here, or thereabouts
@property(nonatomic,retain) NSMutableArray* track; // array of locations tracked from this source

+ (FCCoreLocationSource*) coreLocationSource;

@end

/* Copyright 2010-2018, Alf Watt (alf@istumbler.net) All rights reserved. */
