//
//  WeatherData.m
//  Used by LocatorViewController
//
//  Created by John Roersma on 3/20/2011
//

#import "WeatherData.h"


@implementation WeatherData

@synthesize currentConditions;
@synthesize currentTemp_f;
@synthesize currentTemp_c;
@synthesize currentHumidity;
@synthesize currentWind;


- (void)dealloc
{
	[currentConditions release];
	[currentHumidity release];
	[currentWind release];
	
    [super dealloc];
}


@end
