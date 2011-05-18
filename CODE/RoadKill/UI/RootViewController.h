//
//  RootViewController.h
//  RoadKill
//
//  Created by Pamela on 11/1/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file


	//@class Observation;


@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
		//Apple sample code tends to not use a managed object ivar in the rootViewController
		//Observation *observation_;
	UIView *headerView_; //for IB
	
	NSIndexPath * selectedSpeciesIndexPath_;
	
	NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

	//@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) NSIndexPath * selectedSpeciesIndexPath;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)addObservation:(id)sender;



@end
