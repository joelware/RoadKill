//
//  RKObservationSubmission.m
//  RoadKill
//
//  Created by Hal Mueller on 10/9/10.
//

#import "RKObservation.h"


@implementation RKObservation

@synthesize taxonomy;
@synthesize formIdConfidence;
@synthesize street;
@synthesize freeText;
@synthesize observationDate;
@synthesize decayDurationHours;
@synthesize observerName;

- (void)dealloc
{
    self.formIdConfidence = nil;
    self.street = nil;
    self.observationDate = nil;
    self.observerName = nil;
	
    [super dealloc];
}

+ (RKObservation *)dummyObservation
{
	RKObservation *result = [[[[self class] alloc] init] autorelease];
	result.taxonomy = 5;
	result.freeText = @"TEST";
	result.formIdConfidence = @"100% Certain";
	result.street = @"Middle Road";
	result.observationDate = [NSDate date];
	result.decayDurationHours = 1;
	result.observerName = @"Loudon Wainwright III";
	return result;
}

@end
