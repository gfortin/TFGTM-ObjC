//
//  InvitationVC.m
//  tfgtm
//
//  Created by Isabelle Dextraze on 26/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import "InvitationVC.h"

@interface InvitationVC ()

@end

@implementation InvitationVC

@synthesize shopListName;
@synthesize pseudoInvitation;
@synthesize emailInvitation;
@synthesize telephoneInvitation;




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Invitation - liste de course";

    //self.titleInvitation.text = [NSString stringWithFormat:@"Invitation à ma liste de course : %@", shopListName];
    self.titleInvitation.text = shopListName;
    
    
    
    //Pour masquer le clavier
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    pseudoInvitation.autocorrectionType = UITextAutocorrectionTypeNo;
    emailInvitation.autocorrectionType = UITextAutocorrectionTypeNo;
    
    
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

- (IBAction)actionEmail:(id)sender {

    
    NSLog(@"Action email");
    
    
     NSString *recipients = @"mailto:?cc=ghislain.fortin@hotmail.fr&subject=TFGTM : Invitation à ma liste de course";
     
     NSString *body = [NSString stringWithFormat:@"&body=Bonjour, Je t'invite à ma liste de course %@  à l'aide de l'application TheFirstGetTheMilk!", shopListName];
     
     NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
     
     email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
     
     
     //NSLog(@"GFO => SMS");
     
     UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Invitation!" message:@"Invitation envoyée par email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [warningAlert show];
     
     //[self.navigationController popToRootViewControllerAnimated:YES];
     [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)actionSMS:(id)sender {
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"sms:0648162995"]];

    
    UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Invitation!" message:@"Invitation envoyée par SMS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [warningAlert show];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // hide the on-screen keyboard
    return YES;
}

-(void)dismissKeyboard {
    [pseudoInvitation resignFirstResponder];
    [emailInvitation resignFirstResponder];
    [telephoneInvitation resignFirstResponder];
}

@end
