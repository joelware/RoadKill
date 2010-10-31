//
//  SpeciesCategorySelectionVC.h
//  RoadKill
//
//  Created by Pamela on 10/30/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class Observation, SpeciesCategory;


@interface SpeciesCategorySelectionVC : UITableViewController <NSFetchedResultsControllerDelegate>
{
		//	Observation *observation_;
	SpeciesCategory *category_;
	
		// I'm not sure yet if I need this when I add the checkmark code
	NSMutableArray *categoryArray_;

	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
}

	//@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) SpeciesCategory *category;
@property (nonatomic, retain) NSMutableArray *categoryArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


@end
