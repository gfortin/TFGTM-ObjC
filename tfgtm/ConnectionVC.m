//
//  ConnectionVC.m
//  tfgtm
//
//  Created by Ghislain Fortin on 27/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import "ConnectionVC.h"

@interface ConnectionVC ()

@end

@implementation ConnectionVC

@synthesize emailConnection;
@synthesize passwordConnection;
@synthesize background;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Paralax effect =========
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-30);
    verticalMotionEffect.maximumRelativeValue = @(30);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-30);
    horizontalMotionEffect.maximumRelativeValue = @(30);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [background addMotionEffect:group];
    
    //=============================

    [self.view sendSubviewToBack:self.background];

    
    
    //Pour masquer le clavier
    [emailConnection setDelegate:self];
    [passwordConnection setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    
    self.title = @"Connexion";
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

/*** HELPERS  ***/


/**
 make alert from nsstring
 **/
-(void)makeAlert:(NSString *)message{
    [[[UIAlertView alloc] initWithTitle:@"⚠️ Attention!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

/**
 Validate email address
 **/
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (IBAction)connectionAction:(id)sender {
    
    //get email address from text input
    NSString *email = self.emailConnection.text;
    
    //try validate email
    if ([self validateEmail:email] == NO) {
        [self makeAlert:@"Merci de saisir une adresse email valide"];
        //set responder to this text input
        [self.emailConnection becomeFirstResponder];
        
        return;
    }
    
    //try validate password
    if ([self.passwordConnection.text  isEqual: @""]) {
        [self makeAlert:@"Merci de saisir le mot de passe."];
        [self.passwordConnection becomeFirstResponder];
        return;
    }
    
    
    //try validate password
    if ([self.passwordConnection.text  isEqual: @"rcdsm2015"]) {
        [self performSegueWithIdentifier:@"ConnectionToShopLists" sender:self];
    }else{
        [self makeAlert:@"Mot de passe incorrect."];
        [self.passwordConnection becomeFirstResponder];
        return;
    }
    
}
@end
