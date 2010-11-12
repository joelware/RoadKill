
/*
     File: EditableTableViewCell.m
 Abstract: Table view cell to present an editable text field.
 The cell layout is defined in the accompanying nib file -- EditableTableViewCell.
 
 From Apple sample code: TaggedLocations
 */


#import "EditableTableViewCell.h"

@implementation EditableTableViewCell

@synthesize textField;


- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
	// The user can only edit the text field when in editing mode.
    [super setEditing:editing animated:animated];
	textField.enabled = editing;
}


- (void)dealloc 
{
	[textField release];
	[super dealloc];
}


@end
