// 
//  Species.m
//  RoadKill
//
//  Created by Pamela on 10/17/10.
//  Copyright 2010 Pamela DeBriere. All rights reserved.
//

#import "Species.h"

#import "Observation.h"
#import "SpeciesCategory.h"
#import "RKConstants.h"

@implementation Species 

@dynamic nidCode;
@dynamic latinName;
@dynamic commonName;
@dynamic speciesCategory;
@dynamic observations;

+ (Species *)findOrCreateSpeciesWithCommonName:(NSString *)theCommonName
									 latinName:(NSString *)theLatinName
									   nidCode:(NSString *)theNidCode
											   inContext:(NSManagedObjectContext *)moc
{
	NSDictionary *predicateVariables = [NSDictionary dictionaryWithObject:theLatinName
																   forKey:@"NAME"];
	NSPredicate *localPredicate = [[NSPredicate predicateWithFormat:@"name == $NAME"]
								   predicateWithSubstitutionVariables:predicateVariables];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	fetchRequest.entity = 
	[NSEntityDescription entityForName:RKSpeciesCategoryEntity inManagedObjectContext:moc];
	fetchRequest.predicate = localPredicate;
	
	NSError *error = nil;
	NSArray *matchingSpeciesArray = [moc executeFetchRequest:fetchRequest error:&error];
	NSAssert2(1 >= matchingSpeciesArray.count, @"found too many species entries for Latin name %@ (%d found)",
			  theLatinName, matchingSpeciesArray.count);
	if (1 == matchingSpeciesArray.count)
		return [matchingSpeciesArray objectAtIndex:0];
	
	Species *theSpecies = [NSEntityDescription insertNewObjectForEntityForName:RKSpeciesEntity
														inManagedObjectContext:moc];
	theSpecies.commonName = theCommonName;
	theSpecies.latinName = theLatinName;
	theSpecies.nidCode = theNidCode;
	return theSpecies;
}

@end
