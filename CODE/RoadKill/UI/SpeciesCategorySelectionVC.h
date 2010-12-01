//
//  SpeciesCategorySelectionVC.h
//  RoadKill
//
//  Created by Pamela on 10/30/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file

@class SpeciesCategory;

@interface SpeciesCategorySelectionVC : UITableViewController <NSFetchedResultsControllerDelegate>
{
	SpeciesCategory *category_;

	NSIndexPath * lastIndexPath_;
	NSString *selectedCategoryString_;
	
    UIViewController *observationEntryVC;

	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic, retain) SpeciesCategory *category;
@property (nonatomic, retain) NSIndexPath * lastIndexPath;
@property (nonatomic, retain) NSString *selectedCategoryString;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIViewController *observationEntryVC;

- (void)setReturnToVC:(UIViewController *) viewController;

@end
