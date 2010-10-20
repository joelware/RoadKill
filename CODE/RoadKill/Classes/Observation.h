//
//  Observation.h
//  RoadKill
//
//  Created by Hal Mueller on 10/12/10.
//

#import <CoreData/CoreData.h>

@class Species;
@class SpeciesCategory;
@class State;
@class User;

@interface Observation :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * formIDConfidence;
@property (nonatomic, retain) NSString * sentStatus;
@property (nonatomic, retain) NSString * observerName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * decayDurationHours;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * observationID;
@property (nonatomic, retain) NSString * freeText;
	//TODO: delete this once Hal has OK'd the new SpeciesCategory code
	//@property (nonatomic, retain) NSNumber * taxonomy;
	//TODO: also delete the taxonomy attribute from the data model graph
@property (nonatomic, retain) NSDate * observationTimestamp;
@property (nonatomic, retain) State * state;
@property (nonatomic, retain) Species * species;
@property (nonatomic, retain) SpeciesCategory * speciesCategory;
@property (nonatomic, retain) User * user;

+ (Observation *)dummyObservationInContext:(NSManagedObjectContext *)moc;

@end



