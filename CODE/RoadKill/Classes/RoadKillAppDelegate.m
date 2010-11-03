//
//  RoadKillAppDelegate.m
//  RoadKill
//
//  Created by Joel Ware on 9/27/10.
//  Copyright University of Washington 2010. All rights reserved.
//

#import "RoadKillAppDelegate.h"
#import "RootViewController.h"

#import "RKConstants.h"
#import "RKCROSSession.h"
#import "Observation.h"
#import "ObservationEntryController.h"
#import "SpeciesCategory.h"
#import "Species.h"

#import "ASIHTTPRequest.h"
#import "CSVParser.h"

@implementation RoadKillAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize activeWebTransactions;

NSString *RKIsFirstLaunchKey = @"isFirstLaunch";

#pragma mark -
#pragma mark Application lifecycle

- (void)initializeDefaults {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:RKIsFirstLaunchKey];

	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}	

- (id)init
{
    if ((self = [super init])) {
        activeWebTransactions = [[NSMutableSet set] retain];
		[self initializeDefaults];
    }
    return self;
}

- (void)awakeFromNib {    
 
    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

	[self populateInitialDatastoreIfNeeded];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(noteDeactivatedTransaction:)
												 name:RKCROSSessionSucceededNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(noteDeactivatedTransaction:)
												 name:RKCROSSessionFailedNotification
											   object:nil];
	[[NSUserDefaults standardUserDefaults] setBool:NO
											forKey:RKIsFirstLaunchKey];
											
    UIViewController *entryVC = [[ObservationEntryController alloc] initWithNibName:@"ObservationEntryController" 
                                                                              bundle:nil];
    [navigationController pushViewController:entryVC animated:YES];
                                                                          
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[[NSUserDefaults standardUserDefaults] synchronize];

    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self.activeWebTransactions enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		[obj cancel];
	}];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"RoadKill" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"RoadKill.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark -
#pragma mark datastore setup
- (void)handleParsedSpeciesInfo:(NSDictionary*)theRecord
{
	LogMethod();
	RKLog(@"theRecord is %@", theRecord);
	RKLog(@"the category is %@", [theRecord objectForKey:kCSVHeaderCategory]);

	SpeciesCategory *category = [SpeciesCategory speciesCategoryWithName:[theRecord objectForKey:kCSVHeaderCategory]
															   inContext:self.managedObjectContext];
	
	//Species *species = 
	[Species findOrCreateSpeciesWithCommonName:[theRecord objectForKey:kCSVHeaderCommon]
									 latinName:[theRecord objectForKey:kCSVHeaderLatin]
									   nidCode:[theRecord objectForKey:kCSVHeaderNID]
							   speciesCategory:category
									 inContext:self.managedObjectContext];
}

- (void)startAsynchronousLoadOfSpeciesDatabase
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://www.wildlifecrossing.net/california/files/xing/CA-taxa.csv"]];
	request.delegate = self;
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSError *error;
	RKLog(@"MOC status: %d registered objects", self.managedObjectContext.registeredObjects.count);
		//RKLog(@"MOC status - the registered objects descriptions: %@ ", self.managedObjectContext.registeredObjects.description);

	CSVParser *speciesParser =
	[[[CSVParser alloc]
	  initWithString:request.responseString
	  separator:@","
	  hasHeader:YES
	  fieldNames:
	  [NSArray arrayWithObjects:
	   kCSVHeaderNID, kCSVHeaderCategory, kCSVHeaderCommon, kCSVHeaderLatin, nil
	   ]]
	 autorelease];
	[speciesParser parseRowsForReceiver:self selector:@selector(handleParsedSpeciesInfo:)];
	RKLog(@"MOC status: %d registered objects", self.managedObjectContext.registeredObjects.count);

	[self.managedObjectContext save:&error];
}

- (void)putSpeciesCategoriesIntoDatastore
{
	[SpeciesCategory findOrCreateSpeciesCategoryWithName:@"Amphibian"
											 codeInteger:8
											   inContext:self.managedObjectContext];
	[SpeciesCategory findOrCreateSpeciesCategoryWithName:@"Bird"
											 codeInteger:6
											   inContext:self.managedObjectContext];
	[SpeciesCategory findOrCreateSpeciesCategoryWithName:@"Mammal (Large)"
											 codeInteger:3
											   inContext:self.managedObjectContext];
	[SpeciesCategory findOrCreateSpeciesCategoryWithName:@"Mammal (Medium)"
											 codeInteger:4
											   inContext:self.managedObjectContext];
	[SpeciesCategory findOrCreateSpeciesCategoryWithName:@"Mammal (Small)"
											 codeInteger:5
											   inContext:self.managedObjectContext];
	[SpeciesCategory findOrCreateSpeciesCategoryWithName:@"Reptile"
											 codeInteger:7
											   inContext:self.managedObjectContext];
	
}

- (void)populateInitialDatastoreIfNeeded
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:RKIsFirstLaunchKey]) {
		[self putSpeciesCategoriesIntoDatastore];
		[self startAsynchronousLoadOfSpeciesDatabase];
	}
}

- (void)noteDeactivatedTransaction:(NSNotification *)notification
{
	LogMethod();
	[self.activeWebTransactions removeObject:notification.object];
}

- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

