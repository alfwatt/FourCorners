#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#if SWIFT_PACKAGE
#import "KitBridge.h"
#else
#import <KitBridge/KitBridge.h>
#endif

/// a concerte MKMapAnnotation class */
@interface FCAnnotation : NSObject <MKAnnotation>
@property(nonatomic, weak) id representedObject;
@property(nonatomic, retain) ILImage* icon;

// MARK: -

+ (instancetype) annotationAtCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
