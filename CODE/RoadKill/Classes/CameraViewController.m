    //
//  CameraViewController.m
//  RoadKill
//
//  Created by becca on 11/6/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import "CameraViewController.h"


@implementation CameraViewController
@synthesize imagePickerController;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.imagePickerController = [[UIImagePickerController alloc] init] ;

    }

    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
	
	self.imagePickerController.delegate = self;
	self.imagePickerController.sourceType = sourceType;
	
	
	if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
      //  [self.overlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.imagePickerController animated:YES];
    }
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark --
#pragma mark ImagePickerDelegate

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// this get called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Finished Picking");
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	NSLog(@"Got image %@", image);
	[self.imagePickerController dismissModalViewControllerAnimated:YES];
	self.imagePickerController.delegate=nil;
	[self.navigationController popViewControllerAnimated:YES];

	NSLog(@"Finished Picking Complete");

   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	NSLog(@"Cancel");
	self.imagePickerController.delegate=nil;
	[self.imagePickerController dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
	NSLog(@"Cancel Complete");

}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.imagePickerController=nil;
    [super dealloc];
	NSLog(@"Deallocating CameraViewController");
}


@end
