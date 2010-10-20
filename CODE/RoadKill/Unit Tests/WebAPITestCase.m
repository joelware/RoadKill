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
//  URL's for some solutions to the async testing problem:
//      http://gist.github.com/506353
//      http://blog.clickablebliss.com/2006/02/08/asynchronous-unit-testing/
//      http://www.cocoabuilder.com/archive/xcode/247124-asynchronous-unit-testing.html
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
											   host:RKWebServer 
											   path:@"/california/nodereference/autocomplete/field_taxon_ref/duck"]
					  autorelease];
	NSError *error;
	NSString *results = [NSString stringWithContentsOfURL:duckURL
												 encoding: NSUTF8StringEncoding 
													error:&error];
	STAssertNotNil(results, @"duck download returned error %d %@ %@",
				   error.code, error.localizedDescription, error.localizedFailureReason);
	STAssertTrue((results.length > 0), @"duck download returned empty string");
	
	NSURL *wildcardURL = [[[NSURL alloc] initWithScheme:@"http" 
												   host:RKWebServer 
												   path:@"/california/nodereference/autocomplete/field_taxon_ref/"]
						  autorelease];
	NSString *wildcardResults = [NSString stringWithContentsOfURL:wildcardURL
												 encoding:NSUTF8StringEncoding
															error:&error];
	STAssertNotNil(wildcardResults, @"wildcard download returned error %d %@ %@",
				   error.code, error.localizedDescription, error.localizedFailureReason);
	STAssertTrue((wildcardResults.length >0), @"wildcard download returned empty string");
}

- (void)dontTestSessionAuthentication
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

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	NSMutableSet *allBundles = [[[NSMutableSet alloc] init] autorelease];
    [allBundles addObjectsFromArray:[NSBundle allBundles]];
    [allBundles addObjectsFromArray:[NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[allBundles allObjects]] retain];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [self persistentStorePath];
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

- (NSString *)persistentStorePath
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"WebAPIUnitTests.sqlite"];
}


@end
