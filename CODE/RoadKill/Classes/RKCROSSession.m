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
@synthesize sessionState;
@synthesize receivedData;
@synthesize receivedString;

- (id)init
{
	if (self = [super init]) {
		sessionState = RKCROSSessionConnecting;
	}
	return self;
}

- (void)dealloc
{
    self.connection = nil;
    self.receivedData = nil;
	
    [super dealloc];
}

+ (NSMutableURLRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password
{
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" 
										  host:RKProductionServer 
										  path:@"/california/node"];
	RKLog(@"requesting URL %@", url);
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	request.HTTPMethod = @"POST";
//	request.HTTPShouldHandleCookies = NO;
	request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
	// added cachePolicy to try to force reload, but it has no effect. Maybe need to clear cookies?
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

	NSString *stringForBody = [NSString stringWithFormat:@"name=%@&pass=%@&op=Log+in&form_id=user_login_block",
							   username, password];
	request.HTTPBody = [stringForBody dataUsingEncoding:NSUTF8StringEncoding];
	[request setValue:[NSString stringWithFormat:@"%d", request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
	
	RKLog(@"request %@ headers %@", request, request.allHTTPHeaderFields);
	RKLog(@"request body string %@", stringForBody);
	RKLog(@"request body %@", request.HTTPBody);

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
	RKLog(@"response status %d: %@", httpResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
	RKLog(@"response headers %@", httpResponse.allHeaderFields);
	
	long long contentLength = httpResponse.expectedContentLength;
	if (contentLength == NSURLResponseUnknownLength)
		contentLength = 1000;
	self.receivedData = [NSMutableData dataWithCapacity:contentLength];
	
	NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields
															  forURL:[[self class] baseURL]];
	RKLog(@"Response contained %d cookies", cookies.count);
	for (id theCookie in cookies) {
		RKLog(@"  received cookie: %@", theCookie);
	}
	RKLog(@"Persisted cookies: %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[self class] baseURL]]);
}

- (NSMutableURLRequest *)formTokenRequest
{
	LogMethod();
	NSURL *formTokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/california/node/add/roadkill",
												[[self class] baseURL]]];
	RKLog(@"%@", formTokenURL);
	NSMutableURLRequest *result = [NSMutableURLRequest requestWithURL:formTokenURL];
	
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] 
																		  cookiesForURL:[[self class] baseURL]]];
	RKLog(@"headers: %@", headers);
	[result setAllHTTPHeaderFields:headers]; // I am not sure that this is safe. What am I overwriting?
	return result;
}

- (void)obtainFormToken
{
	NSMutableURLRequest *request = [self formTokenRequest];
	if (self.connection)
		[self.connection cancel];
	self.connection = [NSURLConnection connectionWithRequest:request
													delegate:self];
}

#pragma mark -
#pragma mark NSURLConnection delegate
- (NSURLRequest *)connection:(NSURLConnection *)theConnection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	LogMethod();
	RKLog(@"%@ %@ %@", theConnection, request, redirectResponse);
	switch (self.sessionState) {
		case RKCROSSessionConnecting:
			if (redirectResponse) 
				return nil;
	} 
	return request;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	NSAssert(theConnection == self.connection, @"connection error");
	self.receivedData.length = 0;
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

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	self.receivedString = [[[NSString alloc] initWithData:self.receivedData
												 encoding:NSUTF8StringEncoding] autorelease];
	LogMethod();
//	RKLog(@"%@", self.receivedString);
}

@end
