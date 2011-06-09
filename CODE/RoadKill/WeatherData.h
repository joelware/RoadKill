//
//  WeatherData.h
//  Used by LocatorViewController
//
//  Created by John Roersma on 3/20/2011
//

#import <Foundation/Foundation.h>


@interface WeatherData : NSObject
{
	NSString *currentConditions;
	int currentTemp_f;
	int currentTemp_c;
	NSString *currentHumidity;
	NSString *currentWind;
}

@property (nonatomic, copy) NSString *currentConditions;
@property (nonatomic, assign) int currentTemp_f;
@property (nonatomic, assign) int currentTemp_c;
@property (nonatomic, copy) NSString *currentHumidity;
@property (nonatomic, copy) NSString *currentWind;

@end
