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

+ (Observation *)dummyObservationInContext:(NSManagedObjectContext *)moc
{
	Observation *result = (Observation *)[NSEntityDescription insertNewObjectForEntityForName:RKObservationEntity
																	   inManagedObjectContext:moc];
		
	SpeciesCategory *newSpeciesCategory = (SpeciesCategory *)[NSEntityDescription insertNewObjectForEntityForName:RKSpeciesCategoryEntity inManagedObjectContext:moc];
	
	result.speciesCategory = newSpeciesCategory;
	result.speciesCategory.code = [NSNumber numberWithUnsignedInt:5];	
	RKLog(@"CHECK: value for result.speciesCategory.code = %@", result.speciesCategory.code);
	
	result.freeText = @"TEST";
	result.formIDConfidence = @"100% Certain";
	result.street = @"Middle Road";
	result.observationTimestamp = [NSDate date];
	result.decayDurationHours = [NSNumber numberWithUnsignedInt:1];
	result.observerName = @"Loudon Wainwright III";
		
	return result;
}

@end
