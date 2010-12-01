//
//  Photo.h
//  RoadKill
//
//  Created by Pamela on 11/9/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Observation;

@interface Photo :  NSManagedObject  
{
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) Observation * observation;

@end



