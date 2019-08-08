#import "FCAnnotation.h"
#import "FCFormatters.h"

@interface FCAnnotation ()
@property(nonatomic, assign) CLLocationCoordinate2D coordinateStorage;
@property(nonatomic, retain) NSString *titleStorage;
@property(nonatomic, retain) NSString *subtitleStorage;

@end

#pragma mark -


@implementation FCAnnotation

+ (instancetype) annotationAtCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title andSubtitle:(NSString*)subtitle
{
    FCAnnotation* annotation = [FCAnnotation new];
    annotation.coordinateStorage = coordinate;
    annotation.titleStorage = title;
    annotation.subtitleStorage = subtitle;
    return annotation;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D) coordinate
{
    return self.coordinateStorage;
}

- (NSString*) title
{
    return [self.titleStorage copy];
}

- (NSString*) subtitle
{
    return [self.subtitleStorage copy];
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    [self willChangeValueForKey:@"coordinate"];
    self.coordinateStorage = newCoordinate;
    [self didChangeValueForKey:@"coordinate"];
}

#pragma mark - NSKeyValueObserving

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    @try {
        [super removeObserver:observer forKeyPath:keyPath];
    }
    @catch(NSException* except) {
        NSLog(@"EXCEPTION: %@ in %@ removeObserver: %@ forKeyPath: %@", except, self, observer, keyPath);
    }
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@ %p: %@, %@ at %@ icon: %@>",
        self.class, self, self.titleStorage, self.subtitleStorage, [CLLocationCoordinateFormatter coordinateString:self.coordinateStorage], self.icon];
}

@end

/* Copyright © 2010-2019, Alf Watt (alf@istumbler.net) All rights reserved. */
