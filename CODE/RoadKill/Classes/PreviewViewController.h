//
//  PreviewViewController.h
//  RoadKill
//
//  Created by Pamela on 11/11/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

	//#import are found in the Prefix file

@class Observation;
@class Species;


@interface PreviewViewController : UITableViewController 
{
	Observation *observation_;
	Species *species_;
	NSString *selectedSpeciesString_;
}

@property (nonatomic, retain) Observation *observation;
@property (nonatomic, retain) NSString *selectedSpeciesString;
@property (nonatomic, retain) Species *species;


@end
