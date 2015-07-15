//
//  SelectItemsVC.h
//  tfgtm
//
//  Created by Ghislain Fortin on 14/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectItemsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate> {
    NSMutableArray *items;
}

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UISearchBar *searchItem;
@property (weak, nonatomic) IBOutlet UITableView *tableViewItems;

- (IBAction)addItem:(id)sender;


@end
