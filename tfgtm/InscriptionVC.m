//
//  InscriptionVC.m
//  tfgtm
//
//  Created by Ghislain Fortin on 27/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import "InscriptionVC.h"


#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "TFGTMService.h"
#import "QSAppDelegate.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"



@interface InscriptionVC ()

@property (strong, nonatomic) TFGTMService *inscriptionService;


@end

@implementation InscriptionVC

@synthesize pseudoInscription;
@synthesize emailInscription;
@synthesize passwordInscription;
@synthesize confirmPasswordInscription;
@synthesize background;

@synthesize adView;

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [adView setHidden:NO];
    NSLog(@"GFO => Affiche publicité");
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [adView setHidden:YES];
    NSLog(@"GFO => Masque publicité");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    adView.delegate = self;
    [adView setHidden:YES];
    
    // Paralax effect =========
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-40);
    verticalMotionEffect.maximumRelativeValue = @(40);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-40);
    horizontalMotionEffect.maximumRelativeValue = @(40);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [background addMotionEffect:group];
    //=============================
    
    [self.view sendSubviewToBack:self.background];
    
    
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


- (IBAction)validateInscription:(id)sender {
    
    //get email address from text input
    NSString *email = self.emailInscription.text;
    
    //try validate pseudo
    if ([self.pseudoInscription.text  isEqual: @""]) {
        [self makeAlert:@"Merci de saisir un identifiant."];
        [self.pseudoInscription becomeFirstResponder];
        return;
    }
    
    //try validate email
    if ([self validateEmail:email] == NO) {
        [self makeAlert:@"Merci de saisir une adresse email valide"];
        [self.emailInscription becomeFirstResponder];
        return;
    }
    
    //try validate password
    if ([self.passwordInscription.text  isEqual: @""]) {
        [self makeAlert:@"Merci de saisir un mot de passe."];
        [self.passwordInscription becomeFirstResponder];
        return;
    }

    //try validate confirmation password
    if ([self.confirmPasswordInscription.text  isEqual: @""]) {
        [self makeAlert:@"Merci de confirmer le mot de passe."];
        [self.confirmPasswordInscription becomeFirstResponder];
        return;
    }
    
    //try validate password
    if ([self.passwordInscription.text  isEqual: self.confirmPasswordInscription.text]) {
        NSLog(@"Password = Confirmation"); }
    else
    {
        [self makeAlert:@"Merci de saisir un mot de passe."];
        [self.passwordInscription becomeFirstResponder];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.pseudoInscription.text forKey:@"userIdentifier"];
    [defaults setValue:self.emailInscription.text forKey:@"userEmail"];
    [defaults setValue:self.passwordInscription.text forKey:@"userPassword"];
    [defaults synchronize];
    
    
    NSString *UUID_User = [[NSUUID UUID] UUIDString];
    
    NSLog(@"GFO => UUID id_User %@", UUID_User);
    
    
    MSClient *client = [(QSAppDelegate *) [[UIApplication sharedApplication] delegate] client];
    
    NSDictionary *user = @{ @"id": UUID_User, @"email_User": self.emailInscription.text, @"pseudo_User" : self.pseudoInscription.text, @"password_User" : self.passwordInscription.text };
    MSTable *itemTable = [client tableWithName:@"Users"];
    
    [itemTable insert:user completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"User inserted, id: %@", [insertedItem objectForKey:@"id"]);
        }
    }];
    
    //[self.inscriptionService addUser:user completion:nil];

    
    [self performSegueWithIdentifier:@"InscriptionToShopLists" sender:self];

    
}

/*
- (void) refresh
{
    [self.refreshControl beginRefreshing];
    
    [self.inscriptionService syncDataShopLists:^
     
     {
         [self.refreshControl endRefreshing];
     }];
}
 */

@end
