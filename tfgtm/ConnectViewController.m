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

@interface ConnectViewController ()

@property (strong, nonatomic) AuthService *authService;

@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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



/*
- (void) loginAndGetData
{
    MSClient *client = self.todoService.client;
    if (client.currentUser != nil) {
        return;
    }
    
    [client loginWithProvider:@"facebook" controller:self animated:YES completion:^(MSUser *user, NSError *error) {
        
        // Sauvegarde de l'authentification
//        [self saveAuthInfo];
        
//        [self refresh];
    }];

}
*/

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


- (IBAction)connect_Facebook:(id)sender {
    NSLog(@"Facebook");
    //[self loginWithProvider:@"facebook"];
}

- (IBAction)connect_Google:(id)sender {
    NSLog(@"Google");
    //[self loginWithProvider:@"google"];
}

- (IBAction)connect_Windows:(id)sender {
    NSLog(@"Windows");
    //[self loginWithProvider:@"microsoftaccount"];
}





@end
