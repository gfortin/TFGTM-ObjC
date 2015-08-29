//
//  SelectItemsVC.m
//  tfgtm
//
//  Created by Ghislain Fortin on 14/07/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//


#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#import "SelectItemsVC.h"
#import "TFGTMService.h"
#import "QSAppDelegate.h"

#import "SSKeychain.h"
#import "SSKeychainQuery.h"



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

@property (strong, nonatomic) TFGTMService *shoplistsitemsService;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


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
                        @"🍅 Tomates",
                        @"🍌 Bananes",
                        @"🍐 Poires",
                        @"🍇 Raisins",
                        @"🍍 Ananas",
                        @"🍆 Aubergine"
                        ];
    
    
    _viandesPoissons = @[ @"🐓 Poulet",
                          @"🐂 Boeuf",
                          @"🐖 Porc",
                          @"🐟 Thon",
                          @"🐓 Coq au vin",
                          @"🐑 Mouton",
                          @"🐇 Lapin à la moutarde",
                          @"🐸 Cuisses de grenouilles",
                          @"🍣 Sushi",
                          @"🍤 Crevette"
                        ];
    
    _painsPatisseries = @[ @"🍞 Pain tranché",
                           @"🍪 Biscuits",
                           @"🍮 Flan",
                           @"🍩 Beignets",
                           @"🍰 Fraisier",
                           @"🎂 Gâteau",
                           @"🍞 Baguette",
                           @"🍞 Croissant",
                           @"🍞 Pain au chocolat",
                           @"🍞 Brioche"
                           ];

    _produitsLaitiers = @[ @"🍧 Sorbet",
                           @"🍼 Lait",
                           @"🍦 Glace",
                           @"🍒 Yaourt",
                           @"🐐 Fromage de chèvre",
                           @"🐄 Fromage de vache",
                           @"🐑 Fromage de brebis",
                           @"🐄 Camembert",
                           @"❄️ Crème fraiche",
                           @"🔥 Crème brulée"
                           ];

    _patesRiz = @[ @"🍝 Spaghettis",
                   @"🍝 Pâtes",
                   @"🍚 Riz",
                   @"🍒 Pennes",
                   @"🍝 Coquillettes",
                   @"🍝 Torsades",
                   @"🍝 Raviolis",
                   @"🍝 Fetutinis",
                   @"🍝 Linguinis",
                   @"🍚 Riz basmati"
                   ];

    _epices = @[ @"🍴 Curry",
                 @"🌱 Herbes de provence",
                 @"🍃 Epices à poisson",
                 @"🔥 Piment d'espelette",
                 @"🌱 Paprika",
                 @"🍴 Sel",
                 @"🍴 Poivre",
                 @"🍴 Cumin",
                 @"🍃 Thym",
                 @"🍃 Coriande"
                 ];

    _boissons =@[ @"💧 Eau",
                  @"☕️ Café",
                  @"🍵 Thé",
                  @"🍺 Bières",
                  @"🍹 Cocktail",
                  @"🍹 Liqueur",
                  @"🍷 Vin rouge",
                  @"🍷 Vin rosé",
                  @"🍸 Vin blanc",
                  @"🍶 Saké"
                  ];

    _snacks = @[ @"🍕 Pizza",
                 @"🍟 Frites",
                 @"🍔 Hamburger",
                 @"🍫 Chocolat",
                 @"🐖 Hot-dogs",
                 @"🍞 Sandwich",
                 @"🐓 Poulet pané",
                 @"🍲 Soupe",
                 @"🍴 Panini",
                 @"🍴 Bretzel"
               ];
    
    _autres = @[ @"🚬 Cigarettes",
                 @"💊 Médicament",
                 @"🍳 Oeufs",
                 @"🍯 Miel",
                 @"🍭 Sucettes",
                 @"🍬 Bonbon",
                 @"🍬 Friandise",
                 @"💦 Shampoing",
                 @"💦 Savon",
                 @"💦 Savon à vaiselle"
               ];


    
    
    [self.items addObjectsFromArray:_fruitsLegumes];
    
    
    // Connect data
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;

    self.tableViewItems.dataSource = self;
    self.tableViewItems.delegate = self;
    self.tableViewItems.allowsMultipleSelection = true;

    
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

// returns the view provided by the delegate via pickerView:viewForRow:forComponent:reusingView:
// or nil if the row/component is not visible or the delegate does not implement
// pickerView:viewForRow:forComponent:reusingView:
- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.view;
}


// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"GFO => ADD %@, %@", cell.textLabel.text, cell.detailTextLabel.text);
    
    NSString *UUID_Item = [[NSUUID UUID] UUIDString];
    
    NSLog(@"GFO => UUID id_Item %@", UUID_Item);
    
    //NSDictionary *item = @{ @"emoji": emojiItem, @"user": @"ghislain.fortin@hotmail.fr", @"text" : self.itemText.text, @"complete" : @NO };
    NSDictionary *item = @{ @"id": UUID_Item, @"emoji_Item": cell.textLabel.text, @"name_Item" : cell.detailTextLabel.text, @"complete" : @NO };
    //NSDictionary *item = @{ @"id_ShopList" : self.itemText.text };
    //    [self.shoplistsitemsService addShopListItem:item completion:nil];
    
    
    //GFOGFO
    [self.shoplistsitemsService addItem:item completion:nil];
    

    
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Deselect  %@, %@", cell.textLabel.text, cell.detailTextLabel.text);
    
    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // hide the on-screen keyboard
    return YES;
}


- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
 
    NSLog(@"GFO => Back button pushed");
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
