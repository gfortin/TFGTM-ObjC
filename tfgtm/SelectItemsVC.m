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

//lazy instantiation
-(NSMutableArray*)items
{
    if (_items == nil) {
        _items = [[NSMutableArray alloc]init];
    }
    return _items;
}

@synthesize tableViewItems;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Initialize Data
    
    _categories = @[        @"  🍎  Fruits et légumes",
                            @"  🍗  Viandes et poissons",
                            @"  🍞  Pains et pâtisseries",
                            @"  🍦  Produits laitiers",
                            @"  🍚  Pâtes, riz et céréales",
                            @"  🌱  Épices et condiments",
                            @"  🍵  Boissons",
                            @"  🍭  Snacks et friandises",
                            @"  ❓  Autres"];

    
    _fruitsLegumes = @[ @"🍎 Pommes",
                        @"🍊 Oranges",
                        @"🍋 Citrons",
                        @"🍒 Cerises",
                        @"🍒 Cerises",
                        @"🍒 Cerises",
                        @"🍒 Cerises",
                        @"🍒 Cerises",
                        @"🍒 Cerises",
                        @"🍒 Cerises"
                        ];
    
    
    _viandesPoissons = @[ @"🐓 Poulet",
                          @"🐂 Boeuf",
                          @"🐖 Porc",
                          @"🐟 Thon",
                          @"🍒 Cerises",
                          @"🍒 Cerises",
                          @"🍒 Cerises",
                          @"🍒 Cerises",
                          @"🍒 Cerises",
                          @"🍒 Cerises"
                        ];
    
    _painsPatisseries = @[ @"🍎 painsPatisseries",
                           @"🍊 painsPatisseries",
                           @"🍋 painsPatisseries",
                           @"🍒 painsPatisseries",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises"
                           ];

    _produitsLaitiers = @[ @"🍎 produitsLaitiers",
                           @"🍊 produitsLaitiers",
                           @"🍋 produitsLaitiers",
                           @"🍒 produitsLaitiers",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises",
                           @"🍒 Cerises"
                           ];

    _patesRiz = @[ @"🍎 patesRiz",
                   @"🍊 patesRiz",
                   @"🍋 patesRiz",
                   @"🍒 patesRiz",
                   @"🍒 Cerises",
                   @"🍒 Cerises",
                   @"🍒 Cerises",
                   @"🍒 Cerises",
                   @"🍒 Cerises",
                   @"🍒 Cerises"
                   ];

    _epices = @[ @"🍎 epices",
                 @"🍊 epices",
                 @"🍋 epicess",
                 @"🍒 epices",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises"
                 ];

    _boissons =@[ @"🍎 boissons",
                  @"🍊 boissons",
                  @"🍋 boissons",
                  @"🍒 boissons",
                  @"🍒 Cerises",
                  @"🍒 Cerises",
                  @"🍒 Cerises",
                  @"🍒 Cerises",
                  @"🍒 Cerises",
                  @"🍒 Cerises"
                  ];

    _snacks = @[ @"🍎 _snacks",
                 @"🍊 _snacks",
                 @"🍋 _snacks",
                 @"🍒 _snacks",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises"
               ];
    
    _autres = @[ @"🍎 _autres",
                 @"🍊 _autres",
                 @"🍋 _autres",
                 @"🍒 _autres",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises",
                 @"🍒 Cerises"
               ];

    
    
    [self.items addObjectsFromArray:_fruitsLegumes];
    
    
    // Connect data
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;

    self.tableViewItems.dataSource = self;
    self.tableViewItems.delegate = self;


    
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
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _categories.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _categories[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;{
    
    //GFO
    
    self.title = _categories[row];
    
    [tableViewItems beginUpdates];
    
    
    [self.items removeAllObjects];
    
    
    
    switch (row)
    {
        case 0:
            [self.items addObjectsFromArray: _fruitsLegumes];
            break;
            
        case 1:
            [self.items addObjectsFromArray: _viandesPoissons];
            break;
            
        case 2:
            [self.items addObjectsFromArray: _painsPatisseries];
            break;
            
        case 3:
            [self.items addObjectsFromArray: _produitsLaitiers];
            break;
            
        case 4:
            [self.items addObjectsFromArray: _patesRiz];
            break;
            
        case 5:
            [self.items addObjectsFromArray: _epices];
            break;
            
        case 6:
            [self.items addObjectsFromArray: _boissons];
            break;
            
        case 7:
            [self.items addObjectsFromArray: _snacks];
            break;
            
        case 8:
            [self.items addObjectsFromArray: _autres];
            break;
            
        default:
            [self.items addObjectsFromArray: _autres];
            break;
    }
    
    
    /*
     NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([self.items count] - 1) inSection:0];

     [self.tableViewItems insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    */
     
    [tableViewItems endUpdates];
    [tableViewItems reloadData];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection: [self.items count] %lu", (unsigned long)[self.items count] );
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath        *)indexPath
{
    
    NSLog(@"tableView cellForRowAtIndexPath");
    
    /*
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableViewItems  dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = @"Test textlabel";
    cell.detailTextLabel.text = @"Test detail";
    
    
    //[_fruitsLegumes objectAtIndex:indexPath.row];
    return cell;
    */
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"identifier"];
    }

    cell.textLabel.font = [UIFont systemFontOfSize:32];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.text =  [self.items [indexPath.row] substringToIndex:2];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:25];
    cell.detailTextLabel.text = [self.items [indexPath.row] substringFromIndex:2];
    

    return cell;
    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // hide the on-screen keyboard
    return YES;
}


/*
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"configureCell");

    
    // Set the label on the cell and make sure the label color is black (in case this cell
    // has been reused and was previously greyed out
    cell.textLabel.textColor = [UIColor blackColor];
    //    cell.textLabel.text = @"🍴";
    cell.textLabel.text =  @"Test textlabel";
    cell.detailTextLabel.text = @"Test detail";

    
}
*/



@end
