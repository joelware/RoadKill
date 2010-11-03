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

@interface RKCROSSession ()
+ (ASIHTTPRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
- (ASIHTTPRequest *)formTokenRequest;
- (void)obtainFormToken;
+ (NSURL *)baseURLForWildlifeServer;
- (BOOL)extractFormTokenFromReceivedString;
- (BOOL)receivedStringShowsSuccessfulSubmission;
- (NSString *)observationIDFromResponseHeaders:(NSDictionary *)headers;
@end

@implementation RKCROSSession

@synthesize observation;
@synthesize asiHTTPRequest;
@synthesize sessionState;
@synthesize formToken;
@synthesize username;
@synthesize password;
@synthesize isAsynchronous;

NSString *RKCROSSessionSucceededNotification = @"RKCROSSessionSucceededNotification";
NSString *RKCROSSessionFailedNotification = @"RKCROSSessionFailedNotification";

- (id)init
{
	if (self = [super init]) {
		sessionState = RKCROSSessionConnecting;
	}
	return self;
}

- (void)dealloc
{
    self.observation = nil;
    self.asiHTTPRequest = nil;
	self.formToken = nil;
    [super dealloc];
}

+ (ASIHTTPRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password
{
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										   host:RKWebServer 
										   path:@"/california/node"] autorelease];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.shouldRedirect = NO;
	NSMutableDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
									  username, @"name",
									  password, @"pass",
									  @"Log in", @"op",
									  @"user_login_block", @"form_id",
									  nil];
	[arguments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		RKLog(@"%@ %@", key, obj);
		[request setPostValue:obj forKey:key];
	}];
	
	return request;
}

- (ASIFormDataRequest *)observationSubmissionRequest
{
	// FIXME: this submits only the bare minimum required form info
	if (![self.observation isValidForSubmission]) {
		RKLog(@"observation %@ not valid for submission");
		NSAssert(NO, @"observation not valid for submission");
		return nil;
	}
	NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
										   host:RKWebServer 
										   path:@"/california/node/add/roadkill"] autorelease];
	//	  NSURL *url = [[[NSURL alloc] initWithScheme:@"http" 
	//			       host:@"www.sailwx.info"
	//			       path:@"/test/roadkill.php"] autorelease];
	
	ASIFormDataRequest *postRequest = [ASIFormDataRequest requestWithURL:url];
	postRequest.shouldRedirect = NO;
	NSMutableDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
									  self.observation.species.speciesCategory.code, @"taxonomy[1]",
									  self.observation.species.commonName, @"field_taxon_ref[0][nid][nid]",
									  self.observation.freeText, @"field_taxon_freetext[0][value]",
									  self.formToken, @"form_token", 
									  self.observation.formIDConfidence, @"field_id_confidence[value]",
									  self.observation.street, @"field_geography[0][street]", 
									  self.observation.decayDurationHours, @"field_decay_duration",
									  self.observation.observerName, @"field_observer[0][value]", 
									  self.observation.latitude, @"field_geography[0][locpick][user_latitude]",
									  self.observation.longitude, @"field_geography[0][locpick][user_longitude]",
									  @"roadkill_node_form", @"form_id",
									  @"", @"changed",
									  @"", @"form_build_id",
									  @"test log message Seattle iPhone Team",	@"log", 
									  @"Save", @"op",
									  nil];
	[arguments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		RKLog(@"%@ %@", key, obj);
		if (obj)
			[postRequest setPostValue:obj forKey:key];
	}];
	
	NSDateFormatter *obsDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[obsDateFormatter setDateFormat:@"YYYY-MM-dd"];
	[postRequest setPostValue:[obsDateFormatter stringFromDate:self.observation.observationTimestamp]
					   forKey:@"field_date_observation[0][value][date]"];
	[obsDateFormatter setDateFormat:@"kk:mm"];
	[postRequest setPostValue:[obsDateFormatter stringFromDate:self.observation.observationTimestamp]
					   forKey:@"field_date_observation[0][value][time]" ];
	
	NSString *demoImagePathname = [[NSBundle mainBundle] pathForResource:@"demoSkunk" ofType:@"jpg"];
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

- (void)authenticateWithUsername:(NSString *)theUsername password:(NSString *)thePassword
{
	ASIHTTPRequest *request = [[self class] authenticationRequestWithUsername:theUsername
																	 password:thePassword];
	request.delegate = self;
	[request startAsynchronous];
}

- (ASIHTTPRequest *)formTokenRequest
{
	NSURL *formTokenURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/california/node/add/roadkill",
												[[self class] baseURLForWildlifeServer]]];
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
	
	NSRange tokenFormElementRange = [self.asiHTTPRequest.responseString rangeOfString:@"<input type=\"hidden\" name=\"form_token\".*>"
																			  options:NSRegularExpressionSearch];
	if (tokenFormElementRange.length > 0) {
		NSScanner *scanner = [NSScanner scannerWithString:[self.asiHTTPRequest.responseString substringWithRange:tokenFormElementRange]];
		[scanner scanUpToString:@"value=\"" intoString:NULL];
		[scanner scanUpToString:@"\"" intoString:NULL];
		scanner.scanLocation++;
		NSString *theToken;
		[scanner scanUpToString:@"\"" intoString:&theToken];
		self.formToken = theToken;
		return YES;
	}
	RKLog(@"form token not found");
	return NO;
}

+ (RKCROSSession *)submissionForObservation:(Observation *)report
							   withUsername:(NSString *)theUsername
								   password:(NSString *)thePassword
									  start:(BOOL)startNow
{
	RKCROSSession *result = [[[self alloc] init] autorelease];
	result.observation = report;
	result.username = theUsername;
	result.password = thePassword;
	if (startNow) {
		[result startAsynchronously];
	}
	RKLog(@"%@", result);
	return result;
}

- (void)startAsynchronously
{
	LogMethod();
	[self beginTransactionAsynchronously:YES];
}

- (void)startSynchronously
{
	LogMethod();
	[self beginTransactionAsynchronously:NO];
}

- (void)cancel
{
	LogMethod();
	[self.asiHTTPRequest cancel];
}

/*
 
 Asynchronous:
 Use multiple methods.
 Start with finished report.
 Keep NSSet of active async requests.
 Launch authentication request.
 If that succeeds, launch form token request (from -requestFinished:).
 If that succeeds, launch submission request (from -requestFinished:).
 If that succeeds, mark observation as done.
 
 Synchronous:
 Use one method, sequence of calls.
 Start with finished report.
 Launch authentication request.
 Check error result, proceed to form token request.
 Check error result, proceed to submissions request.
 Check error result, mark as done.
 
 */

- (BOOL)beginTransactionAsynchronously:(BOOL)async
{
	LogMethod();
	self.isAsynchronous = async;
	
	self.asiHTTPRequest = [[self class] authenticationRequestWithUsername:RKTestUsername
																 password:RKCorrectTestPassword];
	self.sessionState = RKCROSSessionConnecting;
	
	if (self.isAsynchronous) {
		self.asiHTTPRequest.delegate = self;
		[self.asiHTTPRequest startAsynchronous];
		return YES;
	}
	else {
		RKLog(@"sending authentication request");
		[self.asiHTTPRequest startSynchronous];
		if (![self.asiHTTPRequest error]) {
			self.sessionState = RKCROSSessionAuthenticated;
			self.asiHTTPRequest = [self formTokenRequest];
			RKLog(@"sending form token request");
			[self.asiHTTPRequest startSynchronous];
			if (![self.asiHTTPRequest error]) {
				if ([self extractFormTokenFromReceivedString]) {
					self.sessionState = RKCROSSessionFormTokenObtained;
					self.asiHTTPRequest = [self observationSubmissionRequest];
					self.sessionState = RKCROSSessionObservationSubmitted;
					RKLog(@"sending submission request");
					[self.asiHTTPRequest startSynchronous];
					if (![self.asiHTTPRequest error]) {
						NSString *theObservationID = [self observationIDFromResponseHeaders:self.asiHTTPRequest.responseHeaders];
						if (theObservationID) {
							RKLog(@"%d %@", asiHTTPRequest.responseStatusCode, asiHTTPRequest.responseHeaders);
							self.observation.observationID = theObservationID;
							self.sessionState = RKCROSSessionObservationComplete;
							self.observation.sentStatus = kRKComplete;
							[[NSNotificationCenter defaultCenter] postNotificationName:RKCROSSessionSucceededNotification
																				object:self];
							NSError *error = nil;
							if (![self.observation.managedObjectContext save:&error]) {
								/*
								 Replace this implementation with code to handle the error appropriately.
								 
								 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
								 */
								RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
								abort();
							}
							return YES;
						}
						else {
							RKLog(@"observation submission shows unsuccessful submission");
							[[NSNotificationCenter defaultCenter] postNotificationName:RKCROSSessionFailedNotification
																				object:self];
						}
					}
					[[NSNotificationCenter defaultCenter] postNotificationName:RKCROSSessionFailedNotification
																		object:self];
					RKLog(@"observation submission request failed");
					RKLog(@"%d %@", asiHTTPRequest.responseStatusCode, asiHTTPRequest.responseHeaders);
				}
				else {
					RKLog(@"form token response contained no token");
				}
			}
			else {
				RKLog(@"form token request failed");
			}
		}
	}
	return NO;
}

- (BOOL)receivedStringShowsSuccessfulSubmission
{
	/* upon success, the page contains this text:
	 <div class="messages status">
	 Observation <em>roadkill/review</em> has been created.</div>
	 */
	RKLog(@"response string %@", self.asiHTTPRequest.responseString);
	NSRange searchResults = [self.asiHTTPRequest.responseString rangeOfString:@"Observation <em>roadkill/review</em> has been created."];
	return (searchResults.location != NSNotFound);
}

- (NSString *)observationIDFromResponseHeaders:(NSDictionary *)headers
{
	RKLog(@"response headers %@", headers);
	NSString *serverLocationString = [headers objectForKey:@"Location"];
	RKLog(@"location %@", serverLocationString);
	return [[serverLocationString componentsSeparatedByString:@"/"] lastObject];
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)requestReceivedResponseHeaders:(ASIHTTPRequest *)request
{
	LogMethod();
	RKLog(@"%d %@", request.responseStatusCode, request.responseHeaders);
	if (self.sessionState == RKCROSSessionObservationSubmitted) {
		if (request.responseStatusCode == 302) {
			self.observation.observationID = [self observationIDFromResponseHeaders:request.responseHeaders];
		}
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	LogMethod();
	NSAssert(self.observation, @"observation cannot be null");
	switch (self.sessionState) {
		case RKCROSSessionConnecting:
			self.sessionState = RKCROSSessionAuthenticated;
			if (self.isAsynchronous) {
				self.asiHTTPRequest = [self formTokenRequest];
				self.asiHTTPRequest.delegate = self;
				[self.asiHTTPRequest startAsynchronous];
			}
			break;
		case RKCROSSessionAuthenticated:
			if ([self extractFormTokenFromReceivedString]) {
				self.sessionState = RKCROSSessionFormTokenObtained;
				self.asiHTTPRequest = [self observationSubmissionRequest];
				self.asiHTTPRequest.delegate = self;
				RKLog(@"authenticated headers %@", self.asiHTTPRequest.responseHeaders);
				self.sessionState = RKCROSSessionObservationSubmitted;
				self.observation.sentStatus = kRKQueued;
				[self.asiHTTPRequest startAsynchronous];
			}
			break;
		case RKCROSSessionObservationSubmitted:
			RKLog(@"final headers %@", self.asiHTTPRequest.responseHeaders);
			if ([self receivedStringShowsSuccessfulSubmission] ||
				[self observationIDFromResponseHeaders:request.responseHeaders]) {
				self.sessionState = RKCROSSessionObservationComplete;
				RKLog(@"observation successfully submitted");
				self.observation.sentStatus = kRKComplete;
				NSError *error = nil;
				if (![self.observation.managedObjectContext save:&error]) {
					/*
					 Replace this implementation with code to handle the error appropriately.
					 
					 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
					 */
					RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
					abort();
				}
				[[NSNotificationCenter defaultCenter] postNotificationName:RKCROSSessionSucceededNotification
																	object:self];
			}
			else {
				self.sessionState = RKCROSSessionAuthenticated;
				RKLog(@"observation failed");
				[[NSNotificationCenter defaultCenter] postNotificationName:RKCROSSessionFailedNotification
																	object:self];
			}
			break;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	LogMethod();
	[[NSNotificationCenter defaultCenter] postNotificationName:RKCROSSessionFailedNotification
														object:self];
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
