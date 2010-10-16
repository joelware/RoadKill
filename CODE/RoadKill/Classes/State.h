//
//  State.h
//  RoadKill
//
//  Created by Pamela on 10/13/10.
//  Copyright 2010 Pamela DeBriere. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Observation;

@interface State :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * protocol;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet* observations;

@end


@interface State (CoreDataGeneratedAccessors)
- (void)addObservationsObject:(Observation *)value;
- (void)removeObservationsObject:(Observation *)value;
- (void)addObservations:(NSSet *)value;
- (void)removeObservations:(NSSet *)value;

@end

