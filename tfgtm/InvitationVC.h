//
//  InvitationVC.h
//  tfgtm
//
//  Created by Isabelle Dextraze on 26/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitationVC : UIViewController

@property (nonatomic, strong) NSString *shopListName;

@property (weak, nonatomic) IBOutlet UILabel *titleInvitation;

@property (weak, nonatomic) IBOutlet UITextField *pseudoInvitation;
@property (weak, nonatomic) IBOutlet UITextField *emailInvitation;
@property (weak, nonatomic) IBOutlet UITextField *telephoneInvitation;


- (IBAction)actionEmail:(id)sender;
- (IBAction)actionSMS:(id)sender;

@end
