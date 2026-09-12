#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#if __has_include(<KitBridge/KitBridge.h>)
#import <KitBridge/KitBridge.h>
#else
#import "KitBridge.h"
#endif

/// a concerte MKMapAnnotation class */
@interface FCAnnotation : NSObject <MKAnnotation>
@property(nonatomic, weak) id representedObject;
@property(nonatomic, retain) ILImage* icon;

// MARK: -

+ (instancetype) annotationAtCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
