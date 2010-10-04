//
//  WebAPITestCase.m
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//

#import "WebAPITestCase.h"


@implementation WebAPITestCase


- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
	STAssertFalse((1+1)==3, @"Compiler isn't feeling well today :-(" );
	
}


@end
