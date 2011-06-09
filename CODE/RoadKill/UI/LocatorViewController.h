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
	
//TODO: move preferences/settings into main app
//	// RoadKill ivars for demo of user settings
//	NSString *host_web_url;
//	NSString *user_name;
//	NSString *user_password;
//	bool delete_once_uploaded;
//	bool debug_mode;
//	bool test_data_mode;
}


@property (nonatomic, retain) Observation *observation;

//@property (nonatomic, copy) NSString *host_web_url;
//@property (nonatomic, copy) NSString *user_name;
//@property (nonatomic, copy) NSString *user_password;


- (IBAction)mapTypeChanged:(id)sender;
- (IBAction)refreshCurrentLocation:(id)sender;
- (IBAction)addPinAtCenter:(id)sender;

- (void)startReverseGeocoder;
- (void)addPinWithPoint:(MapPoint *)point;


@end
