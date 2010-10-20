// 
//  SpeciesCategory.m
//  RoadKill
//
//  Created by Pamela on 10/18/10.
//

#import "SpeciesCategory.h"

#import "Observation.h"
#import "RKConstants.h"

@implementation SpeciesCategory 

@dynamic name;
@dynamic code;
@dynamic observations;

+ (SpeciesCategory *)findOrCreateSpeciesCategoryWithName:(NSString *)theName
											 codeInteger:(NSInteger)codeInteger
												 inContext:(NSManagedObjectContext *)moc
{
	NSString *searchName;
	
	NSDictionary *predicateVariables = [NSDictionary dictionaryWithObject:searchName
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
			  searchName, matchingCategories.count);
	if (1 == matchingCategories.count)
		return [matchingCategories objectAtIndex:0];
	
	SpeciesCategory *theCategory = [NSEntityDescription insertNewObjectForEntityForName:RKSpeciesCategoryEntity
														  inManagedObjectContext:moc];
	theCategory.name = theName;
	theCategory.code = [NSNumber numberWithInteger:codeInteger];
	return theCategory;
}

@end
