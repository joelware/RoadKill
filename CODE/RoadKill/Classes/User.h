//
//  User.h
//  RoadKill
//
//  Created by Pamela on 10/13/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Observation;

@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet* observations;

@end


@interface User (CoreDataGeneratedAccessors)
- (void)addObservationsObject:(Observation *)value;
- (void)removeObservationsObject:(Observation *)value;
- (void)addObservations:(NSSet *)value;
- (void)removeObservations:(NSSet *)value;

@end

