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
@synthesize receivedData;

- (void)dealloc
{
    self.connection = nil;
    self.receivedData = nil;
	
    [super dealloc];
}

+ (NSMutableURLRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password
{
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										  host:RKProductionServer 
										  path:[NSString stringWithFormat:@"/california/node?name=%@&pass=%@d&op=Log+in&form_id=user_login_block",
												username, password]] autorelease];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	request.HTTPMethod = @"POST";
	request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
	// added cachePolicy to try to force reload, but it has no effect. Maybe need to clear cookies?
	
	return request;
}

+ (NSURL *)baseURL
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", RKProductionServer]];
}
			
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password
{
	NSMutableURLRequest *request = [[self class] authenticationRequestWithUsername:username
																		  password:password];
	if (self.connection)
		[self.connection cancel];
	self.receivedData.length = 0;
	RKLog(@"%@", self.receivedData.class);
	self.connection = [NSURLConnection connectionWithRequest:request
													delegate:self];
}

- (void)doSomethingWithResponse:(NSURLResponse *)response
{
	// this method might be completely unnecessary. After the authentication request has been sent, 
	// cookies are available using NSHTTPCookieStorage. We don't have to do anything manually. Might
	// be able to scrap the connection:didReceiveData: implementation and receivedData ivar.
	
	// break out into separate method with no NSURLConnection reference, for unit testing
	NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], 
			 @"should be NSHTTPURLResponse");
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	RKLog(@"status %d: %@", httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
	RKLog(@"headers %@", httpResponse.allHeaderFields);
	
	long long contentLength = httpResponse.expectedContentLength;
	if (contentLength == NSURLResponseUnknownLength)
		contentLength = 1000;
	self.receivedData = [NSMutableData dataWithCapacity:contentLength];
	
	NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields
															  forURL:[[self class] baseURL]];
	RKLog(@"received cookie: %@", cookies.lastObject);
	RKLog(@"persisted cookie: %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[self class] baseURL]]);
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
	NSAssert(self.receivedData, @"bad receivedData ivar");
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	LogMethod();
    self.connection = nil;
	self.receivedData.length = 0;
	
    // inform the user
    RKLog(@"Connection failed! Error - %@",
          [error localizedDescription]);
}

@end
