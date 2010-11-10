	//
	//  SpeciesSelectionVC.m
	//  RoadKill
	//
	//  Created by Pamela on 10/31/10.
	//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
	//

#import "SpeciesSelectionVC.h"
#import "RKConstants.h"
#import "RoadKillAppDelegate.h"
#import "Observation.h"
#import "Species.h"
#import "RootViewController.h"
	//#import "SpeciesCategorySelectionVC.h"

@interface SpeciesSelectionVC ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation SpeciesSelectionVC

@synthesize observation = observation_, species = species_;
@synthesize lastIndexPath = lastIndexPath_; 
@synthesize selectedSpeciesString = selectedSpeciesString_, selectedCategoryString = selectedCategoryString_;
@synthesize managedObjectContext = managedObjectContext_, fetchedResultsController=fetchedResultsController_;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem;
		//TODO: which title is better?
		//self.navigationItem.title = @"Species";
	self.navigationItem.title = self.selectedCategoryString;
	
		//NSLog(@"%@",[NSString stringWithFormat:@"I am adding this string:%@.", box.name]);
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
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
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
		// Configure the cell...
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{	
		//Apress Beginning iPhone 3 Chapter 9 - Project 09 Nav: see CheckListController files
	
	NSUInteger row = [indexPath row];
    NSUInteger oldRow = [self.lastIndexPath row];
	
	self.species = nil;
	self.species = (Species *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [self.species valueForKey:@"commonName"];
	
	cell.accessoryType = (row == oldRow && self.lastIndexPath != nil) ? 
    UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{		
		//http://stackoverflow.com/questions/974170/uitableview-having-problems-changing-accessory-when-selected
		//http://developer.apple.com/library/ios/#documentation/userexperience/conceptual/TableView_iPhone/ManageSelections/ManageSelections.html see listing 6-3  Managing a selection list—exclusive list
		//Apress Beginning iPhone 3 Chapter 9 - Project 09 Nav: see CheckListController files
	
		//Be sure the list is exclusive
	
		//RKLog(@"BEFORE species selection: %@", self.selectedSpeciesString);
	
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
	
		//remember the species selected
		//FIXME: need to persist this selection for the new observation
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.lastIndexPath];
    self.selectedSpeciesString = selectedCell.textLabel.text;
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
		//RKLog(@"AFTER species selection: %@", self.selectedSpeciesString);
	
		//push the next view controller when a category is selected
		//FIXME: what will the next view be? See note below.
	RootViewController *newViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	if (newViewController) 
	{
			//FIXME: the species selection is not persisted yet
			//FIXME: temporarily return to rootView per Gerard's plan?
			//[self.navigationController pushViewController:newViewController animated:YES];
	}	
	[newViewController release];
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
	
		//TODO: is this the best way to pass the MOC? Ideally I probably don't want to query the app delegate for the MOC?	
	if (managedObjectContext_ == nil) 
	{ 
		self.managedObjectContext = [(RoadKillAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
		// Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:RKSpeciesEntity 
											  inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	
		//create the predicate to filter by the chosen category
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"speciesCategory.name CONTAINS[cd] %@", self.selectedCategoryString];
	
		//http://stackoverflow.com/questions/2709768/nsfetchedresultscontroller-crashing-on-performfetch-when-using-a-cache
		//if the cache is not cleared, the app will crash with an error: "You have illegally mutated the NSFetchedResultsController's fetch request, its predicate, or its sort descriptor without either disabling caching or using +deleteCacheWithName:"
	[NSFetchedResultsController deleteCacheWithName:@"Species"];
	[fetchRequest setPredicate:predicate];
	
		// Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
		// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"commonName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext  
																								  sectionNameKeyPath:nil 
																										   cacheName:@"Species"];
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
	[species_ release], species_ = nil;
	[lastIndexPath_ release], lastIndexPath_ = nil;
	[selectedSpeciesString_ release], selectedSpeciesString_ = nil;
	[selectedCategoryString_ release], selectedCategoryString_ = nil;
	[managedObjectContext_ release], managedObjectContext_ = nil;
	[fetchedResultsController_ release], fetchedResultsController_ = nil;
    [super dealloc];
}


@end

