//
//  WeatherGrabber.m
//  Used by LocatorViewController
//
//  Created by John Roersma on 3/20/2011
//

#import "WeatherGrabber.h"


@implementation WeatherGrabber

@synthesize delegate;

- (void)startGrabbingWeatherInfo:(int)zipCode
{
	RKLog(@"grabbing weather for zipcode=%d", zipCode);
	
	if (!zipCode)
	{
		// no valid zipcode, so skipping weather data
		return;
	}

	// create a new WeatherData object
	wxData = [[WeatherData alloc] init];
	
	// use the Google Weather API to get current weather data
	NSString *urlString = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%d", zipCode];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// create a request object
	NSURLRequest *request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestReloadIgnoringCacheData
										 timeoutInterval:30];
	
	// make sure only one connection at a time
	if (urlConnection)
	{
		[urlConnection cancel];
		[urlConnection release];
	}
	
	// prepare the data object
	[xmlData release];
	xmlData = [[NSMutableData alloc] init];
	
	// create the connection object
	urlConnection = [[NSURLConnection alloc] initWithRequest:request
													delegate:self
											startImmediately:YES];
}



#pragma mark -
#pragma mark NSURL-related delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[xmlData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *weatherReport = [[NSString alloc] initWithData:xmlData
													encoding:NSUTF8StringEncoding];
	[weatherReport autorelease];
	//RKLog(@"weather = %@", weatherReport);
	
	// create the XML parser object
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
	[xmlParser setDelegate:self];
	
	// start parsing (note that this is a blocking call!)
	[xmlParser parse];
	
	// parsing is now complete
	[xmlParser release];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[urlConnection release];
	urlConnection = nil;
	
	[xmlData release];
	xmlData = nil;
	
	RKLog(@"** error retrieving weather info: %@", [error localizedDescription]);
}



#pragma mark -
#pragma mark XML parser delegate methods

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqual:@"current_conditions"])
	{
		//RKLog(@"/ found current_conditions!");
		isParsingCurrentConditions = YES;
	}
	else if (isParsingCurrentConditions)
	{
		if ([elementName isEqual:@"condition"])
		{
			wxData.currentConditions = [attributeDict objectForKey:@"data"];
		}
		
		if ([elementName isEqual:@"temp_f"])
		{
			NSNumber *temp_f = [attributeDict objectForKey:@"data"];
			wxData.currentTemp_f = [temp_f intValue];
		}
		
		if ([elementName isEqual:@"temp_c"])
		{
			NSNumber *temp_c = [attributeDict objectForKey:@"data"];
			wxData.currentTemp_c = [temp_c intValue];
		}
		
		if ([elementName isEqual:@"humidity"])
		{
			wxData.currentHumidity = [attributeDict objectForKey:@"data"];
		}
		
		if ([elementName isEqual:@"wind_condition"])
		{
			wxData.currentWind = [attributeDict objectForKey:@"data"];
		}
	}
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	RKLog(@"** XML parsing error: %@", [parseError localizedDescription]);
}


- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
	if ([elementName isEqual:@"current_conditions"])
	{
		//RKLog(@"\\ finished current_conditions!");
		isParsingCurrentConditions = NO;
	
		// inform our delegate
		[delegate gotWeatherData:wxData];
	}
}


@end
