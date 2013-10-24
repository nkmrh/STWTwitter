//
//  STWConfigController.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/20/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWConfigController.h"
#import "STWTwitterManager.h"

@interface STWConfigController ()
{
    NSString*   lastTextViewString;
}

// Property
@property (weak, nonatomic) IBOutlet UITextField* userNameTextField;

@end

@implementation STWConfigController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Invoke super
    [super viewDidLoad];
    
    // Get user name
    NSString*   userName;
    userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    // Set user name
    self.userNameTextField.text = userName;
    
    // Save text
    lastTextViewString = self.userNameTextField.text;
    
    // Set delegate
    self.userNameTextField.delegate = self;
}

//--------------------------------------------------------------//
#pragma mark -- Action --
//--------------------------------------------------------------//

- (IBAction)doneButtonAction:(id)sender {
    // Save user name
    NSUserDefaults* defaults;
    BOOL            successful;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.userNameTextField.text forKey:@"username"];
    successful = [defaults synchronize];
    
    if (successful) {
#ifdef DEBUG
        NSLog(@"Success saving username.");
#endif
        // Request
        [[STWTwitterManager sharedManager] requestWithScreenName:self.userNameTextField.text];
    }
    
    // Dismiss
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonAction:(id)sender {
    // Reset name
    self.userNameTextField.text = lastTextViewString;
    
    // Dismiss
    [self dismissViewControllerAnimated:YES completion:nil];
}

//--------------------------------------------------------------//
#pragma mark -- UITextFieldDelegate --
//--------------------------------------------------------------//

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameTextField) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}


@end
