//
//  ShowAddrAppDelegate.m
//  ShowAddr
//
//  Created by John Roersma on 10/4/10.
//

#import "ShowAddrAppDelegate.h"
#import "MapPoint.h"


@implementation ShowAddrAppDelegate

@synthesize window = window_;


#pragma mark -
#pragma mark Xcode auto-generated methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSLog(@"* application:didFinishLaunchingWithOptions:");

	currentAltitude_ = -1;
	
	// create & configure the location manager object
	locationManager_ = [[CLLocationManager alloc] init];
	[locationManager_ setDelegate:self];	
	[locationManager_ setDistanceFilter:kCLDistanceFilterNone];
	[locationManager_ setDesiredAccuracy:kCLLocationAccuracyBest];

	// start updating location
	[locationManager_ startUpdatingLocation];

	//jjr note: next line is not needed if delegate is set via IB
	//[mapView_ setDelegate:self];
	[mapView_ setShowsUserLocation:YES];

    [window_ makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"* applicationWillResignActive:");
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSLog(@"* applicationDidEnterBackground:");

	if (reverseGeocoder_ != nil)
	{
		[reverseGeocoder_ cancel];
	}
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	NSLog(@"* applicationWillEnterForeground:");
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	NSLog(@"* applicationDidBecomeActive:");
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	NSLog(@"* applicationWillTerminate:");
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	NSLog(@"* applicationDidReceiveMemoryWarning:");
}


- (void)dealloc
{
	NSLog(@"* dealloc");
    [window_ release];
	[reverseGeocoder_ setDelegate:nil];
	[reverseGeocoder_ release];
	[prevMapPoint_ release];
    [super dealloc];
}



#pragma mark -
#pragma mark IBAction methods

- (IBAction)mapTypeChanged:(id)sender
{
	NSLog(@"* mapTypeChanged");

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
	NSLog(@"* addPinAtCenter:");
	MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:[mapView_ centerCoordinate]
														title:@"Roadkill"];
	[self addPinWithPoint:mapPoint];
}


- (IBAction)showCurrentLocation:(id)sender
{
	NSLog(@"* showCurrentLocation:");

	[locationManager_ startUpdatingLocation];
	[activityIndicator_ startAnimating];
}



#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	currentAltitude_ = [newLocation altitude];
	NSLog(@"* locationManager didUpdate: to=%@, alt=%f", newLocation, currentAltitude_);

	MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:[newLocation coordinate]
												  		title:@"GPS waypoint"];
	[self addPinWithPoint:mapPoint];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"error: Could not find location: %@", error);
}



#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	int radius = 300;  //jjr todo: animate a further zoom-in?
	NSLog(@"* mapView:didAddAnnotationViews:");
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	annotationView.draggable = YES;
	
	id <MKAnnotation> mapPoint = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mapPoint coordinate], radius, radius);
	[mapView setRegion:region animated:YES];
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
	didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	//jjr todo: bug -- sometimes pin cannot be selected after panning/zooming
	if (newState == MKAnnotationViewDragStateEnding)
	{
		id <MKAnnotation> mapPoint = [annotationView annotation];
		[mapView setCenterCoordinate:[mapPoint coordinate] animated:YES];
		[self addPinAtCenter:nil];
	}
}


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	NSLog(@"didFailToLocateUserWithError:");
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	NSLog(@"didUpdateUserLocation:");
}



#pragma mark -
#pragma mark Other methods

- (void)startReverseGeocoder
{
	/* jjr note: reverseGeocoder_ may not be valid here, even if !nil
	 // complete any lookup which may have been in progress
	 if (reverseGeocoder_ != nil && [reverseGeocoder_ isQuerying])
	 {
	 	[reverseGeocoder_ cancel];
	 }
	 */

	// look up city & state using MKReverseGeocoder
	NSLog(@"Requesting MKReverseGeocoder service...");
	reverseGeocoder_ = [[MKReverseGeocoder alloc] initWithCoordinate:[mapView_ centerCoordinate]];  // for centered location
	[reverseGeocoder_ setDelegate:self];
	[reverseGeocoder_ start];
}


- (void)addPinWithPoint:(MapPoint *)point
{
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
	NSLog(@"geocoder failed, error=%@", [error localizedDescription]);
	NSString *errText = [[NSString alloc] initWithFormat:@"Could not obtain address"];
	[addressView_ setText:errText];
	[errText release];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)coder didFindPlacemark:(MKPlacemark *)placeMark
{
/*
 	NSLog(@"found placeMark: city=%@, state=%@, country=%@, addrDict=%@, ", [placeMark locality],
		  																	[placeMark administrativeArea],
		  																	[placeMark countryCode],
																			[placeMark addressDictionary]);
	NSLog(@"country=%@", [placeMark country]);
	NSLog(@"zipcode=%@", [placeMark postalCode]);
	NSLog(@"county=%@",  [placeMark subAdministrativeArea]);
	NSLog(@"subLocality=%@", [placeMark subLocality]);
	NSLog(@"address=%@ %@",  [placeMark subThoroughfare], [placeMark thoroughfare]);
*/
	NSMutableString *locationString = [NSMutableString stringWithCapacity:200];
	if ([placeMark subThoroughfare] != nil)
	{
		[locationString setString:[placeMark subThoroughfare]];          // street number
	}
	else
	{
		[locationString setString:@"#"];
	}

	[locationString appendFormat:@" %@", [placeMark thoroughfare]];  // street name
	[locationString appendFormat:@", %@", [placeMark locality]];     // city
	[locationString appendFormat:@", %@ County, %@  %@", [placeMark subAdministrativeArea],
	 												     [placeMark administrativeArea],
	 													 [placeMark postalCode]];  // county, state, & zip
	if ([placeMark subLocality])
	{
		[locationString appendFormat:@" (subLocality=%@)", [placeMark subLocality]];  // neighborhood/landmark (if any)
	}

	[addressView_ setText:locationString];
	
	[coder setDelegate:nil];
	[coder autorelease];
}


@end
