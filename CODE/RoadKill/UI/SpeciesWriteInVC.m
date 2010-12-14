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

	// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.tableView.allowsSelectionDuringEditing = YES;
	self.navigationItem.title = @"Species Write-In";
	self.editing = YES;
	
		//configure the save and cancel buttons
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																				target:self 
																				action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				  target:self 
																				  action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
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
	cell.textField.placeholder = @"Enter write-in";
	
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
}


#pragma mark -
#pragma mark Editing text fields


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField 
{	
	[self setEditing:NO];	
	return YES;
}	


- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{	
		//keep keyboard in case user pops back
		//[textField resignFirstResponder];
	
	[self save:self];
	
	return YES;	
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		// Navigation logic may go here. Create and push another view controller.
}

#pragma mark -
#pragma mark Actions

- (void)cancel:(id)sender
{	
		//don't pass the value, just pop the view
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)save:(id)sender
{	
	EditableTableViewCell *cell;
	
	cell = (EditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	self.observation.freeText = cell.textField.text;
	
		//save the MOC
	NSError *error = nil;
		//TODO: use self here? (self.managedObjectContext)
	if (![self.managedObjectContext save:&error]) 
	{
			// Handle the error.
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
		//TODO: do we want to pop back one view or pop back to Preview?
	
		//pop back one view
		//[self.navigationController popViewControllerAnimated:YES];
	
		//pop back to Preview
	[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
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

