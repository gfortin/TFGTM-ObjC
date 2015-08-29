//
//  InscriptionVC.h
//  tfgtm
//
//  Created by Ghislain Fortin on 27/08/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>


@interface InscriptionVC : UIViewController<UINavigationControllerDelegate, UITextFieldDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
}
@property (nonatomic, retain) IBOutlet ADBannerView *adView;

@property (weak, nonatomic) IBOutlet UITextField *pseudoInscription;
@property (weak, nonatomic) IBOutlet UITextField *emailInscription;
@property (weak, nonatomic) IBOutlet UITextField *passwordInscription;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordInscription;
@property (weak, nonatomic) IBOutlet UIImageView *background;

- (IBAction)validateInscription:(id)sender;

@end
