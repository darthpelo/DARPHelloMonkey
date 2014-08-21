//
//  Copyright 2011 Twilio. All rights reserved.
//
 
@interface HelloMonkeyViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton* dialButton;
@property (nonatomic, strong) IBOutlet UIButton* hangupButton;
@property (nonatomic, strong) IBOutlet UITextField* numberField;

- (IBAction)dialButtonPressed:(id)sender;
- (IBAction)hangupButtonPressed:(id)sender;

@end

