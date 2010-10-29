// 
//  SpeciesCategory.m
//  RoadKill
//
//  Created by Pamela on 10/18/10.
//

#import "SpeciesCategory.h"

#import "Observation.h"
#import "Species.h"
#import "RKConstants.h"

@implementation SpeciesCategory 

@dynamic name;
@dynamic code;
@dynamic speciesMembers;


+ (SpeciesCategory *)findOrCreateSpeciesCategoryWithName:(NSString *)theName
											 codeInteger:(NSInteger)codeInteger
												 inContext:(NSManagedObjectContext *)moc
{
	NSDictionary *predicateVariables = [NSDictionary dictionaryWithObject:theName
																   forKey:@"NAME"];
	NSPredicate *localPredicate = [[NSPredicate predicateWithFormat:@"name == $NAME"]
								   predicateWithSubstitutionVariables:predicateVariables];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	fetchRequest.entity = 
	[NSEntityDescription entityForName:RKSpeciesCategoryEntity inManagedObjectContext:moc];
	fetchRequest.predicate = localPredicate;
	
	NSError *error = nil;
	NSArray *matchingCategories = [moc executeFetchRequest:fetchRequest error:&error];
	NSAssert2(1 >= matchingCategories.count, @"found too many species categories for name %@ (%d found)",
			  theName, matchingCategories.count);
	if (1 == matchingCategories.count)
		return [matchingCategories objectAtIndex:0];
	
	SpeciesCategory *theCategory = [NSEntityDescription insertNewObjectForEntityForName:RKSpeciesCategoryEntity
														  inManagedObjectContext:moc];
	theCategory.name = theName;
	theCategory.code = [NSNumber numberWithInteger:codeInteger];
	return theCategory;
}

// FIXME: these two methods have too much common code, should be consolidated somehow
+ (SpeciesCategory *)speciesCategoryWithName:(NSString *)theName
								   inContext:(NSManagedObjectContext *)moc
{
	// return the correct category, which must already exist in the datastore
	NSDictionary *predicateVariables = [NSDictionary dictionaryWithObject:theName
																   forKey:@"NAME"];
	NSPredicate *localPredicate = [[NSPredicate predicateWithFormat:@"name == $NAME"]
								   predicateWithSubstitutionVariables:predicateVariables];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	fetchRequest.entity = 
	[NSEntityDescription entityForName:RKSpeciesCategoryEntity inManagedObjectContext:moc];
	fetchRequest.predicate = localPredicate;
	
	NSError *error = nil;
	NSArray *matchingCategories = [moc executeFetchRequest:fetchRequest error:&error];
	NSAssert2(1 >= matchingCategories.count, @"found too many species categories for name %@ (%d found)",
			  theName, matchingCategories.count);
	NSAssert2(1 == matchingCategories.count, @"no species category for name %@ (%d found)",
			  theName, matchingCategories.count);
	return [matchingCategories objectAtIndex:0];
}

@end
