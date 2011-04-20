	//
	//  PickerViewController.m
	//  RoadKill
	//
	//  Created by Pamela on 12/5/10.
	//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
	//

#import "PickerViewController.h"
#import "Observation.h"


@implementation PickerViewController

@synthesize observation = observation_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize timeOfImpactArray = timeOfImpactArray_, travelInfoArray = travelInfoArray_;
@synthesize picker = picker_, datePicker = datePicker;
@synthesize editingDate, editingTimeOfImpact, editingTravelInfo;


	// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


	// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	if (editingDate) 
	{
		self.navigationItem.title = @"Observation date";
	}
	else if	(editingTimeOfImpact)
	{
		self.navigationItem.title = @"Impact time";
	}
	else if	(editingTravelInfo)
	{
		self.navigationItem.title = @"Travel info";
	}
	
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
		// Configure the user interface according to state.
    if (editingDate) 
	{
        datePicker.hidden = NO;
		self.picker.hidden = YES;
		
		NSDate *date = self.observation.observationTimestamp;
        if (date == nil) date = [NSDate date];
        datePicker.date = date;
    }
	else if (editingTimeOfImpact)
	{
        datePicker.hidden = YES;
		self.picker.hidden = NO;
		
		self.timeOfImpactArray = [NSArray arrayWithObjects:
								  @"exact time (witnessed)",
								  @"definitely less than 3 hours",
								  @"definitely less than 6 hours", 
								  @"definitely less than 12 hours", 
								  @"definitely less than 24 hours",
								  @"about one week",
								  @"about two weeks",
								  @"about one month",
								  @"unknown - over month",
								  nil];
		NSNumber *theNumber = self.observation.decayDurationHours;
		
			//reload the titles for the picker
		[self.picker reloadComponent:0];
		
			//then set the picker to the value of the attribute, if there is one
		
		if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:0]]) 
		{
			[self.picker selectRow:0 inComponent:0 animated:YES];
		}
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:3]]) 
		{
			[self.picker selectRow:1 inComponent:0 animated:YES];
		}
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:6]]) 
		{
			[self.picker selectRow:2 inComponent:0 animated:YES];
		}
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:12]]) 
		{
			[self.picker selectRow:3 inComponent:0 animated:YES];
		}		
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:24]]) 
		{
			[self.picker selectRow:4 inComponent:0 animated:YES];
		}		
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(7*24)]]) 
		{
			[self.picker selectRow:5 inComponent:0 animated:YES];
		}		
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(14*24)]]) 
		{
			[self.picker selectRow:6 inComponent:0 animated:YES];
		}
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(30*24)]]) 
		{
			[self.picker selectRow:7 inComponent:0 animated:YES];
		}		
		else if ([theNumber isEqualToNumber:[NSNumber numberWithInteger:(45*24)]]) 
		{
			[self.picker selectRow:8 inComponent:0 animated:YES];
		}		
	}
	else if (editingTravelInfo)
	{
		datePicker.hidden = YES;
		self.picker.hidden = NO;
			//FIXME: write this code if this optional info is added
		RKLog(@"The code for this optional information has not been written yet");
	}
	
}

- (void)viewDidDisappear:(BOOL)animated 
{
	[super viewDidDisappear:animated];
	
		//if no choice was made, default to 0 so something will be displayed when the user returns to Preview
		//if the user doesn't move the picker (because they want 0), the setting of 0 won't be detected by didSelectRow:
	
	if (!self.observation.decayDurationHours) 
	{
		self.observation.decayDurationHours = [NSNumber numberWithInteger:0];
	}
	
		// Save the change
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
			// Handle the error.
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{		
	NSUInteger count = [timeOfImpactArray_ count];
	return count;
}


#pragma mark -
#pragma mark UIPickerViewDataSource


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	returnStr = [self.timeOfImpactArray objectAtIndex:row];
	return returnStr;
}


#pragma mark -
#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	
	if (editingDate) 
	{
			//handled in selectionChanged;
	}
	else if	(editingTimeOfImpact)
	{
		NSString *selection = [self.timeOfImpactArray objectAtIndex:[pickerView selectedRowInComponent:0]];
		if ([selection isEqualToString:@"exact time (witnessed)"]) 
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:0];
		}
		else if ([selection isEqualToString:@"definitely less than 3 hours"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:3];
		}
		else if ([selection isEqualToString:@"definitely less than 6 hours"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:6];
		}
		else if ([selection isEqualToString:@"definitely less than 12 hours"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:12];
		}
		else if ([selection isEqualToString:@"definitely less than 24 hours"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:24];
		}
		else if ([selection isEqualToString:@"about one week"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:(7*24)];
		}
		else if ([selection isEqualToString:@"about two weeks"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:(14*24)];
		}
		else if ([selection isEqualToString:@"about one month"])
		{
			self.observation.decayDurationHours = [NSNumber numberWithInteger:(30*24)];
		}
		else if ([selection isEqualToString:@"unknown - over month"])
		{
				//TODO: what is the correct value to use?
			self.observation.decayDurationHours = [NSNumber numberWithInteger:(45*24)];
		}
	}
	else if (editingTravelInfo)
	{
			//FIXME: write this code if this optional info is added
		RKLog(@"The code for this optional information has ot been written");
	}
	
		// Save the change
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) 
	{
			// Handle the error.
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}


#pragma mark -
#pragma mark Actions

	//A connection is made in IB with File's Owner so this method will be called when the date is changed
- (IBAction)selectionChanged:(id)sender
{		
	self.observation.observationTimestamp = datePicker.date;
	
		// Save the change right when the date is changed
	NSError *error = nil;
	if (![managedObjectContext_ save:&error]) 
	{
			// Handle the error.
		RKLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
		// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
		// Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
		// Release any retained subviews of the main view.
		// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[observation_ release], observation_ = nil;
	[managedObjectContext_ release], managedObjectContext_ = nil;
	[timeOfImpactArray_ release], timeOfImpactArray_ = nil;
	[travelInfoArray_ release], travelInfoArray_ = nil;
	[picker_ release], picker_ = nil;
	[datePicker_ release], datePicker_ = nil;
	[super dealloc];
}


@end
