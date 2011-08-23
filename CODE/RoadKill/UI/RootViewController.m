	//
	//  RootViewController.m
	//  RoadKill
	//
	//  Created by Pamela on 11/1/10.
	//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
	//

#import "RootViewController.h"
#import "Observation.h"
#import "Species.h"
#import "HalsRootViewController.h"
#import "ObservationEntryController.h"
#import "ExistingReportsVC.h"
#import "PreviewViewController.h"
#import "RKConstants.h"


@implementation RootViewController


	//@synthesize observation = observation_;
@synthesize headerView = headerView_;
@synthesize selectedSpeciesIndexPath = selectedSpeciesIndexPath_;
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style 
 {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if ((self = [super initWithStyle:style])) 
 {
 }
 return self;
 }
 */


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.title = @"Observations";
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) 
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//abort();
		exit(-1);
	}
	
		//TODO: do I need this? (it's in Apple's TableSearch)
	self.tableView.scrollEnabled = YES;
}


- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
		//FIXME: see the note in postNotificationName: in SpeciesSelectionVC's didSelectRowAtIndexPath:
	
		//if a species was selected (and the species list was popped), this notification allows the species list (when pushed again) to scroll to the row that was selected for the observation. This saves the user having to scroll the list to find the selection that was already made.
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notifyOfLastIndexPathToScrollToRow:)
												 name:@"SpeciesSelectionVCDidSelect"
											   object:nil];
	[self.tableView reloadData];
}

- (void) notifyOfLastIndexPathToScrollToRow:(NSNotification *)notification 
{
		//use the indexPath to scroll to the selected species when the user gets to the SpeciesSelectionVC
	NSIndexPath *path;
	
	for (path in [notification userInfo]) 
	{
		self.selectedSpeciesIndexPath = path;
		RKLog(@"RootViewController received notification of the indexPath of the selected species: %@", self.selectedSpeciesIndexPath);
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

	//The sections will be based on the sentStatus (see fetchedResultsController)
	//TODO: sentStatus is simplified for now, for testing only. More will be required for a ready status. (See PreviewViewController's determineStatus:)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
		// Return the number of sections.
	return [[self.fetchedResultsController sections] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
		// Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}


	// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
		// Configure the cell...
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
		// A date formatter for short style date display
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) 
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	}	
		// Configure the cell	
	Observation *observation = (Observation *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [dateFormatter stringFromDate:observation.observationTimestamp];
	
		//this displays only the species name
		//cell.detailTextLabel.text = observation.species.commonName;
	
		//or this next code displays the species name *and* the freeText (if there is freeText)
	
		//freeText can be used to *supplement* species name or
		//freeText can be used *in place of* species name?
	NSMutableString * append = [NSMutableString stringWithString:@""];
	if (observation.species.commonName) 
	{
		[append appendString:observation.species.commonName];
	}
	if ((observation.freeText != nil) && (observation.species.commonName == nil))
	{	
		[append appendString:observation.freeText];
	}
	else if ((observation.freeText != nil) && ([observation.freeText length] > 0) &&(observation.species.commonName != nil))
	{
		[append appendString:@" / "];
		[append appendString:observation.freeText];
	}
	
	cell.detailTextLabel.text = append;	
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


#pragma mark -
#pragma mark editing


	// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 	
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
			// Delete the managed object for the given index path
		self.managedObjectContext = [self.fetchedResultsController managedObjectContext];
		[self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
			// Save the context.
			// TODO: find out if self.managedObjectContext should be used during saves (or managedObjectContext_)
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	} 
}



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
		// Navigation logic may go here. Create and push another view controller.
	
		//push the PreviewViewController when an existing observation is selected from the list
	PreviewViewController *nextViewController = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
	
		//determine which observation was selected
	Observation *selectedObservation = (Observation *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
		//pass the selected observation to the next view controller
	nextViewController.observation = selectedObservation;
		//pass the MOC to the nextViewController
	nextViewController.managedObjectContext = self.managedObjectContext;
		//send the indexPath so the species view will scroll to the species row
	nextViewController.selectedSpeciesIndexPath = self.selectedSpeciesIndexPath;
	
	if (nextViewController) 
	{
		[self.navigationController pushViewController:nextViewController animated:YES];
	}	
	[nextViewController release], nextViewController = nil;	
}

#pragma mark -
#pragma mark Add Observation support

- (IBAction)addObservation:(id)sender
{
	if (self.editing) 
	{
			//cancel editing if a new observation is started
		self.editing = NO;
	}
	
		//add the new object to the MOC
	Observation *observation = [NSEntityDescription insertNewObjectForEntityForName:RKObservationEntity 
															 inManagedObjectContext:self.managedObjectContext];
	
		//these are set in the observation's awakeFromInsert: method - 
		//1. the status is "not ready" (kRKNotReady) because the observation was just created
		//2. the latitude is 38 and longitude is -120, per Dave Waetjen's request, for submitted test observations
	
		//FIXME: add an alert to warn the team to set the latitude at 38 and longitude at -120, per Dave Waetjen's request for testing purposes. 
		//!!! Do not allow submission of an observation unless lat and lon is correct!
	
		//FIXME: add an alert to warn the team to set the freeText to TEST for testing purposes. 
		//!!! Do not allow submission of an observation unless freeText is set to TEST 
	
		//timestamp the observation, but later the user can edit this
	observation.observationTimestamp = [NSDate date];
	
		//start off with a blank "time since impact" field
		//setting it to default to 0 might cause the user to forget to edit that field?
	observation.decayDurationHours = nil;
	
	    // Save the context.
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
	
		// Take a photo  (JW4 inte)
		
	
	CameraViewController* detailViewController = [[CameraViewController alloc]init];
	detailViewController.observation=observation;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	
		//
		//push to the Preview where data will be collected
	
	PreviewViewController *nextViewController = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
	
		//pass the MOC to the nextViewController
	nextViewController.managedObjectContext = self.managedObjectContext;
	
		//pass the observation
	nextViewController.observation = observation;
	
	if (nextViewController) 
	{
		[self.navigationController pushViewController:nextViewController animated:YES];
	}	
	[nextViewController release], nextViewController = nil;	
}


#pragma mark -
#pragma mark Fetched results controller

	//see Apple sample code CoreDataBooks and iPhoneCoreDataRecipes

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController 
{
    
    if (fetchedResultsController_ != nil) 
	{
        return fetchedResultsController_;
    }
    
		// Create and configure a fetch request with the Observation entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:RKObservationEntity 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
		// Create the sort descriptors array.
		//Sort by sentStatus and observationTimestamp for now 
		//TODO: may add other sortDescriptors in the future?
	NSSortDescriptor *sentStatusDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sentStatus" ascending:YES];
	
		//TODO: is this the preferred sort?
		//this lists newest observation at the top - preferred?
	NSSortDescriptor *observationTimestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"observationTimestamp" ascending:NO];
	
		//this lists oldest observation at the top - not preferred?
		//NSSortDescriptor *observationTimestampDescriptor = [[NSSortDescriptor alloc] initWithKey:@"observationTimestamp" ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sentStatusDescriptor, observationTimestampDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
		// Create and initialize the fetch results controller.
		//The sections will be based on the sentStatus
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext 
																								  sectionNameKeyPath:@"sentStatus" 
																										   cacheName:@"Root"];
	
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
		// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[sentStatusDescriptor release];
	[observationTimestampDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController_;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
		// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
		// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
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
}


- (void)dealloc 
{
		//[observation_ release], observation_ = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[headerView_ release], headerView_ = nil;
	[selectedSpeciesIndexPath_ release], selectedSpeciesIndexPath_ = nil;
	[fetchedResultsController_ release], fetchedResultsController_ = nil;
    [managedObjectContext_ release], managedObjectContext_ = nil;
    [super dealloc];
}


@end

