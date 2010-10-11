//
//  RKObservationSubmission.h
//  RoadKill
//
//  Created by Hal Mueller on 10/9/10.
//

#import <Foundation/Foundation.h>


@interface RKObservation : NSObject {
	// TODO: these are bare minimum fields needed for a test submission. Flesh out (heh) the Core Data model and convert to NSManagedObject/@dynamic
	NSUInteger taxonomy;
	NSString *formIdConfidence;
	NSString *freeText;
	NSString *street;
	NSDate *observationDate;
	NSUInteger decayDurationHours;
	NSString *observerName;
}

@property (nonatomic) NSUInteger taxonomy;
@property (nonatomic, copy) NSString *formIdConfidence;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *freeText;
@property (nonatomic, copy) NSDate *observationDate;
@property (nonatomic) NSUInteger decayDurationHours;
@property (nonatomic, copy) NSString *observerName;

+ (RKObservation *)dummyObservation;

@end