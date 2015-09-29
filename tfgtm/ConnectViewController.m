//
//  ConnectViewController.m
//  tfgtm
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "ConnectViewController.h"
#import "AuthService.h"

#import "ShopListsViewController.h"
#import "TFGTMService.h"
#import "QSAppDelegate.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"



@interface ConnectViewController ()

//@property (strong, nonatomic) AuthService *authService;

// Private properties
@property (strong, nonatomic) TFGTMService *tfgtmService;
//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end

@implementation ConnectViewController

//@synthesize adView;
@synthesize strUserID;
@synthesize strConnectClient;
@synthesize background;


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
    // Do any additional setup after loading the view.
    
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

 
    // Set this in every view controller so that the back button displays < instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    // Create the tfgtmService - this creates the Mobile Service client inside the wrapped service
    self.tfgtmService = [TFGTMService defaultService];
    
    // Let's load the user ID and token when the app starts.

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *date = @"15/09/2015";

    NSString *signature = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleSignature"];

    NSLog(@"GFO => Version : %@", version);
    NSLog(@"GFO => Signature : %@", signature);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:version forKey:@"appVersion"];
    [defaults setValue:date forKey:@"appDate"];
    [defaults synchronize];
    
    BOOL user = (BOOL)[[NSUserDefaults standardUserDefaults] valueForKey:@"userIdentifier"];
    if(user)
    {
    NSLog(@"user");
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version_preference"];
    
    
    BOOL autoLog = (BOOL)[[NSUserDefaults standardUserDefaults] valueForKey:@"autoconnect"];
    if (autoLog)
    {
        NSLog(@"AUTOLOG ON");
        [self loadAuthInfo];
    }
    else
    {
        NSLog(@"AUTOLOG OFF");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void) loginWithProvider:(NSString *)provider
{
    //Save the provider in case we need to reauthorize them
    self.authService.authProvider = provider;
    
    MSLoginController *controller =
    [self.authService.client
     loginViewControllerWithProvider:provider
     completion:^(MSUser *user, NSError *error) {
         if (error) {
             NSLog(@"Authentication Error: %@", error);
             // Note that error.code == -1503 indicates
             // that the user cancelled the dialog
         } else {
             [self.authService saveAuthInfo];
             [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
         }
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    [self presentViewController:controller animated:YES completion:nil];
}
*/

- (IBAction)connect_Facebook:(id)sender {
    NSLog(@"Facebook");
    //[self loginWithProvider:@"facebook"];
    [self loginAndGetData:@"facebook"];
    
}

- (IBAction)connect_Google:(id)sender {
    NSLog(@"Google");
    //[self loginWithProvider:@"google"];
    [self loginAndGetData:@"google"];

}

- (IBAction)connect_Windows:(id)sender {
    NSLog(@"Windows");
    //[self loginWithProvider:@"microsoftaccount"];
    [self loginAndGetData:@"microsoftaccount"];

}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    QSAppDelegate *delegate = (QSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"Users" inManagedObjectContext:context];

    // sort by date
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ms_createdAt" ascending:YES]];
    
    // Note: if storing a lot of data, you should specify a cache for the last parameter
    // for more information, see Apple's documentation: http://go.microsoft.com/fwlink/?LinkId=524591&clcid=0x409
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

#pragma mark * NSFetchedResultsController methods


- (void) loginAndGetData:(NSString *)provider
{
    
    NSLog(@"GFO => LoginAndGetData provider: %@", provider);
    
    MSClient *client = self.tfgtmService.client;
    
    
    if (client.currentUser != nil) {
       NSLog(@"GFO => client.currentUser %@ :", client.currentUser);

        [self performSegueWithIdentifier:@"showShopLists" sender:self];
       return;
    }

    NSLog(@"client.currentUser = nil");
    
    [client loginWithProvider:provider controller:self animated:YES completion:^(MSUser *user, NSError *error) {
        // Sauvegarde de l'authentification
        [self saveAuthInfo];
        [self saveUser];

    }];
    [self performSegueWithIdentifier:@"showShopLists" sender:self];

}

// Store Authentication Tokens in App
// https://azure.microsoft.com/en-us/documentation/articles/mobile-services-ios-get-started-users/


- (void) saveAuthInfo {
    [SSKeychain setPassword:self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken forService:@"AzureMobileServiceTutorial" account:self.tfgtmService.client.currentUser.userId];
}

- (void) saveUser {
    [SSKeychain setPassword:self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken forService:@"AzureMobileServiceTutorial" account:self.tfgtmService.client.currentUser.userId];
}


- (void)loadAuthInfo {
    NSString *userid = [[SSKeychain accountsForService:@"AzureMobileServiceTutorial"][0] valueForKey:@"acct"];
    if (userid) {
        strUserID = userid;
        NSLog(@"GFO => loadAuthInfo strUserID: %@", strUserID);
        
        self.tfgtmService.client.currentUser = [[MSUser alloc] initWithUserId:userid];
        self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken = [SSKeychain passwordForService:@"AzureMobileServiceTutorial" account:userid];

    
        MSClient *client = self.tfgtmService.client;
        
                if (client.currentUser != nil)
                {
                     // Load settings
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults synchronize];
                     NSString *pseudoInscription = [defaults valueForKey:@"userIdentifier"];
                    
                    NSString *alertMessage = [NSString stringWithFormat: @"Bienvenue %@!", pseudoInscription];
                    
                    //NSString *alertMessage = [NSString stringWithFormat: @"Connexion avec %@ ", strUserID];
                    UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"👤 Connexion automatique" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [warningAlert show];
         
                    [self performSegueWithIdentifier:@"showShopLists" sender:self];
                }

    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"GFO => Prepare for Segue");
    
    if ([segue.identifier isEqualToString:@"showShopLists"]) {
        ShopListsViewController *destViewController = segue.destinationViewController;
        NSLog(@"GFO => prepareForSegue strUserID %@", strUserID);
        destViewController.strUserID = strUserID;
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}


@end
