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
#import "Species.h"

#import "ASIFormDataRequest.h"

#define kFormBoundaryString @"---------------------------1184049667376"
#define kURLResponseSWAGLength 1000

@implementation RKCROSSession

@synthesize connection;
@synthesize asiHTTPRequest;
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
    self.asiHTTPRequest = nil;
	self.receivedData = nil;
	
    [super dealloc];
}

- (void)setConnection:(NSURLConnection *)theConnection
{
    if (connection != theConnection) {
		[connection cancel];
        [connection release];
        connection = [theConnection retain];
    }
}

+ (ASIHTTPRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password
{
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										   host:RKWebServer 
										   path:@"/california/node"] autorelease];
	RKLog(@"requesting URL %@", url);
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.shouldRedirect = NO;
	NSMutableDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
									  username, @"name",
									  password, @"pass",
									  @"Log in", @"op",
									  @"user_login_block", @"form_id",
									  nil];
	[arguments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[request setPostValue:obj forKey:key];
	}];
	 
	return request;
}

- (ASIFormDataRequest *)observationSubmissionRequestForObservation:(Observation *)obs
{
	// FIXME: this submits only the bare minimum required form info
	if (![obs isValidForSubmission]) {
		RKLog(@"observation %@ not valid for submission");
		NSAssert(NO, @"observation not valid for submission");
		return nil;
	}
	NSAssert(self.formToken, @"formToken not set");
	
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										   host:RKWebServer 
										   path:@"/california/node/add/roadkill"] autorelease];
	//	  NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
	//			       host:@"www.sailwx.info"
	//			       path:@"/test/roadkill.php"] autorelease];
	
	ASIFormDataRequest *postRequest = [ASIFormDataRequest requestWithURL:url];
	NSMutableDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
									  obs.speciesCategory.code, @"taxonomy[1]",
									  obs.species.commonName, @"field_taxon_ref[0][nid][nid]",
									  obs.freeText, @"field_taxon_freetext[0][value]",
									  self.formToken, @"form_token", 
									  obs.formIDConfidence, @"field_id_confidence[value]",
									  obs.street, @"field_geography[0][street]", 
									  obs.decayDurationHours, @"field_decay_duration",
									  obs.observerName, @"field_observer[0][value]", 
									  obs.latitude, @"field_geography[0][locpick][user_latitude]",
									  obs.longitude, @"field_geography[0][locpick][user_longitude]",
									  @"roadkill_node_form", @"form_id",
									  @"", @"changed",
									  @"", @"form_build_id",
									  @"test log message Seattle iPhone Team",	@"log", 
									  @"Save", @"op",
									  nil];
	[arguments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (obj)
			[postRequest setPostValue:obj forKey:key];
	}];
	
	NSDateFormatter *obsDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[obsDateFormatter setDateFormat:@"YYYY-MM-dd"];
	[postRequest setPostValue:[obsDateFormatter stringFromDate:obs.observationTimestamp]
					   forKey:@"field_date_observation[0][value][date]"];
	[obsDateFormatter setDateFormat:@"kk:mm"];
	[postRequest setPostValue:[obsDateFormatter stringFromDate:obs.observationTimestamp]
					   forKey:@"field_date_observation[0][value][time]" ];

	NSString *demoImagePathname = [[NSBundle mainBundle] pathForResource:@"demoSkunk" ofType:@"jpg"];
	RKLog (@"demo image %@", demoImagePathname);
	[postRequest addFile:demoImagePathname forKey:@"files[field_image_0]"];
	[postRequest setPostValue:@"0" forKey:@"field_image[0][fid]"];
	[postRequest setPostValue:@"1" forKey:@"field_image[0][list]"];
	[postRequest setPostValue:@"0" forKey:@"field_image[0][_weight]"];
	
	return postRequest;
}

+ (NSURL *)baseURLForWildlifeServer
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", RKWebServer]];
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password
{
	ASIHTTPRequest *request = [[self class] authenticationRequestWithUsername:username
																		  password:password];
	request.delegate = self;
	[request startAsynchronous];
}

- (ASIHTTPRequest *)formTokenRequest
{
	LogMethod();
	NSURL *formTokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/california/node/add/roadkill",
												[[self class] baseURLForWildlifeServer]]];
	RKLog(@"%@", formTokenURL);
	ASIHTTPRequest *result = [ASIHTTPRequest requestWithURL:formTokenURL];
	return result;
}

- (void)obtainFormToken
{
	NSAssert((self.sessionState == RKCROSSessionAuthenticated), @"session not authenticated");
	self.asiHTTPRequest = [self formTokenRequest];
	self.asiHTTPRequest.delegate = self;
	[self.asiHTTPRequest startAsynchronous];
}

- (BOOL)extractFormTokenFromReceivedString
{
	//
	// sample response text:
	// <input type="hidden" name="form_token" id="edit-roadkill-node-form-form-token" value="014bed2bec533edbae01c14ebac6e174"  />
	//
	
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
	RKLog(@"form token not found");
	return NO;
}

- (BOOL)submitObservationReport:(Observation *)report
{
	LogMethod();
	NSAssert(self.sessionState = RKCROSSessionFormTokenObtained, @"need RKCROSSessionFormTokenObtained");
	// FIXME: the correct behavior would be to attempt to obtain a form token, not to die
	ASIHTTPRequest *reportSubmissionRequest = 
	[self observationSubmissionRequestForObservation:report];
	self.asiHTTPRequest = reportSubmissionRequest;
	reportSubmissionRequest.delegate = self;
	[reportSubmissionRequest startAsynchronous];
	self.sessionState = RKCROSSessionObservationSubmitted;
	return YES;
}

- (BOOL)receivedStringShowsSuccessfulSubmission
{
	/* upon success, the page contains this text:
	       <div class="messages status">
           Observation <em>roadkill/review</em> has been created.</div>
	 */
	NSRange searchResults = [self.receivedString rangeOfString:@"Observation <em>roadkill/review</em> has been created."];
	return (searchResults.location != NSNotFound);
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

#pragma mark -
#pragma mark ASIHTTPRequest delegate
- (void)requestStarted:(ASIHTTPRequest *)request
{
	LogMethod();
}
- (void)requestReceivedResponseHeaders:(ASIHTTPRequest *)request
{
	LogMethod();
	self.receivedData.length = 0;
	RKLog(@"%@", request.responseHeaders);
	RKLog(@"%@", request.responseCookies);
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	LogMethod();
	self.receivedString = request.responseString;
	switch (self.sessionState) {
		case RKCROSSessionConnecting:
			self.sessionState = RKCROSSessionAuthenticated;
			break;
		case RKCROSSessionAuthenticated:
			if ([self extractFormTokenFromReceivedString])
				self.sessionState = RKCROSSessionFormTokenObtained;
			break;
		case RKCROSSessionObservationSubmitted:
			if (self.receivedStringShowsSuccessfulSubmission)
				self.sessionState = RKCROSSessionObservationComplete;
			else 
				self.sessionState = RKCROSSessionAuthenticated;
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	LogMethod();
	switch (self.sessionState) {
		case RKCROSSessionConnecting:
			break;
		case RKCROSSessionAuthenticated:
			break;
		case RKCROSSessionObservationSubmitted:
			self.sessionState = RKCROSSessionAuthenticated;
			break;
	}
}

@end
