//
//  LocatorViewController.h
//  RoadKill
//
//  Created by John Roersma on 6/5/2011.
//  Copyright 2011 Seattle RoadKill Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapPoint.h"
#import "WeatherGrabber.h"


#define kMapTypeStd		0	// standard map type
#define kMapTypeSat		1	// satellite map type
#define kMapTypeHyb		2	// hybrid map type

#define kGpsPinLabel	@"GPS waypoint"
#define kSavedPinLabel	@"Saved waypoint"
#define kAddedPinLabel	@"New waypoint"

#define kAssistanceText @"Center crosshairs on report location"

#define kDefaultRadius		300		// default radius for MKCoordinateRegion


@class Observation;

@interface LocatorViewController : UIViewController
<UIApplicationDelegate, CLLocationManagerDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate, WeatherGrabberDelegate>
{
	CLLocationManager *locationManager_;
	MKReverseGeocoder *reverseGeocoder_;
	
	CLLocationDistance currentAltitude_;
	MapPoint *prevMapPoint_;
	WeatherGrabber *weatherGrabber_;
	bool isRequestingMapRecenter_;

	Observation *observation;

	IBOutlet MKMapView *mapView_;
	IBOutlet UIActivityIndicatorView *activityIndicator_;
	IBOutlet UITextView *addressView_;
	IBOutlet UIButton *showAddressButton_;
}

@property (nonatomic, retain) Observation *observation;


- (IBAction)mapTypeChanged:(id)sender;
- (IBAction)refreshCurrentLocation:(id)sender;
- (IBAction)addPinAtCenter:(id)sender;

- (void)startReverseGeocoder;
- (void)addPinWithPoint:(MapPoint *)point;


@end