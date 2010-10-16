// 
//  Observation.m
//  RoadKill
//
//  Created by Hal Mueller on 10/12/10.
//  Copyright 2010 Mobile Geographics. All rights reserved.
//

#import "Observation.h"

#import "State.h"
#import "User.h"

@implementation Observation 

@dynamic street;
@dynamic decayDurationHours;
@dynamic sentStatus;
@dynamic observerName;
@dynamic observationID;
@dynamic formIDConfidence;
@dynamic observationTimestamp;
@dynamic freeText;
@dynamic taxonomy;
@dynamic user;
@dynamic state;

	//+ (Observation *)dummyObservation
	//{
	//	Observation *result = 
	//	result.taxonomy = 5;
	//	result.freeText = @"TEST";
	//	result.formIdConfidence = @"100% Certain";
	//	result.street = @"Middle Road";
	//	result.observationDate = [NSDate date];
	//	result.decayDurationHours = 1;
	//	result.observerName = @"Loudon Wainwright III";
	//	return result;
	//}
	//
@end
