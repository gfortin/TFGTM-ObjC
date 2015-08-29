//
//  ConnectViewController.h
//  TFGTM
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 Ghislain FORTIN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <iAd/iAd.h>


@interface ConnectViewController : UIViewController<NSFetchedResultsControllerDelegate, ADBannerViewDelegate>{
    ADBannerView *adView;
}


@property (nonatomic, strong) NSString *strUserID;
@property (nonatomic, strong) NSString *strConnectClient;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIImageView *background;



@property (weak, nonatomic) IBOutlet UIButton *btn_Facebook;
@property (weak, nonatomic) IBOutlet UIButton *btn_Google;
@property (weak, nonatomic) IBOutlet UIButton *btn_Windows;

- (IBAction)connect_Facebook:(id)sender;
- (IBAction)connect_Google:(id)sender;
- (IBAction)connect_Windows:(id)sender;

@end
