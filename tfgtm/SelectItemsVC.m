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
    NSArray *_pickerData;
}
@end

@implementation SelectItemsVC

@synthesize tableViewItems;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize Data
    
    items = [NSMutableArray new];
    
    _pickerData = @[        @"  🍎  Fruits et légumes",
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

    // Fruits et légumes
    //===================
    
    NSDictionary *item1 = @{ @"type_Item" : @YES,
                            @"name_Item" : @"Tomate",
                            @"emoji_Item" : @"🍅",
                            @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                            @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item2 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Aubergine",
                             @"emoji_Item" : @"🍆",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item3 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Maïs",
                             @"emoji_Item" : @"🌽",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item4 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Patate douce",
                             @"emoji_Item" : @"🍠",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item5 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Raisins",
                             @"emoji_Item" : @"🍇",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item6 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Melon",
                             @"emoji_Item" : @"🍈",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item7 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Pastèque",
                             @"emoji_Item" : @"🍉",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item8 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Tangerine",
                             @"emoji_Item" : @"🍊",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    
    NSDictionary *item9 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Citron",
                             @"emoji_Item" : @"🍋",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item10 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Banane",
                              @"emoji_Item" : @"🍌",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    
    NSDictionary *item11 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pomme rouge",
                              @"emoji_Item" : @"🍎",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item12 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pomme verte",
                              @"emoji_Item" : @"🍏",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };

    
    NSDictionary *item13 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poire",
                              @"emoji_Item" : @"🍐",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item14 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pêche",
                              @"emoji_Item" : @"🍑",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item15 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Cerises",
                              @"emoji_Item" : @"🍒",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item16 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Fraises",
                              @"emoji_Item" : @"🍓",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item17 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Ananas",
                              @"emoji_Item" : @"🍍",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Produits laitiers
    //===================
    
    NSDictionary *item18 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Glace",
                              @"emoji_Item" : @"🍦",
                              @"id_Category" : @"B343FAE7-CF8C-4E24-AB28-F2FA6F98DCC3",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item19 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Lait",
                              @"emoji_Item" : @"🍼",
                              @"id_Category" : @"B343FAE7-CF8C-4E24-AB28-F2FA6F98DCC3",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item21 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sorbet",
                              @"emoji_Item" : @"🍨",
                              @"id_Category" : @"B343FAE7-CF8C-4E24-AB28-F2FA6F98DCC3",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Pains et pâtisseries
    //===================
    
    NSDictionary *item22 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pain",
                              @"emoji_Item" : @"🍞",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item23 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Biscuit",
                              @"emoji_Item" : @"🍪",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item24 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Flan",
                              @"emoji_Item" : @"🍮",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item25 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Beignet",
                              @"emoji_Item" : @"🍩",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item26 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Fraisier",
                              @"emoji_Item" : @"🍰",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Snacks et friandises
    
    NSDictionary *item27 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Chocolat",
                              @"emoji_Item" : @"🍫",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item28 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Friandise",
                              @"emoji_Item" : @"🍬",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item29 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Chocolat",
                              @"emoji_Item" : @"🍫",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item30 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sucette",
                              @"emoji_Item" : @"🍭",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Viandes et poissons
    //===================
    
    NSDictionary *item31 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Boeuf",
                              @"emoji_Item" : @"🐂",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item32 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Porc",
                              @"emoji_Item" : @"🐖",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item33 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Mouton",
                              @"emoji_Item" : @"🐑",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item34 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Lapin",
                              @"emoji_Item" : @"🐇",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item35 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Cuisses de grenouille",
                              @"emoji_Item" : @"🐸",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item36 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poulet",
                              @"emoji_Item" : @"🐓",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item37 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poisson",
                              @"emoji_Item" : @"🐟",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item38 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Crevette",
                              @"emoji_Item" : @"🍤",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item39 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Oeuf",
                              @"emoji_Item" : @"🐣",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Epices et condiments
    //===================
    
    NSDictionary *item40 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Miel",
                              @"emoji_Item" : @"🍯",
                              @"id_Category" : @"6D7BC989-2D17-4C28-8ADA-61DC692254A5",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item41 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sel",
                              @"emoji_Item" : @"🍴",
                              @"id_Category" : @"6D7BC989-2D17-4C28-8ADA-61DC692254A5",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item42 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poivre",
                              @"emoji_Item" : @"🍴",
                              @"id_Category" : @"6D7BC989-2D17-4C28-8ADA-61DC692254A5",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Pâtes, riz et céréales
    //===================
    
    NSDictionary *item43 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Riz",
                              @"emoji_Item" : @"🍚",
                              @"id_Category" : @"A1DB608C-D0A6-4B86-922D-7FC2AED5D939",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item44 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pâtes",
                              @"emoji_Item" : @"🍝",
                              @"id_Category" : @"A1DB608C-D0A6-4B86-922D-7FC2AED5D939",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item45 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sushi",
                              @"emoji_Item" : @"🍣",
                              @"id_Category" : @"A1DB608C-D0A6-4B86-922D-7FC2AED5D939",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Boissons
    //===================
    
    NSDictionary *item46 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Eau",
                              @"emoji_Item" : @"💧",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item47 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Vin",
                              @"emoji_Item" : @"🍷",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item48 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Bière",
                              @"emoji_Item" : @"🍺",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item49 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Mousseux",
                              @"emoji_Item" : @"🍸",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item50 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Café",
                              @"emoji_Item" : @"☕️",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item51 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Thé",
                              @"emoji_Item" : @"🍵",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    
    // Autres
    
    NSDictionary *item52 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Soupe",
                              @"emoji_Item" : @"🍜",
                              @"id_Category" : @"A8E3A4B7-74DB-42BC-B21D-354B97955CBC",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item53 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pizza",
                              @"emoji_Item" : @"🍕",
                              @"id_Category" : @"A8E3A4B7-74DB-42BC-B21D-354B97955CBC",
                              @"id_User" : @"TFGTM_Admin" };
    
    NSDictionary *item54 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Frites",
                              @"emoji_Item" : @"🍟",
                              @"id_Category" : @"A8E3A4B7-74DB-42BC-B21D-354B97955CBC",
                              @"id_User" : @"TFGTM_Admin" };
    
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
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;{
    self.title = _pickerData[row];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath        *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableViewItems  dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    return cell;
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
