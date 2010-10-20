//
//  Species.h
//  RoadKill
//
//  Created by Pamela on 10/17/10.
//

#import <CoreData/CoreData.h>

@class Observation;

@interface Species :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * nidCode;
@property (nonatomic, retain) NSString * latinName;
@property (nonatomic, retain) NSString * commonName;
@property (nonatomic, retain) NSSet* observations;

+ (Species *)findOrCreateSpeciesWithCommonName:(NSString *)theCommonName
									 latinName:(NSString *)theLatinName
									   nidCode:(NSString *)theNidCode
									 inContext:(NSManagedObjectContext *)moc;
@end


@interface Species (CoreDataGeneratedAccessors)
- (void)addObservationsObject:(Observation *)value;
- (void)removeObservationsObject:(Observation *)value;
- (void)addObservations:(NSSet *)value;
- (void)removeObservations:(NSSet *)value;

@end

