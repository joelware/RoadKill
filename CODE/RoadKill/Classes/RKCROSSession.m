//
//  RKCROSSession.m
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//

#import "RKCROSSession.h"
#import "RKConstants.h"

@implementation RKCROSSession

@synthesize connection;
@synthesize responseData;

+ (NSMutableURLRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password
{
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										  host:RKProductionServer 
										  path:[NSString stringWithFormat:@"/california/node?name=%@&pass=%@d&op=Log+in&form_id=user_login_block",
												username, password]] autorelease];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	request.HTTPMethod = @"POST";
	
	return request;
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password
{
	NSMutableURLRequest *request = [[self class] authenticationRequestWithUsername:username
																		  password:password];
	if (self.connection)
		[self.connection cancel];
	self.responseData = [NSMutableData data];
	self.connection = [NSURLConnection connectionWithRequest:request
													delegate:self];
}

- (void)doSomethingWithResponse:(NSURLResponse *)response
{
	// break this into a separate method so it can be tested synchronously
	NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], 
			 @"should be NSHTTPURLResponse");
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	NSLog(@"status %d: %@", httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
	NSLog(@"headers %@", httpResponse.allHeaderFields);
}

#pragma mark -
#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	NSAssert(theConnection == self.connection, @"connection error");
	[self doSomethingWithResponse:response];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	NSAssert(theConnection == self.connection, @"connection error");
	[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.responseData = [NSMutableData data];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@",
          [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	NSString *responseString = [[NSString alloc] initWithData:self.responseData
													 encoding:NSUTF8StringEncoding];
	NSLog(@"server said: %@", responseString);
	[responseString release];
}

- (void)dealloc
{
    self.responseData = nil;
	self.connection = nil;
    [super dealloc];
}
@end
