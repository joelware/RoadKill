//
//  MapPoint.h
//  Used by LocatorViewController
//
//  Created by John Roersma on 3/12/2011
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
