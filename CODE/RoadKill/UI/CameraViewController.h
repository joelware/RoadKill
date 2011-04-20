//
//  CameraViewController.h
//  RoadKill
//
//  Created by becca on 11/6/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Observation.h"
#import "Photo.h"
#import "RKConstants.h"


@interface CameraViewController  : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
	
    UIImagePickerController *imagePickerController;
	UIButton *myButton;
	Observation *observation;
	
}

@property (nonatomic, retain) UIImagePickerController *imagePickerController;

//** TEST CODE **/
@property (nonatomic, retain) UIButton* myButton;
@property (nonatomic, retain) Observation* observation;
-(void) buttonAction;
-(void) setupDismissButton;

@end
