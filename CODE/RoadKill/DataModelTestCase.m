//
//  DataModelTestCase.m
//  RoadKill
//
//  Created by Hal Mueller on 10/15/10.
//  Copyright 2010 Mobile Geographics. All rights reserved.
//

#import "DataModelTestCase.h"


@implementation DataModelTestCase

- (void)testTestFramework
{
    NSString *string1 = @"test";
    NSString *string2 = @"test";
    STAssertEquals(string1,
                   string2,
                   @"FAILURE");
    NSUInteger uint_1 = 4;
    NSUInteger uint_2 = 4;
    STAssertEquals(uint_1,
                   uint_2,
                   @"FAILURE");
}

- (void)setUp
{
//	STAssertNoThrow([CelestialBody addPlanetsToContext:self.managedObjectContext],
//					@"planet insertion failure");
//	STAssertNoThrow([CelestialBody addNavigationalStarsToContext:self.managedObjectContext],
//					@"star insertion failure");
//	
}

- (void)tearDown
{
}

- (void)testRKObObservationInsertion
{
//	STAssertNoThrow([CelestialBody addPlanetsToContext:self.managedObjectContext],
//					@"planet insertion failure");
//	STAssertNoThrow([CelestialBody addNavigationalStarsToContext:self.managedObjectContext],
//					@"star insertion failure");
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	NSMutableSet *allBundles = [[[NSMutableSet alloc] init] autorelease];
    [allBundles addObjectsFromArray:[NSBundle allBundles]];
    [allBundles addObjectsFromArray:[NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[allBundles allObjects]] retain];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *storePath = [self persistentStorePath];
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

- (NSString *)persistentStorePath
{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"CelestNavUnitTests.sqlite"];
}


@end
