	// 
	//  Observation.m
	//  RoadKill
	//
	//  Created by Hal Mueller on 10/12/10.
	//

#import "Observation.h"

#import "Photo.h"
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
@dynamic photos;
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
	self.street = @"Middle of the Road";
	self.observerName = @"Loudon Wainwright III";

	// per Dave Waetjen's request 1 November:
	self.latitude = [NSNumber numberWithDouble:38.];
	self.longitude = [NSNumber numberWithDouble:-120.];
}

- (BOOL)isValidForSubmission
{
	if (!([self.sentStatus isEqualToString:kRKReady] ||
		  [self.sentStatus isEqualToString:kRKQueued])) {
		RKLog(@"status should be kRKReady in observation %@", self);
		return NO;
	}
	if (!self.species) {
		RKLog(@"species needed in observation %@", self);
		return NO;
	}
	return YES;
}

- (void)awakeFromInsert
{
	self.sentStatus = kRKNotReady;
	// per Dave Waetjen's request 1 November:
	self.latitude = [NSNumber numberWithDouble:38.];
	self.longitude = [NSNumber numberWithDouble:-120.];

}
@end
