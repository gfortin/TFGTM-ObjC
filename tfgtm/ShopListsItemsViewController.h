//
//  ShopListsItemsViewController.h
//  tfgtm
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <WebKit/WebKit.h>


@interface ShopListsItemsViewController : UITableViewController<NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSString *shopListName;
@property (nonatomic, strong) NSString *shopListID;


- (IBAction)inviteAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *itemText;
@property (weak, nonatomic) NSString *itemEmoji;

- (IBAction)onAdd:(id)sender;

@end
