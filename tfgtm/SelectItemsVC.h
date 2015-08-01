//
//  SelectItemsVC.h
//  tfgtm
//
//  Created by Ghislain Fortin on 14/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectItemsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate> {
    //NSMutableArray *items;
    
}

//this will hold the data
@property (strong, nonatomic) NSMutableArray *items, *emoji;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UISearchBar *searchItem;
@property (weak, nonatomic) IBOutlet UITableView *tableViewItems;

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component;

@end
