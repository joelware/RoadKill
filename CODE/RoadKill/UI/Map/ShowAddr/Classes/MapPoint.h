//
//  MapPoint.h
//  ShowAddr
//
//  Created by John Roersma on 10/6/10.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface MapPoint : NSObject <MKAnnotation>
{
	NSString *title;
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)pointCoordinate title:(NSString *)pointTitle;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
