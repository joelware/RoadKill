//
//  LocatorViewController.m
//  RoadKill
//
//  Created by John Roersma on 6/5/2011.
//  Copyright 2011 Seattle RoadKill Team. All rights reserved.
//

#import "LocatorViewController.h"
#import "WeatherGrabber.h"
#import "WeatherData.h"
#import "Observation.h"
#import "RKConstants.h"


@implementation LocatorViewController

@synthesize observation = observation_;


- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationItem.title = @"Report Location";
	
	// configure the Cancel and Save buttons
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				   target:self 
																				   action:@selector(popController)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																				target:self 
																				action:@selector(addPinAndSave)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];

	// create & configure the location manager object
	locationManager_ = [[CLLocationManager alloc] init];
	[locationManager_ setDelegate:self];	
	[locationManager_ setDistanceFilter:kCLDistanceFilterNone];
	[locationManager_ setDesiredAccuracy:kCLLocationAccuracyBest];

	// create the weather grabber object
	weatherGrabber_ = [[WeatherGrabber alloc] init];
	weatherGrabber_.delegate = self;

	if ( ([self.observation.latitude doubleValue] == kDefaultLatitude) &&
		 ([self.observation.longitude doubleValue] == kDefaultLongitude) )
	{
		// this is a new report, so fire up the location manager
		[locationManager_ startUpdatingLocation];
		
		[addressView_ setText:kAssistanceText];
	}
	else
	{
		// this is a previously-saved report, so don't start the location manager yet
		CLLocationCoordinate2D prevCoordinate;
		prevCoordinate = CLLocationCoordinate2DMake([self.observation.latitude doubleValue], [self.observation.longitude doubleValue]);
		MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:prevCoordinate
															title:kSavedPinLabel];
		[self addPinWithPoint:mapPoint];
	}
	
	[mapView_ setDelegate:self];
	[mapView_ setShowsUserLocation:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)shutdownLocatorServices
{
	// shut down the weather grabber
	weatherGrabber_.delegate = nil;
	[weatherGrabber_ release]; weatherGrabber_ = nil;
	
	// shut down the reverse geocoder	
	[reverseGeocoder_ cancel];
	[reverseGeocoder_ setDelegate:nil];
	[reverseGeocoder_ release];
	
	// shut down the location manager
	[locationManager_ stopUpdatingLocation];
	[locationManager_ release]; locationManager_ = nil;
}


- (void)viewDidUnload
{
	[self shutdownLocatorServices];
	
	[prevMapPoint_ release]; prevMapPoint_ = nil;

	[mapView_ release]; mapView_ = nil;
	[activityIndicator_ release]; activityIndicator_ = nil;
	[addressView_ release]; addressView_ = nil;
	[showAddressButton_ release]; showAddressButton_ = nil;

    [super viewDidUnload];
}


- (void)dealloc
{
	[self shutdownLocatorServices];
	
	[observation_ release]; observation_ = nil;
	[prevMapPoint_ release]; prevMapPoint_ = nil;

	[mapView_ release];
	[activityIndicator_ release];
	[addressView_ release];
	[showAddressButton_ release];

    [super dealloc];
}



#pragma mark -
#pragma mark IBAction methods

- (IBAction)mapTypeChanged:(id)sender
{
	int newMapType = [sender selectedSegmentIndex];
	if (newMapType == kMapTypeSat)
	{
		[mapView_ setMapType:MKMapTypeSatellite];
	}
	else if (newMapType == kMapTypeHyb)
	{
		[mapView_ setMapType:MKMapTypeHybrid];
	}
	else
	{
		[mapView_ setMapType:MKMapTypeStandard];
	}
}


- (IBAction)addPinAtCenter:(id)sender
{
	//RKLog(@"* addPinAtCenter:");
	
	MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:[mapView_ centerCoordinate]
														title:kAddedPinLabel];
	[self addPinWithPoint:mapPoint];
}


- (void)addPinAndSave
{
	//RKLog(@"* addPinAndSave");

	NSTimeInterval exitDelay = 0.7;  // standard delay if address is already being shown
	if ([addressView_ isHidden])
	{
		// wait a bit longer so user can see the address show up briefly
		exitDelay = 1.5;
	}
	
	[self addPinAtCenter:nil];
	
	CLLocationCoordinate2D coordinateToSave = [mapView_ centerCoordinate];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:RKSettingsIsTestModeKey])
	{
		// make sure that we only send the default lat & long values to the server when in test mode!
		//TODO: move this checking of test mode to submitNow: in PreviewViewController, once implemented
		RKLog(@"note: saving default coordinates, as we're in test mode!");
		coordinateToSave.latitude = kDefaultLatitude;
		coordinateToSave.longitude = kDefaultLongitude;
	}
	
	RKLog(@"saving: lat=%f, long=%f", coordinateToSave.latitude, coordinateToSave.longitude);
	self.observation.latitude = [NSNumber numberWithDouble:coordinateToSave.latitude];
	self.observation.longitude = [NSNumber numberWithDouble:coordinateToSave.longitude];
	
	// pop back one view after a short delay so the user can see the pin drop
	[self performSelector:@selector(popController) withObject:nil afterDelay:exitDelay];
}


- (void)popController
{
	// pop back one view
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)refreshCurrentLocation:(id)sender
{
	RKLog(@"* refreshCurrentLocation:");  //jjr start

	isRequestingMapRecenter_ = YES;  // recenter map when map location is updated
	[locationManager_ startUpdatingLocation];
	[activityIndicator_ startAnimating];
	[addressView_ setText:kAssistanceText];
}



#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	currentAltitude_ = [newLocation altitude];
	RKLog(@"* locationManager didUpdate: to=%@, alt=%f", newLocation, currentAltitude_);
	
	MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:[newLocation coordinate]
												  		title:kGpsPinLabel];
	[self addPinWithPoint:mapPoint];
	
	if (isRequestingMapRecenter_)
	{
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mapPoint coordinate], kDefaultRadius, kDefaultRadius);
		[mapView_ setRegion:region animated:YES];
		isRequestingMapRecenter_ = NO;
	}
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	RKLog(@"** error: Could not find location: %@", error);
}



#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	//RKLog(@"* mapView:didAddAnnotationViews:");
	
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	annotationView.draggable = YES;

	id <MKAnnotation> mapPoint = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mapPoint coordinate], kDefaultRadius, kDefaultRadius);
	[mapView setRegion:region animated:YES];
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	//FIXME: sometimes pin cannot be selected after panning/zooming
	if (newState == MKAnnotationViewDragStateEnding)
	{
		id <MKAnnotation> mapPoint = [annotationView annotation];
		[mapView setCenterCoordinate:[mapPoint coordinate] animated:YES];
		[self addPinAtCenter:nil];
	}
}


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	RKLog(@"** error: didFailToLocateUserWithError:");
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	//RKLog(@"didUpdateUserLocation:");
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	//RKLog(@"region change!");
	[addressView_ setHidden:YES];
	[showAddressButton_ setHidden:NO];
}



#pragma mark -
#pragma mark Other methods

- (void)startReverseGeocoder
{
	/* note: reverseGeocoder_ may not be valid here, even if !nil
	 // complete any lookup which may have been in progress
	 if (reverseGeocoder_ != nil && [reverseGeocoder_ isQuerying])
	 {
	 [reverseGeocoder_ cancel];
	 }
	 */
	
	// look up city & state using MKReverseGeocoder
	RKLog(@"* requesting MKReverseGeocoder service...");
	//FIXME: reverseGeocoder_ memory leak?
	reverseGeocoder_ = [[MKReverseGeocoder alloc] initWithCoordinate:[mapView_ centerCoordinate]];  // for centered location
	[reverseGeocoder_ setDelegate:self];
	[reverseGeocoder_ start];
}


- (void)addPinWithPoint:(MapPoint *)point
{
	// hide the "Show Address" button
	[showAddressButton_ setHidden:YES];
	[addressView_ setText:kAssistanceText];

	// remove the previous pin, if one exists
	if (prevMapPoint_)
	{
		[mapView_ removeAnnotation:prevMapPoint_];
		[prevMapPoint_ release];
		prevMapPoint_ = nil;
	}

	[mapView_ addAnnotation:point];
	prevMapPoint_ = point;

	[activityIndicator_ stopAnimating];
	[locationManager_ stopUpdatingLocation];

	// look up the address for the new point
	[self startReverseGeocoder];
}



#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)coder didFailWithError:(NSError *)error
{
	RKLog(@"** geocoder failed, error=%@", [error localizedDescription]);
	//NSString *errText = [[NSString alloc] initWithFormat:@"Could not obtain address"];
	[addressView_ setText:kAssistanceText];
	//[errText release];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)coder didFindPlacemark:(MKPlacemark *)placeMark
{
	// start retrieving current weather for the found location
	[weatherGrabber_ startGrabbingWeatherInfo:[[placeMark postalCode] intValue]];
	
	//
	// build a string containing found location info
	//

	NSMutableString *locationString = [NSMutableString stringWithCapacity:500];
	
	// subThoroughfare (street number)
	if ([placeMark subThoroughfare] != nil)
	{
		[locationString setString:[placeMark subThoroughfare]];
		[locationString appendFormat:@" "];
	}
	else
	{
		[locationString setString:@""];
	}
	
	// thoroughfare (street name)
	if ([placeMark thoroughfare] != nil)
	{
		[locationString appendFormat:@"%@, ", [placeMark thoroughfare]];
	}
	
	// locality (city)
	if ([placeMark locality] != nil)
	{
		[locationString appendFormat:@"%@, ", [placeMark locality]];
	}
	
	// subAdministrativeArea (county)
	if ([placeMark subAdministrativeArea] != nil)
	{
		[locationString appendFormat:@"%@ County, ", [placeMark subAdministrativeArea]];
	}

	// administrativeArea (state)
	if ([placeMark administrativeArea] != nil)
	{
		[locationString appendFormat:@"%@ ", [placeMark administrativeArea]];
	}
	
	// postalCode (zip code)
	if ([placeMark postalCode] != nil)
	{
		[locationString appendFormat:@"%@", [placeMark postalCode]];
		
	}
	
	// subLocality (neighborhood/landmark, if any)
	if ([placeMark subLocality])
	{
		[locationString appendFormat:@"  %@", [placeMark subLocality]];
	}
	
	[addressView_ setText:locationString];
	
	// show the address, hide the "Show Address" button
	[showAddressButton_ setHidden:YES];
	[addressView_ setHidden:NO];

	[coder setDelegate:nil];
	[coder autorelease];
	
	//FIXME: A minor UI glitch: If the map is changing the region, sometimes it will clear the address (via the
	//			mapView:regionDidChangeAnimated: method) after it has just been displayed--need a way to detect
	//			this condition.
}



#pragma mark -
#pragma mark WeatherGrabberDelegate methods

- (void)gotWeatherData:(WeatherData *)wxData
{
	RKLog(@"** got weather data!\n");
	RKLog(@"     conditions = %@\n", wxData.currentConditions);
	RKLog(@"     temp = %d (F)\n", wxData.currentTemp_f);
	RKLog(@"     temp = %d (C)\n", wxData.currentTemp_c);
	RKLog(@"     humidity = %@\n", wxData.currentHumidity);
	RKLog(@"     %@\n", wxData.currentWind);
	
	//TODO: save weather conditions as part of the report?
	
	[wxData release];
}

@end
