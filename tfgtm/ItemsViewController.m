//
//  ItemsViewController.m
//  tfgtm
//
//  Created by Ghislain Fortin on 21/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//


#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#import "ItemsViewController.h"
#import "TFGTMService.h"
#import "QSAppDelegate.h"

#import "SSKeychain.h"
#import "SSKeychainQuery.h"


#pragma mark * Private Interface

@interface ItemsViewController ()

// Private properties
@property (strong, nonatomic) TFGTMService *itemsService;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ItemsViewController

#pragma mark * UIView methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the shoplistsService - this creates the Mobile Service client inside the wrapped service
    self.itemsService = [TFGTMService defaultService];
    
    // Let's load the user ID and token when the app starts.
    [self loadAuthInfo];
    
    // have refresh control reload all data from server
    [self.refreshControl addTarget:self
                            action:@selector(onRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    // load the data
    //[self loginAndGetData];
    [self refresh];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    QSAppDelegate *delegate = (QSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"Items" inManagedObjectContext:context];
    
    
    // show only non-completed items
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
    
    // sort by item text
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ms_createdAt" ascending:YES]];
    
    // Note: if storing a lot of data, you should specify a cache for the last parameter
    // for more information, see Apple's documentation: http://go.microsoft.com/fwlink/?LinkId=524591&clcid=0x409
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void) refresh
{
    [self.refreshControl beginRefreshing];
    
    [self.itemsService syncDataItems:^
     {
         [self.refreshControl endRefreshing];
     }];
}


#pragma mark * UITableView methods


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find item that was commited for editing (completed)
    NSManagedObject *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // map to a dictionary to pass to Mobile Services SDK
    NSDictionary *dict = [MSCoreDataStore tableItemFromManagedObject:item];
    
    // Change the appearance to look greyed out until we remove the item
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor grayColor];
    
    // Ask the shoplistsService to set the item's complete value to YES
    [self.itemsService completeItem:dict completion:nil];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find the item that is about to be edited
    NSManagedObject *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // If the item is complete, then this is just pending upload. Editing is not allowed
    if ([[item valueForKey:@"complete"] boolValue])
    {
        return UITableViewCellEditingStyleNone;
    }
    
    // Otherwise, allow the delete button to appear
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Customize the Delete button to say "complete" / "Supprimer"
    return @"Supprimer";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Set the label on the cell and make sure the label color is black (in case this cell
    // has been reused and was previously greyed out
    cell.textLabel.textColor = [UIColor blackColor];
    //    cell.textLabel.text = [item valueForKey:@"text"];
    //    cell.textLabel.text = [item valueForKey:@"name_Category"];
    
    //cell.textLabel.text = [item valueForKey:@"name_Item"];
    //cell.detailTextLabel.text = [item valueForKey:@"emoji_Item"];

    cell.detailTextLabel.text = [item valueForKey:@"name_Item"];
    cell.textLabel.text = [item valueForKey:@"emoji_Item"];

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;  // Always a single section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark * UITextFieldDelegate methods


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder]; // hide the on-screen keyboard
    return YES;
}


#pragma mark * UI Actions


- (IBAction)onAdd:(id)sender
{
    if (self.itemText.text.length  == 0)
    {
        return;
    }
    
    //    NSDictionary *item = @{ @"text" : self.itemText.text, @"complete" : @NO };
    NSDictionary *item = @{ @"type_Item" : @YES,
                            @"name_Item" : self.itemText.text,
                            @"emoji_Item" : @"🍴",
                            @"id_Category" : @"Fruits et légumes",
                            @"id_User" : @"ghislain.fortin@hotmail.fr" };
    [self.itemsService addItem:item completion:nil];
    self.itemText.text = @"";
}

- (IBAction)onAddINIT:(id)sender
{
    if (self.itemText.text.length  == 0)
    {
        return;
    }
    
    //    NSDictionary *item = @{ @"text" : self.itemText.text, @"complete" : @NO };
    
    // Fruits et légumes
    //===================

    NSDictionary *item = @{ @"type_Item" : @YES,
                            @"name_Item" : @"Tomate",
                            @"emoji_Item" : @"🍅",
                            @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                            @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item completion:nil];
    sleep(5);

    NSDictionary *item2 = @{ @"type_Item" : @YES,
                            @"name_Item" : @"Aubergine",
                            @"emoji_Item" : @"🍆",
                            @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                            @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item2 completion:nil];sleep(5);
    sleep(5);
    
    NSDictionary *item3 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Maïs",
                             @"emoji_Item" : @"🌽",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item3 completion:nil];
    sleep(5);
    
    NSDictionary *item4 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Patate douce",
                             @"emoji_Item" : @"🍠",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item4 completion:nil];
    sleep(5);
    
    NSDictionary *item5 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Raisins",
                             @"emoji_Item" : @"🍇",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item5 completion:nil];
    sleep(5);
    
    NSDictionary *item6 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Melon",
                             @"emoji_Item" : @"🍈",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item6 completion:nil];
    sleep(5);
    
    NSDictionary *item7 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Pastèque",
                             @"emoji_Item" : @"🍉",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item7 completion:nil];
    sleep(5);
    
    NSDictionary *item8 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Tangerine",
                             @"emoji_Item" : @"🍊",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item8 completion:nil];
    sleep(5);
    
    
    NSDictionary *item9 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Citron",
                             @"emoji_Item" : @"🍋",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item9 completion:nil];
    sleep(5);
    
    NSDictionary *item10 = @{ @"type_Item" : @YES,
                             @"name_Item" : @"Banane",
                             @"emoji_Item" : @"🍌",
                             @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                             @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item10 completion:nil];
    sleep(5);
    
    
    NSDictionary *item11 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pomme rouge",
                              @"emoji_Item" : @"🍎",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item11 completion:nil];
    sleep(5);
    
    NSDictionary *item12 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pomme verte",
                              @"emoji_Item" : @"🍏",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item12 completion:nil];
    sleep(5);
    
    
    NSDictionary *item13 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poire",
                              @"emoji_Item" : @"🍐",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item13 completion:nil];
    sleep(5);
    
    NSDictionary *item14 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pêche",
                              @"emoji_Item" : @"🍑",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item14 completion:nil];
    sleep(5);
    
    NSDictionary *item15 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Cerises",
                              @"emoji_Item" : @"🍒",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item15 completion:nil];
    sleep(5);
    
    NSDictionary *item16 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Fraises",
                              @"emoji_Item" : @"🍓",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item16 completion:nil];
    sleep(5);
    
    NSDictionary *item17 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Ananas",
                              @"emoji_Item" : @"🍍",
                              @"id_Category" : @"E05DAA91-6E26-4394-B3AC-5ED08AFDF1E0",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item17 completion:nil];
    sleep(5);
    
    // Produits laitiers
    //===================
    
    NSDictionary *item18 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Glace",
                              @"emoji_Item" : @"🍦",
                              @"id_Category" : @"B343FAE7-CF8C-4E24-AB28-F2FA6F98DCC3",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item18 completion:nil];
    sleep(5);
    
    NSDictionary *item19 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Lait",
                              @"emoji_Item" : @"🍼",
                              @"id_Category" : @"B343FAE7-CF8C-4E24-AB28-F2FA6F98DCC3",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item19 completion:nil];
    sleep(5);
    
    NSDictionary *item21 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sorbet",
                              @"emoji_Item" : @"🍨",
                              @"id_Category" : @"B343FAE7-CF8C-4E24-AB28-F2FA6F98DCC3",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item21 completion:nil];
    sleep(5);
    
    // Pains et pâtisseries
    //===================
    
    NSDictionary *item22 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pain",
                              @"emoji_Item" : @"🍞",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item22 completion:nil];
    sleep(5);
    
    NSDictionary *item23 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Biscuit",
                              @"emoji_Item" : @"🍪",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item23 completion:nil];
    sleep(5);
    
    NSDictionary *item24 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Flan",
                              @"emoji_Item" : @"🍮",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item24 completion:nil];
    sleep(5);
    
    NSDictionary *item25 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Beignet",
                              @"emoji_Item" : @"🍩",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item25 completion:nil];
    sleep(5);
    
    NSDictionary *item26 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Fraisier",
                              @"emoji_Item" : @"🍰",
                              @"id_Category" : @"3554D086-8D89-4B04-9D8D-468834648BA9",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item26 completion:nil];
    sleep(5);
    
    // Snacks et friandises
    
    NSDictionary *item27 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Chocolat",
                              @"emoji_Item" : @"🍫",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item27 completion:nil];
    sleep(5);
    
    NSDictionary *item28 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Friandise",
                              @"emoji_Item" : @"🍬",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item28 completion:nil];
    sleep(5);
    
    NSDictionary *item29 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Chocolat",
                              @"emoji_Item" : @"🍫",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item29 completion:nil];
    sleep(5);
    
    NSDictionary *item30 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sucette",
                              @"emoji_Item" : @"🍭",
                              @"id_Category" : @"493C4435-E189-445D-BC9B-07772E30F6B5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item30 completion:nil];
    sleep(5);
    
    // Viandes et poissons
    //===================
    
    NSDictionary *item31 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Boeuf",
                              @"emoji_Item" : @"🐂",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item31 completion:nil];
    sleep(5);
    
    NSDictionary *item32 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Porc",
                              @"emoji_Item" : @"🐖",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item32 completion:nil];
    sleep(5);
    
    NSDictionary *item33 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Mouton",
                              @"emoji_Item" : @"🐑",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item33 completion:nil];
    sleep(5);
    
    NSDictionary *item34 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Lapin",
                              @"emoji_Item" : @"🐇",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item34 completion:nil];
    sleep(5);
    
    NSDictionary *item35 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Cuisses de grenouille",
                              @"emoji_Item" : @"🐸",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item35 completion:nil];
    sleep(5);
    
    NSDictionary *item36 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poulet",
                              @"emoji_Item" : @"🐓",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item36 completion:nil];
    sleep(5);
    
    NSDictionary *item37 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poisson",
                              @"emoji_Item" : @"🐟",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item37 completion:nil];
    sleep(5);
    
    NSDictionary *item38 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Crevette",
                              @"emoji_Item" : @"🍤",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item38 completion:nil];
    sleep(5);
    
    NSDictionary *item39 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Oeuf",
                              @"emoji_Item" : @"🐣",
                              @"id_Category" : @"5C1FE337-AA80-4C40-8254-CDD6E1894533",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item39 completion:nil];
    sleep(5);
    
    // Epices et condiments
    //===================
    
    NSDictionary *item40 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Miel",
                              @"emoji_Item" : @"🍯",
                              @"id_Category" : @"6D7BC989-2D17-4C28-8ADA-61DC692254A5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item40 completion:nil];
    sleep(5);
    
    NSDictionary *item41 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sel",
                              @"emoji_Item" : @"🍴",
                              @"id_Category" : @"6D7BC989-2D17-4C28-8ADA-61DC692254A5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item41 completion:nil];
    sleep(5);
    
    NSDictionary *item42 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Poivre",
                              @"emoji_Item" : @"🍴",
                              @"id_Category" : @"6D7BC989-2D17-4C28-8ADA-61DC692254A5",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item42 completion:nil];
    sleep(5);
    
    // Pâtes, riz et céréales
    //===================
    
    NSDictionary *item43 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Riz",
                              @"emoji_Item" : @"🍚",
                              @"id_Category" : @"A1DB608C-D0A6-4B86-922D-7FC2AED5D939",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item43 completion:nil];
    sleep(5);
    
    NSDictionary *item44 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pâtes",
                              @"emoji_Item" : @"🍝",
                              @"id_Category" : @"A1DB608C-D0A6-4B86-922D-7FC2AED5D939",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item44 completion:nil];
    sleep(5);
    
    NSDictionary *item45 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Sushi",
                              @"emoji_Item" : @"🍣",
                              @"id_Category" : @"A1DB608C-D0A6-4B86-922D-7FC2AED5D939",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item45 completion:nil];
    sleep(5);
    
    // Boissons
    //===================
    
    NSDictionary *item46 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Eau",
                              @"emoji_Item" : @"💧",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item46 completion:nil];
    sleep(5);
    
    NSDictionary *item47 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Vin",
                              @"emoji_Item" : @"🍷",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item47 completion:nil];
    sleep(5);
    
    NSDictionary *item48 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Bière",
                              @"emoji_Item" : @"🍺",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item48 completion:nil];
    sleep(5);
    
    NSDictionary *item49 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Mousseux",
                              @"emoji_Item" : @"🍸",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item49 completion:nil];
    sleep(5);
    
    NSDictionary *item50 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Café",
                              @"emoji_Item" : @"☕️",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item50 completion:nil];
    sleep(5);
    
    NSDictionary *item51 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Thé",
                              @"emoji_Item" : @"🍵",
                              @"id_Category" : @"1B6C6848-C545-4E2E-BB36-2B6ED8A687E6",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item51 completion:nil];
    sleep(5);
    
    // Autres
    
    NSDictionary *item52 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Soupe",
                              @"emoji_Item" : @"🍜",
                              @"id_Category" : @"A8E3A4B7-74DB-42BC-B21D-354B97955CBC",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item52 completion:nil];
    sleep(5);
    
    NSDictionary *item53 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Pizza",
                              @"emoji_Item" : @"🍕",
                              @"id_Category" : @"A8E3A4B7-74DB-42BC-B21D-354B97955CBC",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item53 completion:nil];
    sleep(5);
    
    NSDictionary *item54 = @{ @"type_Item" : @YES,
                              @"name_Item" : @"Frites",
                              @"emoji_Item" : @"🍟",
                              @"id_Category" : @"A8E3A4B7-74DB-42BC-B21D-354B97955CBC",
                              @"id_User" : @"TFGTM_Admin" };
    [self.itemsService addItem:item54 completion:nil];
    sleep(5);

    
    
    
    
    self.itemText.text = @"";
}



- (void)onRefresh:(id) sender
{
    [self refresh];
}

#pragma mark * NSFetchedResultsController methods


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
    });
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableView *tableView = self.tableView;
        
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [tableView reloadRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                
                // note: Apple samples show a call to configureCell here; this is incorrect--it can result in retrieving the
                // wrong index when rows are reordered. For more information, see http://go.microsoft.com/fwlink/?LinkID=524590&clcid=0x409
                // [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath]; // wrong! call reloadRows instead
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray
                                                   arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray
                                                   arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    });
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            default:
                break;
        }
    });
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView endUpdates];
    });
}


- (void) loginAndGetData
{
    MSClient *client = self.itemsService.client;
    if (client.currentUser != nil) {
        return;
    }
    
    [client loginWithProvider:@"facebook" controller:self animated:YES completion:^(MSUser *user, NSError *error) {
        
        // Sauvegarde de l'authentification
        [self saveAuthInfo];
        
        [self refresh];
    }];
}

// Store Authentication Tokens in App
// https://azure.microsoft.com/en-us/documentation/articles/mobile-services-ios-get-started-users/


- (void) saveAuthInfo {
    [SSKeychain setPassword:self.itemsService.client.currentUser.mobileServiceAuthenticationToken forService:@"AzureMobileServiceTutorial" account:self.itemsService.client.currentUser.userId];
}


- (void)loadAuthInfo {
    NSString *userid = [[SSKeychain accountsForService:@"AzureMobileServiceTutorial"][0] valueForKey:@"acct"];
    if (userid) {
        NSLog(@"userid: %@", userid);
        self.itemsService.client.currentUser = [[MSUser alloc] initWithUserId:userid];
        self.itemsService.client.currentUser.mobileServiceAuthenticationToken = [SSKeychain passwordForService:@"AzureMobileServiceTutorial" account:userid];
        
    }
}

@end
