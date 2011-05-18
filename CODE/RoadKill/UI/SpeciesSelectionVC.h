//
//  SpeciesSelectionVC.h
//  RoadKill
//
//  Created by Pamela on 10/31/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//search code based on Apple's TableSearch
	//and http://blog.originalfunction.com/index.php/2010/02/uitableviewcontroller-with-uisearchdisplaycontroller-for-core-data/

	//#import are found in the Prefix file


@class Observation;
@class Species;

@interface SpeciesSelectionVC : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
{
	UIView *headerView_; //for IB
	UIButton *button_;
	UISearchBar *searchBar_;
	
	Observation *observation_;
	Species *species_;
		
	NSIndexPath * lastIndexPath_;
	NSString *selectedSpeciesString_;
	NSString *selectedCategoryString_;
	
    UIViewController *observationEntryVC;

	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;
	
		// The content filtered as a result of a search.
	NSArray	*filteredListContent_;	
		
		// The saved state of the search UI if a memory warning removed the view.
    NSString *savedSearchTerm_;
    BOOL searchWasActive_;
	BOOL clearTheList_;
}

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) Species *species;
@property (nonatomic, retain) NSIndexPath * lastIndexPath;
@property (nonatomic, retain) NSString *selectedSpeciesString;
@property (nonatomic, retain) NSString *selectedCategoryString;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic) BOOL clearTheList;
@property (nonatomic, retain) UIViewController *observationEntryVC;

- (IBAction)speciesWriteIn:(id)sender;


@end

