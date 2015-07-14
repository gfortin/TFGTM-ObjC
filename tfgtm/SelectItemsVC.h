//
//  SelectItemsVC.h
//  tfgtm
//
//  Created by Ghislain Fortin on 14/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectItemsVC : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UISearchBar *searchItem;


@end
