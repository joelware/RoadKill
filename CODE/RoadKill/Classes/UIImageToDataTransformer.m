//
//  UIImageToDataTransformer.m
//  RoadKill
//
//  Created by Pamela on 11/9/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//
//  from Apple sample code PhotoLocations

#import "UIImageToDataTransformer.h"


@implementation UIImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
	return [[[UIImage alloc] initWithData:value] autorelease];
}

@end
