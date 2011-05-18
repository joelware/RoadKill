//
//  PickerViewController.h
//  RoadKill
//
//  Created by Pamela on 12/5/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file

@class Observation;


@interface PickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>  
{
	Observation *observation_;
	NSManagedObjectContext *managedObjectContext_;

		//FIXME: update the data model to include attribute for travelInfo?
	NSArray *timeOfImpactArray_;
	NSArray *travelInfoArray_;

	UIPickerView *picker_;
	UIDatePicker *datePicker_;
	
	BOOL editingDate;
	BOOL editingTimeOfImpact;
	BOOL editingTravelInfo;	
}

@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *timeOfImpactArray;
@property (nonatomic, retain) NSArray *travelInfoArray;
@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, assign, getter=isEditingDate) BOOL editingDate;
@property (nonatomic, assign, getter=isEditingTimeOfImpact) BOOL editingTimeOfImpact;
@property (nonatomic, assign, getter=isEditingTravelInfo) BOOL editingTravelInfo;


- (void)selectionChanged:(id)sender;


@end


