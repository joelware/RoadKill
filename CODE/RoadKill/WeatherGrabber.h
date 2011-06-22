//
//  WeatherGrabber.h
//  Used by LocatorViewController
//
//  Created by John Roersma on 3/20/2011
//

#import <Foundation/Foundation.h>
#import "WeatherData.h"


@protocol WeatherGrabberDelegate <NSObject>

@required
- (void) gotWeatherData:(WeatherData *)data;

@end



@interface WeatherGrabber : NSObject <NSXMLParserDelegate>
{
	WeatherData *wxData;
	id delegate;
	NSMutableData *xmlData;
	NSURLConnection *urlConnection;
	bool isParsingCurrentConditions;
}

- (void)startGrabbingWeatherInfo:(int)zipCode;

@property(nonatomic, retain) id delegate;

@end
