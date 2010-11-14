//
//  PreviewViewController.h
//  RoadKill
//
//  Created by Pamela on 11/11/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//
//  based on Apple sample code, HeaderFooter

	//#import are found in the Prefix file

@class Observation;
@class Species;


@interface PreviewViewController : UITableViewController 
{
	UIView *headerView_;
	UIView *footerView_;
	
	Observation *observation_;
	Species *species_;
	NSString *selectedSpeciesString_;
}

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) NSString *selectedSpeciesString;
@property (nonatomic, retain) Species *species;

- (IBAction)submitNow:(id)sender;
- (IBAction)saveForLater:(id)sender;
- (IBAction)addInfo:(id)sender;


@end
