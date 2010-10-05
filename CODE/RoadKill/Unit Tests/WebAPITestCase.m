//
//  WebAPITestCase.m
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
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

@end
