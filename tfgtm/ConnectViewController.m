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
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Create the tfgtmService - this creates the Mobile Service client inside the wrapped service
    self.tfgtmService = [TFGTMService defaultService];
    
    // Let's load the user ID and token when the app starts.
    [self loadAuthInfo];
    
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
    
    //    fetchRequest.entity = [NSEntityDescription entityForName:@"ShopLists" inManagedObjectContext:context];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:context];
    //    fetchRequest.entity = [NSEntityDescription entityForName:@"TodoItem" inManagedObjectContext:context];
    
    // sort by item text
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
    
    NSLog(@"LoginAndGetData provider: %@", provider);
    
    MSClient *client = self.tfgtmService.client;
    
    
    if (client.currentUser != nil) {
       NSLog(@"client.currentUser %@ :", client.currentUser);
       return;
    }

    NSLog(@"client.currentUser = nil");
    
    [client loginWithProvider:provider controller:self animated:YES completion:^(MSUser *user, NSError *error) {
        // Sauvegarde de l'authentification
        [self saveAuthInfo];

    }];
}

// Store Authentication Tokens in App
// https://azure.microsoft.com/en-us/documentation/articles/mobile-services-ios-get-started-users/


- (void) saveAuthInfo {
    [SSKeychain setPassword:self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken forService:@"AzureMobileServiceTutorial" account:self.tfgtmService.client.currentUser.userId];
}


- (void)loadAuthInfo {
    NSString *userid = [[SSKeychain accountsForService:@"AzureMobileServiceTutorial"][0] valueForKey:@"acct"];
    if (userid) {
        NSLog(@"userid: %@", userid);
        self.tfgtmService.client.currentUser = [[MSUser alloc] initWithUserId:userid];
        self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken = [SSKeychain passwordForService:@"AzureMobileServiceTutorial" account:userid];
        
    }
}


@end
