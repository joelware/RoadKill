//
//  WebAPITestCase.m
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//
//  Note: OCUnit runs synchronously, without a run loop. Asynchronous web transactions 
//  will fail in OCUnit. Construct the API, and the unit tests, so that all pieces can
//  be tested using NSURLConnection's sendSynchronousRequest:returningResponse:error:.
//  

#import "WebAPITestCase.h"
#import "RKConstants.h"
#import "RKCROSSession.h"

@implementation WebAPITestCase


- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
	STAssertFalse((1+1)==3, @"Compiler isn't feeling well today :-(" );
	
}

- (void) testTaxonomyReference
{
	NSURL *duckURL = [[[NSURL alloc] initWithScheme:@"http" 
											   host:RKTestServer 
											   path:@"/california/nodereference/autocomplete/field_taxon_ref/duck"]
					  autorelease];
	NSError *error;
	NSString *results = [NSString stringWithContentsOfURL:duckURL
												 encoding: NSUTF8StringEncoding 
													error:&error];
	STAssertNotNil(results, @"duck download returned error %d %@ %@",
				   error.code, error.localizedDescription, error.localizedFailureReason);
	STAssertTrue(results.length , @"duck download returned empty string");
}

- (void)testSessionAuthentication
{
	NSMutableURLRequest *request = [RKCROSSession authenticationRequestWithUsername:RKTestUsername
																		   password:RKCorrectTestPassword];
	RKCROSSession *session = [[[RKCROSSession alloc] init] autorelease];
	
	NSHTTPURLResponse *response;
	NSError *error;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&error];
	// FIXME: we're relying on the connection's delegate methods in order to get correct behavior,
	// but sendSynchronousRequest doesn't let us provide a delegate. Synchronous testing of the
	// web API is doomed to failure.
	
	STAssertTrue(response.statusCode == 302, @"status code %d", response.statusCode);
	STAssertNotNil(responseData, @"responseData");
	STAssertTrue(responseData.length > 0, @"responseData length %d", responseData.length);
	
	STAssertNoThrow([session doSomethingWithResponse:response], @"doSomethingWithResponse");
	STAssertNoThrow(session.receivedData = [responseData mutableCopy], @"copy");
//	STAssertNoThrow([session connectionDidFinishLoading:nil], @"connectionDidFinishLoading");
}

- (void)testObtainFormToken
{
	NSMutableURLRequest *request = [RKCROSSession authenticationRequestWithUsername:RKTestUsername
																		   password:RKCorrectTestPassword];
	RKCROSSession *session = [[[RKCROSSession alloc] init] autorelease];
	
	NSHTTPURLResponse *response;
	NSError *error;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request
												 returningResponse:&response
															 error:&error];
	STAssertTrue(responseData.length > 0, @"responseData length %d", responseData.length);
	
	NSMutableURLRequest *tokenRequest = [session formTokenRequest];
	NSData *tokenRequestData = [NSURLConnection sendSynchronousRequest:tokenRequest
													 returningResponse:&response
																 error:&error];
	STAssertTrue(tokenRequestData.length > 0, @"tokenRequestData length %d %@", tokenRequestData.length, error.localizedDescription);
}
@end
