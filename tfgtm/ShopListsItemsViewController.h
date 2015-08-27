//
//  ShopListsItemsViewController.h
//  tfgtm
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopListsItemsViewController : UITableViewController<NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *shopListName;


- (IBAction)inviteAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *itemText;
@property (weak, nonatomic) NSString *itemEmoji;

- (IBAction)onAdd:(id)sender;

@end
