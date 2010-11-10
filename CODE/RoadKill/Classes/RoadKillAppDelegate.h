//
//  RoadKillAppDelegate.h
//  RoadKill
//
//  Created by Joel Ware on 9/27/10.
//  Copyright University of Washington 2010. All rights reserved.
//

	//#import are found in the Prefix file


@interface RoadKillAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;

	NSMutableSet *activeWebTransactions;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, copy) NSMutableSet *activeWebTransactions;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (void)populateInitialDatastoreIfNeeded;

// User Defaults

extern NSString *RKIsFirstLaunchKey;

@end

