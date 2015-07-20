//
//  SelectItemsVC.m
//  tfgtm
//
//  Created by Ghislain Fortin on 14/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import "SelectItemsVC.h"

@interface SelectItemsVC ()
{
    NSArray *_categories,
            *_fruitsLegumes,
            *_viandesPoissons,
            *_painsPatisseries,
            *_produitsLaitiers,
            *_patesRiz,
            *_epices,
            *_boissons,
            *_snacks,
            *_autres;
}
@end

@implementation SelectItemsVC

@synthesize tableViewItems;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize Data
    
    items = [NSMutableArray new];

    _categories = @[        @"  🍎  Fruits et légumes",
                            @"  🍗  Viandes et poissons",
                            @"  🍞  Pains et pâtisseries",
                            @"  🍦  Produits laitiers",
                            @"  🍚  Pâtes, riz et céréales",
                            @"  🌱  Épices et condiments",
                            @"  🍵  Boissons",
                            @"  🍭  Snacks et friandises",
                            @"  ❓  Autres"];

    // Connect data
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;
    self.tableViewItems.dataSource = self;
    self.tableViewItems.delegate = self;

    self.tableViewItems.beginUpdates;
    
    // Fruits et légumes
    //===================
    
    
    _fruitsLegumes = @ [        @"🍎", @"Fruits et légumes",
                                @"🍗", @"Viandes et poissons",
                                @"🍞", @"Pains et pâtisseries",
                                @"🍦", @"Produits laitiers",
                                @"🍚", @"Pâtes, riz et céréales",
                                @"🌱", @"Épices et condiments",
                                @"🍵", @"Boissons",
                                @"🍭", @"Snacks et friandises",
                                @"❓", @"Autres"];

    
    //tableViewItems.reloadData;
    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// The number of columns of data
- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _categories.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _categories[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;{
    self.title = _categories[row];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"_fruitsLegumes count %lu", (unsigned long)[_fruitsLegumes count] );
    return [_fruitsLegumes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath        *)indexPath
{
    
    NSLog(@"tableView cellForRowAtIndexPath");
    
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableViewItems  dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = @"Test textlabel";
    cell.detailTextLabel.text = @"Test detail";
    
    
    //[_fruitsLegumes objectAtIndex:indexPath.row];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    // Set the label on the cell and make sure the label color is black (in case this cell
    // has been reused and was previously greyed out
    cell.textLabel.textColor = [UIColor blackColor];
    //    cell.textLabel.text = [item valueForKey:@"text"];
    //    cell.textLabel.text = [item valueForKey:@"name_Category"];
    //    cell.textLabel.text = [item valueForKey:@"name_ShopList"];
    //    cell.detailTextLabel.text = [item valueForKey:@"name_ShopList"];
    //    cell.textLabel.text = @"🍴";
    cell.textLabel.text =  @"Test textlabel";
    cell.detailTextLabel.text = @"Test detail";

    
}





- (IBAction)addFav:(id)sender {
    //[tableViewItems beginUpdates];
    [items addObject:@"Finland"];
    /*
     NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([items count] - 1) inSection:0];
    [self.tableViewItems insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    [tableViewItems endUpdates];
     */
    [tableViewItems reloadData];
}


@end
