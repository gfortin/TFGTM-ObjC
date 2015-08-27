//
//  InscriptionVC.m
//  tfgtm
//
//  Created by Ghislain Fortin on 27/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import "InscriptionVC.h"

@interface InscriptionVC ()

@end

@implementation InscriptionVC

@synthesize pseudoInscription;
@synthesize emailInscription;
@synthesize passwordInscription;
@synthesize confirmPasswordInscription;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pour masquer le clavier
    [pseudoInscription setDelegate:self];
    [emailInscription setDelegate:self];
    [passwordInscription setDelegate:self];
    [confirmPasswordInscription setDelegate:self];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    
    
    self.title = @"Inscription";
    // Set this in every view controller so that the back button displays < instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // hide the on-screen keyboard
    return YES;
}


-(void)dismissKeyboard {
    //[pseudoInvitation resignFirstResponder];
    //[emailInvitation resignFirstResponder];
    //[telephoneInvitation resignFirstResponder];
}


- (IBAction)validateInscription:(id)sender {
}
@end
