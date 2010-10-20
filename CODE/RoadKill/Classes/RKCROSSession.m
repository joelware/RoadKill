//
//  RKCROSSession.m
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//

#import "RKConstants.h"
#import "RKCROSSession.h"
#import "Observation.h"
#import "SpeciesCategory.h"

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

@synthesize speciesCategory;
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
	[speciesCategory release], speciesCategory = nil;
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

- (NSString*) multipartMIMEStringWithDictionary: (NSDictionary*) dict 
{
	NSString* result = [NSString string];
	
	for (NSString *theKey in dict) {
		NSString *theValue = [dict valueForKey:theKey];
		RKLog(@"key %@ %@", theKey, theValue);
		if (theValue)
			result = [result stringByAppendingFormat:
					  @"%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
					  kFormBoundaryString, theKey, theValue];
	}
	result = [result stringByAppendingFormat:@"\r\n%@--\r\n", kFormBoundaryString];
	return result;
}


- (NSMutableURLRequest *)observationSubmissionRequestForObservation:(Observation *)obs
{
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										  host:RKWebServer 
										  path:@"/california/node/add/roadkill"] autorelease];
	NSMutableURLRequest *postRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	postRequest.HTTPMethod = @"POST";
	[postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kFormBoundaryString]
	   forHTTPHeaderField:@"Content-Type"];
	
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] 
																		  cookiesForURL:[[self class] baseURLForWildlifeServer]]];
	RKLog(@"my headers: %@", headers);
	RKLog(@"default headers: %@", postRequest.allHTTPHeaderFields);
	[postRequest setAllHTTPHeaderFields:headers]; // I am not sure that this is safe. What am I overwriting?
	[postRequest addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
	[postRequest addValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kFormBoundaryString] 
	   forHTTPHeaderField: @"Content-Type"];

	// FIXME: this should be done with NSMutableData, not NSMutableString!
	// http://lists.apple.com/archives/web-dev/2007/Dec/msg00017.html appears to have the answer
	// hmm, no it's the Content-Disposition/Content-Type that I'm missing
	// http://cocoadev.com/index.pl?HTTPFileUpload
	//
	// This one really wraps it nicely: http://cocoadev.com/forums/comments.php?DiscussionID=1402
	//
	NSAssert(self.formToken, @"formToken not set");
	NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									  obs.speciesCategory.code, @"taxonomy[1]",
									  @"5: Mammal (large)", @"field_taxon_ref[0][nid][nid]",
									  
									  obs.freeText, @"field_taxon_freetext[0][value]",
									  self.formToken, @"form_token", 
									  @"roadkill_node_form", @"form_id",
									  obs.formIDConfidence, @"field_id_confidence[value]",
									  obs.street, @"field_geography[0][street]", 
									  obs.decayDurationHours, @"field_decay_duration",
									  obs.observerName, @"field_observer[0][value]", 
									  @"test log message Seattle iPhone Team",	@"log", 
									  @"Save", @"op",
									  nil];
	
	NSDateFormatter *obsDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[obsDateFormatter setDateFormat:@"YYYY-MM-dd"];
	[arguments setObject:[obsDateFormatter stringFromDate:obs.observationTimestamp]
				  forKey:@"field_date_observation[0][value][date]"];
	[obsDateFormatter setDateFormat:@"kk:mm"];
	[arguments setObject:[obsDateFormatter stringFromDate:obs.observationTimestamp]
				  forKey:@"field_date_observation[0][value][time]" ];
						  
#ifdef DEBUG
	[arguments setObject:@"Fulvous Whistling-Duck [nid:122]" forKey:@"field_taxon_ref[0][nid][nid]"];
	[arguments setObject:@"8" forKey:@"taxonomy[1]"];
	NSLog(@"#################\nWarning: I'm using dummy data\n");
#endif
	
	NSString *stringForBody = [self multipartMIMEStringWithDictionary:arguments];

	RKLog(@"**********");
	RKLog(@"%@", stringForBody);
	RKLog(@"**********");
	postRequest.HTTPBody = [stringForBody dataUsingEncoding:NSUTF8StringEncoding];
	[postRequest setValue:[NSString stringWithFormat:@"%d", postRequest.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
	
	RKLog(@"request %@ headers %@", postRequest, postRequest.allHTTPHeaderFields);
	
	return postRequest;
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
