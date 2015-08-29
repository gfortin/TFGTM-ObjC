//
//  InvitationVC.m
//  tfgtm
//
//  Created by Ghislain Fortin on 26/08/2015.
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
@synthesize background;
@synthesize adView;


//create default values (MUST REWRITE)
NSString *messageBody = @"Bonjour, Je t'invite à ma liste de courses à l'aide de l'application TheFirstGetTheMilk!";
NSString *messageSubject = @"Invitation - liste de courses";


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

    // Publicité
    adView.delegate = self;
    [adView setHidden:YES];
    
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
    
    
    
    //Pour masquer le clavier
    [pseudoInvitation setDelegate:self];
    [emailInvitation setDelegate:self];
    [telephoneInvitation setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.title = @"Invitation - liste de courses";
    self.titleInvitation.text = shopListName;
    
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
    
    //get email address from text input
    NSString *email = self.emailInvitation.text;
    
    //try validate pseudo
    if ([self.pseudoInvitation.text  isEqual: @""]) {
        [self makeAlert:@"Merci de saisir un nom ou un pseudo."];
        //set responder to this text input
        [self.pseudoInvitation becomeFirstResponder];
        
        return;
    }
    
    
    //try validate email
    if ([self validateEmail:email] == NO) {
        [self makeAlert:@"Merci de saisir une adresse email valide."];
        //set responder to this text input
        [self.emailInvitation becomeFirstResponder];
        
        return;
    }else{
        //create new instane of MFMailComposeViewController
        MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
        //set delegate
        mc.mailComposeDelegate = self;
        
        //set message body
        
        messageBody = [NSString stringWithFormat:@"Bonjour %@,\n\nJe t'invite à ma liste de courses '%@' à l'aide de l'application TheFirstGetTheMilk!\n\nBonnes courses! 😋\n", pseudoInvitation.text, shopListName];
        
        
        [mc setMessageBody:messageBody isHTML:NO];
        //set message subject
        [mc setSubject:messageSubject];
        
        //set message recipients
        [mc setToRecipients:[NSArray arrayWithObject:email]];
        
        //open dialog
        [self presentViewController:mc animated:YES completion:nil];
    }
    /*
     NSString *recipients = [NSString stringWithFormat: @"mailto:%@?&subject=TFGTM : Invitation à ma liste de course", emailInvitation.text];
     
     NSString *body = [NSString stringWithFormat:@"&body=Bonjour, Je t'invite à ma liste de course %@  à l'aide de l'application TheFirstGetTheMilk!", shopListName];
     
     NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
     
     email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    */
    
     /*
     UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Invitation!" message:@"Invitation envoyée par email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [warningAlert show];
     */
    
     //[self.navigationController popToRootViewControllerAnimated:YES];
     //[self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)actionSMS:(id)sender {
    
    //[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"sms:0648162995"]];
    //[[UIApplication sharedApplication] openURL: [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", telephoneInvitation.text]]];

    //get phone number from input
    NSString *phone = self.telephoneInvitation.text;
    
    //try validate pseudo
    if ([self.pseudoInvitation.text  isEqual: @""]) {
        [self makeAlert:@"Merci de saisir un nom ou un pseudo."];
        //set responder to this text input
        [self.pseudoInvitation becomeFirstResponder];
        
        return;
    }
    
    //try validate phone number
    if ([self validatePhone:phone] == NO) {
        [self makeAlert:@"Merci de saisir un numéro de téléphone valide"];
        //set responder to this text input
        [self.telephoneInvitation becomeFirstResponder];
        
        return;
        
    }else{
        //test if this device can send message
        if([MFMessageComposeViewController canSendText] ){
            //create new instance from MFMessageComposeViewController
            MFMessageComposeViewController* comp = [[MFMessageComposeViewController alloc] init];
            
            messageBody = [NSString stringWithFormat:@"Bonjour %@,\n\nJe t'invite à ma liste de courses '%@' à l'aide de l'application TheFirstGetTheMilk!\n\nBonnes courses! 😋\n", pseudoInvitation.text, shopListName];
            
            //set properties
            comp.body = messageBody;
            comp.recipients = [NSArray arrayWithObject:phone];
            comp.messageComposeDelegate = self;
            
            //present view controller
            [self presentViewController:comp animated:YES completion:nil];
            
            /*
             UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Invitation!" message:@"Invitation envoyée par SMS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            */
        }
        else{
            [self makeAlert:@"Cet appareil ne peut pas envoyer de SMS"];
        }
    }
    
    
    //[self.navigationController popViewControllerAnimated:YES];
    
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

/**
 Validate phone number
 **/
-(BOOL)validatePhone : (NSString *)phoneNumber{
    NSString *phoneRegex = @"[0-9]+";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [test evaluateWithObject:phoneNumber];
}


#pragma mark - mail composer delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    //if result is possible
    if(result == MFMailComposeResultSent || result == MFMailComposeResultSaved || result == MFMailComposeResultCancelled){
        
        //test result and show alert
        switch (result) {
            case MFMailComposeResultCancelled:
                [self makeAlert:@"Message annulé"];
                break;
            case MFMailComposeResultSaved:
                [self makeAlert:@"Message sauvegardé"];
                break;
                //message was sent
            case MFMailComposeResultSent:
                [self makeAlert:@"Message bien envoyé"];
                break;
            case MFMailComposeResultFailed:
                [self makeAlert:@"Echec d'envoi de l'email"];
                break;
            default:
                break;
        }
    }
    //else exists error
    else if(error != nil){
        //show error
        [self makeAlert:[error localizedDescription]];
    }
    
    //dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - sms composer delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    //test result
    switch (result) {
        case MessageComposeResultCancelled:
            [self makeAlert:@"Message annulé"];
            break;
            //message was sent
        case MessageComposeResultSent:
            [self makeAlert:@"Message bien envoyé"];
            break;
        case MessageComposeResultFailed:
            [self makeAlert:@"Echec d'envoi de message"];
            break;
        default:
            break;
    }
    
    //dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
