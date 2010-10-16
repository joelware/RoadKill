// 
//  Observation.m
//  RoadKill
//
//  Created by Hal Mueller on 10/12/10.
//

#import "Observation.h"

#import "State.h"
#import "User.h"
#import "RKConstants.h"

@implementation Observation 

@dynamic street;
@dynamic decayDurationHours;
@dynamic sentStatus;
@dynamic observerName;
@dynamic observationID;
@dynamic formIDConfidence;
@dynamic observationTimestamp;
@dynamic freeText;
@dynamic taxonomy;
@dynamic user;
@dynamic state;

+ (Observation *)dummyObservationInContext:(NSManagedObjectContext *)moc
{
	Observation *result = (Observation *)[NSEntityDescription insertNewObjectForEntityForName:RKObservationEntity
										  inManagedObjectContext:moc];
	result.taxonomy = [NSNumber numberWithUnsignedInt:5];
	result.freeText = @"TEST";
	result.formIDConfidence = @"100% Certain";
	result.street = @"Middle Road";
	result.observationTimestamp = [NSDate date];
	result.decayDurationHours = [NSNumber numberWithUnsignedInt:1];
	result.observerName = @"Loudon Wainwright III";
	return result;
}

@end
