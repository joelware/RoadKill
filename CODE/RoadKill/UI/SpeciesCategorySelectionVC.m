	//
	//  SpeciesCategorySelectionVC.m
	//  RoadKill
	//
	//  Created by Pamela on 10/30/10.
	//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
	//

#import "SpeciesCategorySelectionVC.h"
#import "RKConstants.h"
#import "RoadKillAppDelegate.h"
#import "Observation.h"
#import "Species.h"
#import "SpeciesCategory.h"
#import "SpeciesSelectionVC.h"

@interface SpeciesCategorySelectionVC ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation SpeciesCategorySelectionVC

@synthesize observation = observation_;
@synthesize category = category_;
@synthesize lastIndexPath = lastIndexPath_;
@synthesize selectedCategoryString = selectedCategoryString_;
@synthesize managedObjectContext = managedObjectContext_, fetchedResultsController=fetchedResultsController_;
@synthesize observationEntryVC;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = @"Species Category";
}

/*
 - (void)viewWillAppear:(BOOL)animated 
 {
 [super viewWillAppear:animated];
 [self.tableView reloadData];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


	// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
		// Configure the cell...
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#if 1
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
	self.category = nil;
	self.category = (SpeciesCategory *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [self.category valueForKey:@"name"];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (self.selectedCategoryString != nil && self.selectedCategoryString == cell.textLabel.text) 
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else 
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}
#endif
#if 0
	//this doesn't seem to be working - use the other one
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
		//Apress Beginning iPhone 3 Chapter 9 - Project 09 Nav: see CheckListController files
	
	NSUInteger row = [indexPath row];
    NSUInteger oldRow = [self.lastIndexPath row];
	
	self.category = nil;
	self.category = (SpeciesCategory *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [self.category valueForKey:@"name"];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.accessoryType = (row == oldRow && self.lastIndexPath != nil) ? 
	UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;	
	
}
#endif


#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	SpeciesCategory *selectedObject = nil;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
	
		//TODO: is it not necessary to save the category?
		//Is it *only* necessary to save the selectedCategoryString (done further down here) because that's what's passed to SpeciesSelectionVC?
	
		//selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];		
	selectedObject = (SpeciesCategory *) [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	
	self.category = selectedObject;
	
		//http://stackoverflow.com/questions/974170/uitableview-having-problems-changing-accessory-when-selected
		//http://developer.apple.com/library/ios/#documentation/userexperience/conceptual/TableView_iPhone/ManageSelections/ManageSelections.html see listing 6-3  Managing a selection list—exclusive list
		//Apress Beginning iPhone 3 Chapter 9 - Project 09 Nav: see CheckListController files
	
		//Be sure the list is exclusive
	
	RKLog(@"BEFORE category selection: %@", self.selectedCategoryString);
	
	int newRow = [indexPath row];
    int oldRow = (self.lastIndexPath != nil) ? [self.lastIndexPath row] : -1;
    
    if (newRow != oldRow)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath]; 
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        self.lastIndexPath = indexPath;		
    }
	
		//remember the category selected so the next view will filter for species members of that category
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.lastIndexPath];
	
		//set the string so it can be passed to Preview
    self.selectedCategoryString = selectedCell.textLabel.text;
	
		//needed for checkmarks to be up to date
	[self.tableView reloadData];
	
	RKLog(@"AFTER category selection: %@", self.selectedCategoryString);
	
	/*
	 Save the managed object context when the row is tapped
	 */
	NSError *error = nil;
	if (![managedObjectContext_ save:&error]) 
	{
		
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
		//when a category is selected, create the SpeciesSelectionVC and get ready to push 
	SpeciesSelectionVC *nextViewController = [[SpeciesSelectionVC alloc] initWithNibName:@"SpeciesSelectionVC" bundle:nil];
	
		//pass the MOC to the nextViewController
	nextViewController.managedObjectContext = self.managedObjectContext;
	
		//pass the observation to the nextViewController
	nextViewController.observation = self.observation;
	
		//pass the selectedCategoryString to the next view
	nextViewController.selectedCategoryString = self.selectedCategoryString;
	
	if (nextViewController) 
	{
			//during testing, not using this right now
			// Set the view controller to return to
			// [newViewController setReturnToVC:self.observationEntryVC];
		
		[self.navigationController pushViewController:nextViewController animated:YES];
	}	
	[nextViewController release], nextViewController = nil;
	
}


 #pragma mark -
 #pragma mark Accessors
 
 - (void)setReturnToVC:(UIViewController *) viewController {
 self.observationEntryVC = viewController;
 [self.observationEntryVC retain];
 }
 

#pragma mark -
#pragma mark Fetched results controller
	//see Apress More iPhone 3 Development

- (NSFetchedResultsController *)fetchedResultsController 
{	
	if (fetchedResultsController_ != nil) 
	{
		return fetchedResultsController_;
	}
	
	/*
	 Set up the fetched results controller.
	 */
	
		// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:RKSpeciesCategoryEntity 
											  inManagedObjectContext:self.managedObjectContext ];
	[fetchRequest setEntity:entity];
	
		// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
		// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext  
																								  sectionNameKeyPath:nil 
																										   cacheName:@"Category"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
		//[aFetchedResultsController release], aFetchedResultsController = nil;
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	NSError *error = nil;
	if (![fetchedResultsController_ performFetch:&error]) 
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	return fetchedResultsController_;
}

#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
		// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
		// Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
		// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
		// For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	[observation_ release], observation_ = nil;
	[category_ release], category_ = nil;
	[lastIndexPath_ release], lastIndexPath_ = nil;
	[selectedCategoryString_ release], selectedCategoryString_ = nil;
	[managedObjectContext_ release], managedObjectContext_ = nil;
	[fetchedResultsController_ release], fetchedResultsController_ = nil;
	[self.observationEntryVC release]; self.observationEntryVC = nil;
	
	[super dealloc];
}


@end

