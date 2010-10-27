//
//  SpeciesCategory.h
//  RoadKill
//
//  Created by Pamela on 10/18/10.
//  Copyright 2010 Pamela DeBriere. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Observation;
@class Species;

@interface SpeciesCategory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSSet* observations;
@property (nonatomic, retain) NSSet* speciesMembers;


+ (SpeciesCategory *)findOrCreateSpeciesCategoryWithName:(NSString *)theName
											 codeInteger:(NSInteger)codeInteger
											   inContext:(NSManagedObjectContext *)moc;
+ (SpeciesCategory *)speciesCategoryWithName:(NSString *)theName
								   inContext:(NSManagedObjectContext *)moc;
@end


@interface SpeciesCategory (CoreDataGeneratedAccessors)
- (void)addObservationsObject:(Observation *)value;
- (void)removeObservationsObject:(Observation *)value;
- (void)addObservations:(NSSet *)value;
- (void)removeObservations:(NSSet *)value;

- (void)addSpeciesMembersObject:(Species *)value;
- (void)removeSpeciesMembersObject:(Species *)value;
- (void)addSpeciesMembers:(NSSet *)value;
- (void)removeSpeciesMembers:(NSSet *)value;

@end

