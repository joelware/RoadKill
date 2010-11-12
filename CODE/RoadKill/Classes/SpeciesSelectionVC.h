//
//  SpeciesSelectionVC.h
//  RoadKill
//
//  Created by Pamela on 10/31/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file

@class Observation;
@class Species;

@interface SpeciesSelectionVC : UITableViewController <NSFetchedResultsControllerDelegate>
{
	UIView *headerView_;
		//UILabel *writeInLabel_;

	Observation *observation_;
	Species *species_;
		
	NSIndexPath * lastIndexPath_;
	NSString *selectedSpeciesString_;
	NSString *selectedCategoryString_;
	
	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic, retain) IBOutlet UIView *headerView;
	//@property (nonatomic, retain) IBOutlet UILabel *writeInLabel;
@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) Species *species;
@property (nonatomic, retain) NSIndexPath * lastIndexPath;
@property (nonatomic, retain) NSString *selectedSpeciesString;
@property (nonatomic, retain) NSString *selectedCategoryString;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (IBAction)speciesWriteInButton:(id)sender;


@end
