//
//  InvitationVC.h
//  tfgtm
//
//  Created by Ghislain Fortin on 26/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface InvitationVC : UIViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *shopListName;

@property (weak, nonatomic) IBOutlet UILabel *titleInvitation;

@property (weak, nonatomic) IBOutlet UITextField *pseudoInvitation;
@property (weak, nonatomic) IBOutlet UITextField *emailInvitation;
@property (weak, nonatomic) IBOutlet UITextField *telephoneInvitation;
@property (weak, nonatomic) IBOutlet UIImageView *background;



- (IBAction)actionEmail:(id)sender;
- (IBAction)actionSMS:(id)sender;

@end
