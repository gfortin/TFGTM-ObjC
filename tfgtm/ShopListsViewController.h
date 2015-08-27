//  TFGTM
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 Ghislain FORTIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopListsViewController : UITableViewController<NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *shopListSelect;
@property (nonatomic, strong) NSString *strUserID;



@property (weak, nonatomic) IBOutlet UITextField *itemText;
- (IBAction)onAdd:(id)sender;

@end
