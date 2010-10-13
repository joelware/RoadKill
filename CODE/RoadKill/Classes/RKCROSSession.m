//
//  RKCROSSession.m
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//

#import "RKConstants.h"
#import "RKCROSSession.h"
#import "Observation.h"

#define kSaveObservationStringLength 3500
#define kFormBoundaryString @"---------------------------1184049667376"
#define kURLResponseSWAGLength 1000

@interface NSMutableString (RKCROSSession)
// this category is used by -observationSubmissionRequestForObservation:
- (void)addFieldName:(NSString *)fieldName
			   value:(NSString *)fieldValue;
@end
@implementation NSMutableString (RKCROSSession)
- (void)addFieldName:(NSString *)fieldName
			   value:(NSString *)fieldValue;
{
	[self appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n%@\r\n",
	 fieldName, fieldValue, kFormBoundaryString];
}
@end

@implementation RKCROSSession

@synthesize connection;
@synthesize sessionState;
@synthesize receivedData;
@synthesize receivedString;
@synthesize formToken;

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
										  host:RKWebServer 
										  path:@"/california/node"];
	RKLog(@"requesting URL %@", url);
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	request.HTTPMethod = @"POST";
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

- (NSMutableURLRequest *)observationSubmissionRequestForObservation:(Observation *)obs
{
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" 
										  host:RKWebServer 
										  path:@"/california/node/add/roadkill"];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	request.HTTPMethod = @"POST";
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kFormBoundaryString]
   forHTTPHeaderField:@"Content-Type"];
	
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] 
																		  cookiesForURL:[[self class] baseURLForWildlifeServer]]];
	RKLog(@"headers: %@", headers);
	[request setAllHTTPHeaderFields:headers]; // I am not sure that this is safe. What am I overwriting?

	NSMutableString *stringForBody = [NSMutableString stringWithCapacity:kSaveObservationStringLength];
	[stringForBody appendString:@"\r\n"];
	[stringForBody appendString:kFormBoundaryString];
	[stringForBody appendString:@"\r\n"];

	// field by field:
	[stringForBody addFieldName:@"taxonomy[1]" value:[NSString stringWithFormat:@"%d",
													  obs.taxonomy]];
	//[stringForBody addFieldName:@"field_taxon_ref[0][nid][nid]" value:obs.fieldTaxon];
	[stringForBody addFieldName:@"field_taxon_freetext[0][value]" value:obs.freeText];
	NSAssert(self.formToken, @"formToken not set");
	[stringForBody addFieldName:@"form_token" value:self.formToken];
	[stringForBody addFieldName:@"form_id" value:@"roadkill_node_form"];
	[stringForBody addFieldName:@"field_id_confidence[value]" value:obs.formIDConfidence];
	[stringForBody addFieldName:@"field_geography[0][street]" value:obs.street];

	NSDateFormatter *obsDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[obsDateFormatter setDateFormat:@"YYYY-MM-dd"];
	[stringForBody addFieldName:@"field_date_observation[0][value][date]" 
						  value:[obsDateFormatter stringFromDate:obs.observationTimestamp]];
	[obsDateFormatter setDateFormat:@"kk:mm"];
	[stringForBody addFieldName:@"field_date_observation[0][value][time]" 
						  value:[obsDateFormatter stringFromDate:obs.observationTimestamp]];
	[stringForBody addFieldName:@"field_date_observation[0][value][time]" 
						  value:@"16:15"];
	
	[stringForBody addFieldName:@"field_decay_duration" value:[NSString stringWithFormat:@"%d",
															   obs.decayDurationHours]];
	[stringForBody addFieldName:@"field_observer[0][value]" value:obs.observerName];
	
	[stringForBody addFieldName:@"log" value:@"test log message Seattle iPhone Team"];
	[stringForBody addFieldName:@"op" value:@"Save"];
	RKLog(@"**********");
	RKLog(@"%@", stringForBody);
	RKLog(@"**********");
	request.HTTPBody = [stringForBody dataUsingEncoding:NSUTF8StringEncoding];
	[request setValue:[NSString stringWithFormat:@"%d", request.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
	
	RKLog(@"request %@ headers %@", request, request.allHTTPHeaderFields);
	RKLog(@"request body string %@", stringForBody);
	RKLog(@"request body %@", request.HTTPBody);
	
	return request;
}

+ (NSURL *)baseURLForWildlifeServer
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", RKWebServer]];
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
		contentLength = kURLResponseSWAGLength; 
	self.receivedData = [NSMutableData dataWithCapacity:contentLength];
	
	NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields
															  forURL:[[self class] baseURLForWildlifeServer]];
	RKLog(@"Response contained %d cookies", cookies.count);
	for (id theCookie in cookies) {
		RKLog(@"  received cookie: %@", theCookie);
	}
	RKLog(@"Persisted cookies: %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[self class] baseURLForWildlifeServer]]);
}

- (NSMutableURLRequest *)formTokenRequest
{
	LogMethod();
	NSURL *formTokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/california/node/add/roadkill",
												[[self class] baseURLForWildlifeServer]]];
	RKLog(@"%@", formTokenURL);
	NSMutableURLRequest *result = [NSMutableURLRequest requestWithURL:formTokenURL];
	
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] 
																		  cookiesForURL:[[self class] baseURLForWildlifeServer]]];
	RKLog(@"headers: %@", headers);
	[result setAllHTTPHeaderFields:headers]; // I am not sure that this is safe. What am I overwriting?
	return result;
}

- (void)obtainFormToken
{
	NSAssert((self.sessionState == RKCROSSessionAuthenticated), @"session not authenticated");
	NSMutableURLRequest *request = [self formTokenRequest];
	if (self.connection)
		[self.connection cancel];
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (BOOL)extractFormTokenFromReceivedString
{
	// <input type="hidden" name="form_token" id="edit-roadkill-node-form-form-token" value="014bed2bec533edbae01c14ebac6e174"  />

	NSRange tokenFormElementRange = [self.receivedString rangeOfString:@"<input type=\"hidden\" name=\"form_token\".*>"
													options:NSRegularExpressionSearch];
	if (tokenFormElementRange.length > 0) {
		RKLog(@"found %@", [self.receivedString substringWithRange:tokenFormElementRange]);
		NSScanner *scanner = [NSScanner scannerWithString:[self.receivedString substringWithRange:tokenFormElementRange]];
		[scanner scanUpToString:@"value=\"" intoString:NULL];
		[scanner scanUpToString:@"\"" intoString:NULL];
		scanner.scanLocation++;
		NSString *theToken;
		[scanner scanUpToString:@"\"" intoString:&theToken];
		self.formToken = theToken;
		RKLog(@"token %@", self.formToken);
		return YES;
	}
	return NO;
}

- (BOOL)submitObservationReport:(Observation *)report
{
	// FIXME: this submits only the bare minimum required form info
	LogMethod();
	NSAssert(self.sessionState = RKCROSSessionFormTokenObtained, @"need RKCROSSessionFormTokenObtained");
	NSMutableURLRequest *reportSubmissionRequest = 
	[self observationSubmissionRequestForObservation:report];
	if (self.connection)
		[self.connection cancel];
	self.connection = [NSURLConnection connectionWithRequest:reportSubmissionRequest delegate:self];
	self.sessionState = RKCROSSessionObservationSubmitted;
	return YES;
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
			break;
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
	switch (self.sessionState) {
		case RKCROSSessionConnecting:
			self.sessionState = RKCROSSessionAuthenticated;
			break;
		case RKCROSSessionAuthenticated:
			if ([self extractFormTokenFromReceivedString])
				self.sessionState = RKCROSSessionFormTokenObtained;
			break;
		case RKCROSSessionObservationSubmitted:
			RKLog(@"%@", self.receivedString);
			break;
	}

}

@end
