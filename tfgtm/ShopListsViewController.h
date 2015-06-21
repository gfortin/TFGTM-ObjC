//  TFGTM
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 Ghislain FORTIN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopListsViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *itemText;
- (IBAction)onAdd:(id)sender;

@end
