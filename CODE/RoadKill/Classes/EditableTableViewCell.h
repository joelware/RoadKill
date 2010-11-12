
/*
     File: EditableTableViewCell.h
 Abstract: Table view cell to present an editable text field.
 The cell layout is defined in the accompanying nib file -- EditableTableViewCell.
 
From Apple sample code: TaggedLocations
 */


@interface EditableTableViewCell : UITableViewCell 
{
	UITextField *textField;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

@end
