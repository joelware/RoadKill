//
//  ObservationEntryController.h
//  RoadKill
//
//  Created by Gerard Hickey on 11/2/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ObservationEntryController : UIViewController {
    UINavigationController *navigationC;

}

@property (retain,readwrite) UINavigationController *navigationC;


- (IBAction) doDone:(id)sender;


@end
