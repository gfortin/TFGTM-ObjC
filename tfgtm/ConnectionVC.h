//
//  ConnectionVC.h
//  tfgtm
//
//  Created by Ghislain Fortin on 27/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionVC : UIViewController<UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailConnection;
@property (weak, nonatomic) IBOutlet UITextField *passwordConnection;

- (IBAction)connectionAction:(id)sender;

@end
