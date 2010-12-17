	//
	//  SpeciesSelectionVC.m
	//  RoadKill
	//
	//  Created by Pamela on 10/31/10.
	//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
	//

	//search code based on Apple's TableSearch
	//and http://blog.originalfunction.com/index.php/2010/02/uitableviewcontroller-with-uisearchdisplaycontroller-for-core-data/


#import "SpeciesSelectionVC.h"
#import "RKConstants.h"
#import "RoadKillAppDelegate.h"
#import "Observation.h"
#import "Species.h"
#import "SpeciesCategory.h"
#import "SpeciesCategorySelectionVC.h"
#import "RootViewController.h"
#import "SpeciesWriteInVC.h"
#import "PreviewViewController.h"
#import "PickerViewController.h"


	//a category to prepare for the index table view style (using alphabetical headers and fast index scroller)
	//http://stackoverflow.com/questions/1741093/how-to-use-the-first-character-as-a-section-name/1741131#1741131
@interface Species (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName;
@end

@implementation Species (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName 
{
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"commonName"] uppercaseString];
	
		// support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
	
		// OR no UTF-16 support:
		//NSString *stringToReturn = [aString substringToIndex:1];
	
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}
@end

@interface SpeciesSelectionVC ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation SpeciesSelectionVC

@synthesize headerView = headerView_;
@synthesize button = button_;
@synthesize searchBar = searchBar_;
@synthesize observation = observation_, species = species_;
@synthesize lastIndexPath = lastIndexPath_; 
@synthesize selectedSpeciesString = selectedSpeciesString_, selectedCategoryString = selectedCategoryString_;
@synthesize managedObjectContext = managedObjectContext_, fetchedResultsController=fetchedResultsController_;
@synthesize filteredListContent = filteredListContent_, savedSearchTerm = savedSearchTerm_, searchWasActive = searchWasActive_;
@synthesize clearTheList = clearTheList_;
@synthesize observationEntryVC;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.navigationItem.title = self.selectedCategoryString;
	
		//configure the clear button
	UIBarButtonItem *clearSelectionButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" 
																			 style:UIBarButtonItemStyleBordered 
																			target:self 
																			action:@selector(clearSelection:)];
	self.navigationItem.rightBarButtonItem = clearSelectionButton;
	[clearSelectionButton release];
	
		//start in this mode so checkmarks may be made
	self.clearTheList = NO;
	
		// create a filtered list that will contain results for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[[[self fetchedResultsController] fetchedObjects] count]];	
	
		// restore search settings if they were saved in didReceiveMemoryWarning.
	/*
	 if (self.savedSearchTerm)
	 {
	 [self.searchDisplayController setActive:self.searchWasActive];
	 [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
	 self.savedSearchTerm = nil;
	 }
	 */
		// this is in Apple's TableSearch sample code
	self.tableView.scrollEnabled = YES;
}

- (void)clearSelection:(id)sender 
{	
		//the checkmarks are cleared in configureCell:
	self.clearTheList = YES;
	
		//needed for checkmarks to be up to date
	[self.tableView reloadData];
	
		//clear the species selection
	self.observation.species = nil;
	
	/*
	 Save the managed object context
	 */
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}


- (void)viewWillAppear:(BOOL)animated 
{	
	[super viewWillAppear:animated];	
	[self.tableView reloadData];
	
		// hide the pull-down search bar under the navigation bar
	[self.tableView setContentOffset:CGPointMake(0,40)];
	
		// hide both the pull-down search bar AND the Species Write-In under the navigation bar
		//[self.tableView setContentOffset:CGPointMake(0,100)];
	
		//use the next line to deactivate or cancel search
	[self.searchDisplayController setActive:NO animated: YES];
	
	if ((!self.observation.freeText) || ([self.observation.freeText length] == 0))
	{
		[self.button setTitle:@"Tap for Species or Comment Write-In" forState:UIControlStateNormal];
	}
	else 
	{
		[self.button setTitle:[self.observation valueForKey:@"freeText"] forState:UIControlStateNormal];
	}
	
		//FIXME: see the note in  postNotificationName: in didSelectRowAtIndexPath:
	
		//scroll and display at the selected row in the list
		//See the very bottom of https://devforums.apple.com/message/325662
		//with thanks for help from Greg Anderson and Steve Baker
	if (self.lastIndexPath) 
	{
		[self performSelector:@selector(displayRowAtSelectedIndexPath:) 
				   withObject:self.lastIndexPath 
				   afterDelay:0.0];
	}
}


- (void)displayRowAtSelectedIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath == self.lastIndexPath) 
	{
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

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
 - (void)viewDidDisappear:(BOOL)animated 
 {
 [super viewDidDisappear:animated];	
 self.searchWasActive = [self.searchDisplayController isActive];
 self.savedSearchTerm = [self.searchDisplayController.searchBar text];	
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
		//if (self.searchWasActive) 
		//Apple sample code uses this instead:
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		return 1;	
	}
	else 
	{
		return [[self.fetchedResultsController sections] count];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
		//if (self.searchWasActive) 
		//Apple sample code uses this instead:
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }	
	else 
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
}


	// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
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
		// See also Apress Beginning iPhone 3 Chapter 9 - Project 09 Nav: see CheckListController files
	
	self.species = nil;
	
	if (self.searchWasActive)
	{
		self.species = (Species *)[self.filteredListContent objectAtIndex:indexPath.row];
			//self.species = [self.filteredListContent objectAtIndex:indexPath.row];
	}
	else
	{
		self.species = (Species *)[self.fetchedResultsController objectAtIndexPath:indexPath];
			//self.species = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
	
	cell.textLabel.text = [self.species valueForKey:@"commonName"];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (self.selectedSpeciesString != nil && self.selectedSpeciesString == cell.textLabel.text && self.clearTheList == NO) 
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else if	(self.clearTheList == YES) // this clears the checkmarks
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else 
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{	
		//if (self.searchWasActive) 
		//Apple sample code uses this instead:
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		return 0;
	}
	else
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo name];
	}
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
		//if (self.searchWasActive) 
		//Apple sample code uses this instead:
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		return 0;
	}
	else
	{	
		return [self.fetchedResultsController sectionIndexTitles];
	}
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
		//if (self.searchWasActive) 
		//Apple sample code uses this instead:
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		return 0;
	}
	else
	{
		return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
	}
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{		
	RKLog(@"BEFORE species selection: %@", self.selectedSpeciesString);
	
		//ensure that this mode is NO so new selections may be made
	self.clearTheList = NO;
	
		//will get a value for selectedSpeciesString later in this method, through [selectedObject valueForKey:@"commonName"] instead of through selectedCell.textLabel.text
		//but either way may be OK?
		//UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.lastIndexPath];
		//self.selectedSpeciesString = selectedCell.textLabel.text;
	
	Species *selectedObject = nil;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (tableView == self.searchDisplayController.searchResultsTableView)
			//if (self.searchWasActive)
	{
			//selectedObject = [[self filteredListContent] objectAtIndex:[indexPath row]];
		selectedObject = (Species *) [[self filteredListContent] objectAtIndex:[indexPath row]];
		
			//http://www.iphonedevsdk.com/forum/iphone-sdk-development/41522-searchdisplaycontroller-hide-results.html
			//use the next line to deactivate or cancel search automatically after selecting a row from the filtered selections
			//if we want search to stay active continuously, then comment out this line
			//and comment out self.searchWasActive = NO;
		[self.searchDisplayController setActive:NO animated: YES];
		
			//set searchWasActive to NO now that we have selected a row and so finished the search
		self.searchWasActive = NO;
	}
	else
	{
			//selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
		selectedObject = (Species *) [[self fetchedResultsController] objectAtIndexPath:indexPath];
	}
	
		// Be sure the list is exclusive
#if 1	
		//http://stackoverflow.com/questions/974170/uitableview-having-problems-changing-accessory-when-selected
		//Apress Beginning iPhone 3 Chapter 9 - Project 09 Nav: see CheckListController files
	
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
#endif	
	
#if 0	
		// Or use this code from the Apple doc Table View Programming Guide for iPhone OS?
		// http://developer.apple.com/library/ios/#documentation/userexperience/conceptual/TableView_iPhone/ManageSelections/ManageSelections.html see Listing 6-3  Managing a selection list—exclusive list
	
	NSInteger catIndex = [[self.fetchedResultsController sections] indexOfObject:self.species]; 
	if (catIndex == indexPath.row) 
	{
		return;
	}
	
	NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
	UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath]; 
	if (newCell.accessoryType == UITableViewCellAccessoryNone) 
	{
		newCell.accessoryType = UITableViewCellAccessoryCheckmark; 
		self.species = [[self.fetchedResultsController sections] objectAtIndex:indexPath.row];
	}
	UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath]; 
	if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) 
	{
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
#endif	
	
		//remember the species selected so it can be passed to the next view
	
	self.species = selectedObject;
	self.observation.species = selectedObject;	
	self.selectedSpeciesString = [selectedObject valueForKey:@"commonName"];
	
	RKLog(@"AFTER species selection: %@", self.selectedSpeciesString);
	
		//needed for checkmarks to be up to date
	[self.tableView reloadData];
	
	/*
	 Save the managed object context when the row is tapped
	 */
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
		//FIXME: if the species was selected using search, the index path is for the *filtered* list, so scrolling to the selection later (in the full list) doesn't work, and may crash. So for now, selections made using search will not have scrolling-to-selection enabled.
	
	if (tableView == self.searchDisplayController.searchResultsTableView)
			//if (self.searchWasActive)
	{
		RKLog(@"Scroll to selection doesn't work yet if species was selected by using search");
	}
	else
	{
		NSDictionary* dict = [NSDictionary dictionaryWithObject:self.lastIndexPath 
														 forKey:self.lastIndexPath];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SpeciesSelectionVCDidSelect"
															object:self
														  userInfo:dict];	
	}
	
		//[self.navigationController popViewControllerAnimated:YES]; //only goes back one level
	[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:RKSpeciesEntity 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
		//create the predicate to filter by the chosen category
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"speciesCategory.name CONTAINS[cd] %@", self.selectedCategoryString];
	
		//http://stackoverflow.com/questions/2709768/nsfetchedresultscontroller-crashing-on-performfetch-when-using-a-cache
		//!!! WARNING: if the cache is not cleared, the app will crash with an error: "You have illegally mutated the NSFetchedResultsController's fetch request, its predicate, or its sort descriptor without either disabling caching or using +deleteCacheWithName:"
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
																								  sectionNameKeyPath:@"uppercaseFirstLetterOfName" 
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
	if ([self.searchDisplayController isActive])
	{
		return;
	}
	else 
	{
		[self.tableView beginUpdates];
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type 
{
	if ([self.searchDisplayController isActive])
	{
		return;
	}
	else 
	{		
		switch(type) 
		{
			case NSFetchedResultsChangeInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath 
{
	if ([self.searchDisplayController isActive])
	{
		return;
	}
	else
	{		
		UITableView *tableView = self.tableView;
		
		switch(type) 
		{
				
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
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
	if ([self.searchDisplayController isActive]) 
	{		
		[self searchDisplayController:[self searchDisplayController] shouldReloadTableForSearchString:[[[self searchDisplayController] searchBar] text]];
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
	else 
	{		
		[self.tableView endUpdates];
	}
}


/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	
	/*
	 Update the filtered array based on the search text.
	 */
	
		// First clear the filtered array.
	self.filteredListContent = nil;
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"commonName CONTAINS[cd] %@", searchText];	
	self.filteredListContent = [[[self fetchedResultsController] fetchedObjects] filteredArrayUsingPredicate:predicate];
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{	
	[self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:
	  [self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	
	return YES;
}

	//Not using scopeButtonTitles right now

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{	
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
	
	return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller 
{
	self.searchWasActive = YES;	
		//this is needed to prevent a crash due to the array being equal to the last filtered array rather than the fetchedResultsController list
	self.filteredListContent = [[self fetchedResultsController] fetchedObjects];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller 
{
	self.searchWasActive = NO;
	[self.tableView reloadData];	
}

#pragma mark -
#pragma mark Actions


- (IBAction)speciesWriteIn:(id)sender
{	
	SpeciesWriteInVC *nextViewController = [[SpeciesWriteInVC alloc] initWithStyle:UITableViewStyleGrouped];
	
		//pass the MOC to the nextViewController
	nextViewController.managedObjectContext = self.managedObjectContext;
	
		//and pass the observation
	nextViewController.observation = self.observation;
	
		// If we got a new view controller, push it .
	if (nextViewController) 
	{
		[self.navigationController pushViewController:nextViewController animated:YES];
	}
	
	[nextViewController release], nextViewController = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
		// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];	
		// Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
		// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
		// For example: self.myOutlet = nil;
	self.headerView = nil;
	self.searchBar = nil;
	self.button = nil;
	self.filteredListContent = nil;
}


- (void)dealloc 
{
	[headerView_ release], headerView_ = nil;
	[searchBar_ release], searchBar_ = nil;
	[button_ release], button_ = nil;
	[observation_ release], observation_ = nil;
	[species_ release], species_ = nil;
	[lastIndexPath_ release], lastIndexPath_ = nil;
	[selectedSpeciesString_ release], selectedSpeciesString_ = nil;
	[selectedCategoryString_ release], selectedCategoryString_ = nil;
	[managedObjectContext_ release], managedObjectContext_ = nil;
	[fetchedResultsController_ release], fetchedResultsController_ = nil;
	[filteredListContent_ release], filteredListContent_ = nil;
	[savedSearchTerm_ release], savedSearchTerm_ = nil;
	[self.observationEntryVC release]; self.observationEntryVC = nil;
	
	[super dealloc];
}


@end

