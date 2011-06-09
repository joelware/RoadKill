//
//  MapPoint.m
//  Used by LocatorViewController
//
//  Created by John Roersma on 3/12/2011
//

#import "MapPoint.h"


@implementation MapPoint

@synthesize coordinate, title;


- (id)initWithCoordinate:(CLLocationCoordinate2D)pointCoordinate
				   title:(NSString *)pointTitle
{
	[super init];
	coordinate = pointCoordinate;
	self.title = pointTitle;
	return self;
}


- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	coordinate = newCoordinate;
}


- (void)dealloc
{
	[title release];
	[super dealloc];
}

@end
