//
//  Observation.h
//  RoadKill
//
//  Created by Hal Mueller on 10/12/10.
//  Copyright 2010 Mobile Geographics. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Observation :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSNumber * decayDurationHours;
@property (nonatomic, retain) NSString * observerName;
@property (nonatomic, retain) NSString * formIDConfidence;
@property (nonatomic, retain) NSDate * observationTimestamp;
@property (nonatomic, retain) NSString * freeText;
@property (nonatomic, retain) NSNumber * taxonomy;

//+ (Observation *)dummyObservation;

@end



