//
//  ShowAddrAppDelegate.h
//  ShowAddr
//
//  Created by John Roersma on 10/4/10.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapPoint.h"

#define kMapTypeStd		0	// standard map type
#define kMapTypeSat		1	// satellite map type
#define kMapTypeHyb		2	// hybrid map type


@interface ShowAddrAppDelegate : NSObject
	<UIApplicationDelegate, CLLocationManagerDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate>
{
    UIWindow *window_;
	CLLocationManager *locationManager_;
	MKReverseGeocoder *reverseGeocoder_;
	
	CLLocationDistance currentAltitude_;
	MapPoint *prevMapPoint_;
	
	IBOutlet MKMapView *mapView_;
	IBOutlet UIActivityIndicatorView *activityIndicator_;
	IBOutlet UITextView *addressView_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction)mapTypeChanged:(id)sender;
- (IBAction)showCurrentLocation:(id)sender;
- (IBAction)addPinAtCenter:(id)sender;

- (void)startReverseGeocoder;
- (void)addPinWithPoint:(MapPoint *)point;

@end

