#import <KitBridge/KitBridge.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

/*! @brief a concerte MKMapAnnotation class */
@interface FCAnnotation : NSObject <MKAnnotation>
@property(nonatomic, weak) id representedObject;
@property(nonatomic, retain) ILImage* icon;

#pragma mark -

+ (instancetype) annotationAtCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end

/* Copyright 2010-2019, Alf Watt (alf@istumbler.net) All rights reserved. */
