//
//  CameraViewController.m
//  RoadKill
//
//  Created by becca on 11/6/10.
//  Copyright 2010 Seattle RoadKill Team. All rights reserved.
//

#import "CameraViewController.h"


@implementation CameraViewController
@synthesize imagePickerController,myButton,observation;


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
	self.title=@"Camera";
	
	//UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
		
		self.imagePickerController.delegate = self;
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	    [self presentModalViewController:self.imagePickerController animated:YES];
    }
	else {
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		self.imagePickerController.delegate = self;
	    [self presentModalViewController:self.imagePickerController animated:YES];
		
	}

}

/**  *************   TEST CODE DELETE EVENTUALLY ***********************/
-(void) setupDismissButton{
	//myButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] initWithFrame:CGRectMake(50, 300, 200, 80) ];
	CGRect rect = CGRectMake(50,300,200,80);
	//	//UIButton *button = [[UIButton alloc] initWithFrame:rect];
	//	
	//	//myButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect]retain] ;
	myButton = [[UIButton alloc]initWithFrame:rect];
	[myButton setTitle:@"And a button" forState:UIControlStateNormal];
	[myButton setTitle:@"Alert  " forState:UIControlEventTouchDown];
	[myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	myButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	myButton.backgroundColor = [UIColor clearColor];
	[myButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:myButton]; 
	

}

-(void)buttonAction{
	[self.navigationController popViewControllerAnimated:YES];

}

/** ******************    END TEST CODE  *******************/


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

// this gets called when an image has been chosen from the library or taken from the camera
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	Photo * photo = (Photo*)[NSEntityDescription insertNewObjectForEntityForName:RKPhotoEntity
								  inManagedObjectContext:[observation managedObjectContext]];
	
	photo.image=image;
	NSLog(@"Photos size %d",[self.observation.photos count]);

	[self.observation addPhotosObject:photo];
	
	NSLog(@"Photos size %d",[self.observation.photos count]);
	// wow, you can't animate this
	// http://stackoverflow.com/questions/1298893/calling-poptorootviewcontrolleranimated-after-uiimagepicker-finish-or-cancel-ip
	
	[self.imagePickerController dismissModalViewControllerAnimated:NO];
	[self.navigationController popViewControllerAnimated:YES];

	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self.imagePickerController dismissModalViewControllerAnimated:NO];
	[self.navigationController popViewControllerAnimated:YES];

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
}


@end
