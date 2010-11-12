//
//  SpeciesWriteInVC.m
//  RoadKill
//
//  Created by Pamela on 11/11/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import "SpeciesWriteInVC.h"
#import "Observation.h"
#import "EditableTableViewCell.h"
#import "RoadKillAppDelegate.h"
#import "PreviewViewController.h"


@implementation SpeciesWriteInVC

@synthesize observation = observation_;
@synthesize editableTableViewCell = editableTableViewCell_;
@synthesize managedObjectContext = managedObjectContext_;


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.tableView.allowsSelectionDuringEditing = YES;
	self.navigationItem.title = @"Species Write-In";
	self.editing = YES;
}


- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	self.editing = NO;
}


- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	self.editing = YES;
}

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

	//don't indent when editing
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	static NSString *NameCellIdentifier = @"EditableTableViewCell";
	
    EditableTableViewCell *cell = (EditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NameCellIdentifier];
	
    if (cell == nil) 
	{		
		[[NSBundle mainBundle] loadNibNamed:@"EditableTableViewCell" owner:self options:nil];
		cell = self.editableTableViewCell;
		self.editableTableViewCell = nil;
		
			//from page 57 in Table View Programming Guide for iPhone OS:
			//"Because of the outlet connection you made, the eventTableViewCell outlet now has a reference to the cell loaded from the nib file. 
			//Immediately assign the cell to the passed-in cell variable and set the outlet to nil.
			//The string identifier you assigned to the cell in Interface Builder is the same string passed to the table view in dequeueReusableCellWithIdentifier:"
    }

	cell.textField.clearButtonMode = UITextFieldViewModeAlways;
	[cell.textField becomeFirstResponder];
	
	cell.textField.text = self.observation.freeText;
	cell.textField.placeholder = @"Enter write-in for species name";
	
    return cell;
}

#pragma mark -
#pragma mark Editing rows


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
		//do not allow a red deletion circle (we don't need one because this field is only to edit the name and we will never delete the name here)
	return UITableViewCellEditingStyleNone;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{    	
    [super setEditing:editing animated:animated];
	
		// If editing is finished, save the managed object context.
	
	if (!editing) 
	{
			//TODO: is this the best way to pass the MOC? Ideally I probably don't want to query the app delegate for the MOC?	
		self.managedObjectContext = [(RoadKillAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
		
		EditableTableViewCell *cell;
		
		cell = (EditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		self.observation.freeText = cell.textField.text;
		
		NSError *error = nil;
			//TODO: use self here? (self.managedObjectContext)
		if (![managedObjectContext_ save:&error]) 
		{
				// Handle the error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
	}
}


#pragma mark -
#pragma mark Editing text fields


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField 
{
		//this is called when the user taps the Done key on the keyboard
	self.observation.freeText = textField.text;	
	NSLog(@"1. DATA IS NOT PERSISTED YET: The name of the free text in SpeciesWriteInVC's textFieldShouldEndEditing: is %@", self.observation.freeText);
		NSLog(@"2. The name of the free text in SpeciesWriteInVC's textFieldShouldEndEditing: is %@", textField.text);
	
		// Save the change right when the user finishes typing
	
		//TODO: is this the best way to pass the MOC? Ideally I probably don't want to query the app delegate for the MOC?	
	self.managedObjectContext = [(RoadKillAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	NSError *error = nil;
		//TODO: use self here? (self.managedObjectContext)
	if (![managedObjectContext_ save:&error]) 
	{
			// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}	
	
	[self setEditing:NO];
	
	return YES;
}	


- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{	
	[textField resignFirstResponder];
	
	UIViewController *nextViewController = nil;
	
	nextViewController = [[PreviewViewController alloc] initWithNibName:@"PreviewViewController" bundle:nil];
	
		// If we got a new view controller, push it .
	if (nextViewController) 
	{
		[self.navigationController pushViewController:nextViewController animated:YES];
		[nextViewController release];
	}
	
	return YES;	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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
	self.editableTableViewCell = nil;
}


- (void)dealloc 
{
	[observation_ release], observation_ = nil;
	[editableTableViewCell_ release], editableTableViewCell_ = nil;
	[managedObjectContext_ release], managedObjectContext_ = nil;
    [super dealloc];
}


@end

