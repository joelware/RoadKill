	// 
	//  Observation.m
	//  RoadKill
	//
	//  Created by Hal Mueller on 10/12/10.
	//

#import "Observation.h"

#import "Species.h"
#import "SpeciesCategory.h"
#import "State.h"
#import "User.h"
#import "RKConstants.h"

@implementation Observation 

@dynamic formIDConfidence;
@dynamic sentStatus;
@dynamic observerName;
@dynamic longitude;
@dynamic decayDurationHours;
@dynamic street;
@dynamic latitude;
@dynamic observationID;
@dynamic freeText;
@dynamic observationTimestamp;
@dynamic state;
@dynamic species;
@dynamic speciesCategory;
@dynamic user;

+ (Observation *)addObservationInContext:(NSManagedObjectContext *)moc
{
	Observation *result = (Observation *)[NSEntityDescription insertNewObjectForEntityForName:RKObservationEntity
																	   inManagedObjectContext:moc];
	result.observationTimestamp = [NSDate date];
	result.decayDurationHours = [NSNumber numberWithUnsignedInt:0];
	return result;
}

- (void)markAsTestObservation
{
	self.freeText = @"TEST";
	self.formIDConfidence = @"100% Certain";
	self.street = @"Middle Road";
	self.observerName = @"Loudon Wainwright III";
}

@end
