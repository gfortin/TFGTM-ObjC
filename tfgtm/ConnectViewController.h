//
//  ConnectViewController.h
//  TFGTM
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 Ghislain FORTIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectViewController : UIViewController<NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btn_Facebook;
@property (weak, nonatomic) IBOutlet UIButton *btn_Google;
@property (weak, nonatomic) IBOutlet UIButton *btn_Windows;

- (IBAction)connect_Facebook:(id)sender;
- (IBAction)connect_Google:(id)sender;
- (IBAction)connect_Windows:(id)sender;

@end
