//
//  RootViewController.h
//  RoadKill
//
//  Created by Pamela on 11/1/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file


@class Observation;


@interface RootViewController : UITableViewController 
{
	Observation *testObservation_;
	
	NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) Observation *testObservation;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
