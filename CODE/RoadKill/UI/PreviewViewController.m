	//
	//  PreviewViewController.m
	//  RoadKill
	//
	//  Created by Pamela on 11/11/10.
	//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
	//
	//  based on Apple sample code, HeaderFooter


#import "RootViewController.h"
#import "PreviewViewController.h"
#import "Observation.h"
#import "Species.h"
#import "SpeciesCategory.h"
#import "PickerViewController.h"
#import "SpeciesSelectionVC.h"
#import "SpeciesCategorySelectionVC.h"
#import "SpeciesWriteInVC.h"
#import "RKConstants.h"


@implementation PreviewViewController

@synthesize headerView = headerView_, footerView = footerView_;
@synthesize selectedSpeciesString = selectedSpeciesString_, selectedCategoryString = selectedCategoryString_, selectedSpeciesIndexPath = selectedSpeciesIndexPath_;
@synthesize nextViewController = nextViewController_;
@synthesize observation = observation_;
@synthesize species = species_;
@synthesize managedObjectContext = managedObjectContext_, fetchedResultsController=fetchedResultsController_;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.navigationItem.title = @"Preview";
	
	self.tableView.tableHeaderView = self.headerView;	
	self.tableView.tableFooterView = self.footerView;
	
	self.tableView.allowsSelection = YES;
	
	RKLog(@"PreviewViewController: the observation is: %@", self.observation);
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
		//use the indexPath to scroll to the selected species when the user gets back to the SpeciesSelectionVC
	NSIndexPath *path;
	
	for (path in [notification userInfo]) 
	{
		self.selectedSpeciesIndexPath = path;
		RKLog(@"PreviewViewController received notification of the indexPath of the selected species = %@", self.selectedSpeciesIndexPath);
	}
}

- (void)viewDidAppear:(BOOL)animated 
{
		//this works better than viewWillAppear: for default time-since-impact (ie: if user leaves picker at 0 without moving it, intending 0 as the selection)
	[super viewDidAppear:animated];
	[self.tableView reloadData];	
}


- (void)viewWillDisappear:(BOOL)animated 
{
		//if user forgets to tap the Save For Later button, save observation to the correct section in the rootView anyway
	[super viewWillDisappear:animated];
	[self determineStatus];
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
		// Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		// Return the number of rows in the section.
    return 6;
}


	// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
		// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) 
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
			// cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
			//cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
		// Configure the cell...
	
	switch (indexPath.row) 
	{
		case 0:
			cell.textLabel.text = @"Date";
			cell.detailTextLabel.text = [dateFormatter stringFromDate:self.observation.observationTimestamp];
			break;
		case 1:
			cell.textLabel.text = @"Location";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", 
										 self.observation.latitude, 
										 self.observation.longitude];
			break;
		case 2:
			cell.textLabel.text = @"Category";
				//cell.detailTextLabel.text = self.selectedCategoryString;
			cell.detailTextLabel.text = self.observation.species.speciesCategory.name;
			
			break;	
		case 3:
			cell.textLabel.text = @"Species";
			cell.detailTextLabel.text = self.observation.species.commonName;
			break;	
		case 4:
			cell.textLabel.text = @"Free text";
			cell.detailTextLabel.text = self.observation.freeText;
			break;
		case 5:
			cell.textLabel.text = @"Time since impact";
				//cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ hours", self.observation.decayDurationHours];
			NSNumber *theNumber = self.observation.decayDurationHours;
			
			if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:0]]) 
			{
				cell.detailTextLabel.text = @"0 (witnessed)";
			}
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:3]]) 
			{
				cell.detailTextLabel.text = @"< 3 hrs";
			}
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:6]]) 
			{
				cell.detailTextLabel.text = @"< 6 hrs";
			}
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:12]]) 
			{
				cell.detailTextLabel.text = @"< 12 hrs";
			}		
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:24]]) 
			{
				cell.detailTextLabel.text = @"1 day";
			}		
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(7*24)]]) 
			{
				cell.detailTextLabel.text = @"1 week";
			}		
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(14*24)]]) 
			{
				cell.detailTextLabel.text = @"2 weeks";
			}
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(30*24)]]) 
			{
				cell.detailTextLabel.text = @"1 month";
			}		
			else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(45*24)]]) 
			{
				cell.detailTextLabel.text = @"over 1 mo";
			}		
			break;
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
		// Navigation logic may go here. Create and push another view controller.
	
	switch (indexPath.row) 
	{
		case 0: //this is the date row
		{
			PickerViewController *theController = [[PickerViewController alloc] initWithNibName:@"PickerViewController" bundle:nil];

				//pass the observation
			theController.observation = self.observation;
				//pass the MOC 
			theController.managedObjectContext = self.managedObjectContext;
			theController.editingDate = YES;
			theController.editingTimeOfImpact = NO;
			theController.editingTravelInfo = NO;
			
			self.nextViewController = theController;

			[theController release];
		}
			break;
		case 1:	//this is the location row
		{
				//TODO: add location code
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			RKLog(@"LOCATION CODE NEEDS TO BE ADDED");
			return;
		}
			break;
		case 2:	//this is the species category row
		{
			SpeciesCategorySelectionVC *theController = [[SpeciesCategorySelectionVC alloc] initWithStyle:UITableViewStyleGrouped];
			
				//pass the observation: SpeciesCategorySelectionVC doesn't change the observation, it only selects a selectedCategoryString and passes it to SpeciesSelectionVC. But it needs the observation so it can pass it on to SpeciesSelectionVC?
			theController.observation = self.observation;
				//pass the MOC 
			theController.managedObjectContext = self.managedObjectContext;
				//pass the category name back to the VC so it can put a checkmark by the name
			theController.selectedCategoryString = self.observation.species.speciesCategory.name;
			
			self.nextViewController = theController;
			
			[theController release];
		}
			break;
		case 3:	//this is the species row
		{	
				//but if there's no species yet, pass them the category so they can start there instead
			if (!self.observation.species) 
			{
				SpeciesCategorySelectionVC *theController = [[SpeciesCategorySelectionVC alloc] initWithStyle:UITableViewStyleGrouped];

					//pass the observation
				theController.observation = self.observation;
					//pass the MOC 
				theController.managedObjectContext = self.managedObjectContext;
				
				self.nextViewController = theController;

				[theController release];
			}
			else 
			{
				SpeciesSelectionVC *theController = [[SpeciesSelectionVC alloc] initWithNibName:@"SpeciesSelectionVC" bundle:nil];

					//pass the observation
				theController.observation = self.observation;
					//pass the MOC 
				theController.managedObjectContext = self.managedObjectContext;
				theController.selectedCategoryString = self.observation.species.speciesCategory.name;
				theController.selectedSpeciesString = self.observation.species.commonName;
				
					//send the indexPath so the species view will scroll to the species row
				theController.lastIndexPath = self.selectedSpeciesIndexPath;
				
				self.nextViewController = theController;

				[theController release];
			}
		}
			break;
		case 4:	//this is the free text row
		{	
			SpeciesWriteInVC *theController = [[SpeciesWriteInVC alloc] initWithStyle:UITableViewStyleGrouped];

				//pass the observation
			theController.observation = self.observation;
				//pass the MOC 
			theController.managedObjectContext = self.managedObjectContext;
			
			self.nextViewController = theController;

			[theController release];
		}
			break;
		case 5:	//this is the date since impact row
		{	
			PickerViewController *theController = [[PickerViewController alloc] initWithNibName:@"PickerViewController" bundle:nil];
			theController.observation = self.observation;
			theController.managedObjectContext = self.managedObjectContext;
			theController.editingDate = NO;
			theController.editingTimeOfImpact = YES;
			theController.editingTravelInfo = NO;
			
			self.nextViewController = theController;

			[theController release];
		}
			break;
	}
	
		// If we got a new view controller, push it .
	if (self.nextViewController) 
	{
		[self.navigationController pushViewController:self.nextViewController animated:YES];
	}
}


#pragma mark -
#pragma mark Action methods

- (IBAction)submitNow:(id)sender
{
		//TODO: consider using validForUpdate: here? Or Observation's isValidForSubmission?
	RKLog(@"CODE NEEDS TO BE WRITTEN");
}

- (void)determineStatus
{
		//FIXME: what else is required for a ready status?
		//consider using validForUpdate: here?
	
	if (self.observation.observationTimestamp != nil && self.observation.longitude != nil && self.observation.latitude != nil && self.observation.species != nil && self.observation.decayDurationHours != nil) 
	{
		self.observation.sentStatus = kRKReady;
	}
	else 
	{
		self.observation.sentStatus = kRKNotReady;
	}
}

- (IBAction)saveForLater:(id)sender
{
	
	[self determineStatus];
	
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
		//pop back to the RootViewController if observation is saved for later submission
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)addInfo:(id)sender
{
	RKLog(@"CODE NEEDS TO BE WRITTEN");
}


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
	self.headerView = nil;
	self.footerView  = nil;
}


- (void)dealloc 
{	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[headerView_ release], headerView_ = nil;
	[footerView_ release], footerView_ = nil;
	[observation_ release], observation_ = nil;
	[selectedSpeciesString_ release], selectedSpeciesString_ = nil;
	[selectedCategoryString_ release], selectedCategoryString_ = nil;
	[selectedSpeciesIndexPath_ release], selectedSpeciesIndexPath_ = nil;
	[nextViewController_ release], nextViewController_ = nil;
	[species_ release], species_ = nil;
	[managedObjectContext_ release], managedObjectContext_ = nil;
	[fetchedResultsController_ release], fetchedResultsController_ = nil;
	[super dealloc];
}


@end

