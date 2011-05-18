//
//  SpeciesWriteInVC.h
//  RoadKill
//
//  Created by Pamela on 11/11/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file


@class Observation;
@class EditableTableViewCell;


@interface SpeciesWriteInVC : UITableViewController 
{
	Observation *observation_;
	EditableTableViewCell *editableTableViewCell_;

	NSManagedObjectContext *managedObjectContext_;	
}

@property (nonatomic, retain) Observation *observation;
@property (nonatomic, assign) IBOutlet EditableTableViewCell *editableTableViewCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (void)cancel:(id)sender;
- (void)save:(id)sender;


@end


