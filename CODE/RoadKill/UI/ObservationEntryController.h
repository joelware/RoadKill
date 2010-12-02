//
//  ObservationEntryController.h
//  RoadKill
//
//  Created by Gerard Hickey on 11/2/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ObservationEntryController : UIViewController {

    IBOutlet UIButton *speciesButton;
}


- (IBAction) doSpecies:(id)sender;
- (IBAction) doCamera:(id)sender;
- (IBAction) doDone:(id)sender;


@end
