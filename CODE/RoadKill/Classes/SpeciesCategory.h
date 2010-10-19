//
//  SpeciesCategory.h
//  RoadKill
//
//  Created by Pamela on 10/18/10.
//  Copyright 2010 Pamela DeBriere. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Observation;

@interface SpeciesCategory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSSet* observations;

@end


@interface SpeciesCategory (CoreDataGeneratedAccessors)
- (void)addObservationsObject:(Observation *)value;
- (void)removeObservationsObject:(Observation *)value;
- (void)addObservations:(NSSet *)value;
- (void)removeObservations:(NSSet *)value;

@end

