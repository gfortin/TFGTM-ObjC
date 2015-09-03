//
//  ShopListsItemsViewController.m
//  tfgtm
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#import "ShopListsItemsViewController.h"
#import "InvitationVC.h"
#import "TFGTMService.h"
#import "QSAppDelegate.h"

#import "SelectItemsVC.h"


#import "SSKeychain.h"
#import "SSKeychainQuery.h"


@interface ShopListsItemsViewController ()

@property (strong, nonatomic) TFGTMService *shoplistsitemsService;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end

#pragma mark * Implementation


@implementation ShopListsItemsViewController

@synthesize shopListName;
@synthesize shopListID;
@synthesize itemText;

//create default values (MUST REWRITE)
NSInteger newItems = 0;

#pragma mark * UIView methods


- (void)viewDidLoad
{
    [super viewDidLoad];

     newItems = 0;
    
    //Pour masquer le clavier
    /*
    [itemText setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    */

    self.title = shopListName;
    
    //shopListLabel.text = @"Ma liste";
    
    // Create the shoplistsitemsService - this creates the Mobile Service client inside the wrapped service
    self.shoplistsitemsService = [TFGTMService defaultService];
    
    // Let's load the user ID and token when the app starts.
    //[self loadAuthInfo];
    
    // Set this in every view controller so that the back button displays < instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
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
    
    //    fetchRequest.entity = [NSEntityDescription entityForName:@"TodoItem" inManagedObjectContext:context];
    //    fetchRequest.entity = [NSEntityDescription entityForName:@"ShopLists" inManagedObjectContext:context];
    //    fetchRequest.entity = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:context];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Items" inManagedObjectContext:context];

    //fetchRequest.entity = [NSEntityDescription entityForName:@"ShopListsItems" inManagedObjectContext:context];
    
    // show only Ananas with id
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == '1F65C2BB-D79B-4E82-BFC1-A236F1417A78'"];
    // show only non-completed items
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"complete != YES"];
    
    
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
    
//    [self.shoplistsitemsService syncDataShopListsItems:^
//    [self.shoplistsitemsService syncData:^
         [self.shoplistsitemsService syncDataItems:^
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
    
    // Ask the shoplistsitemsService to set the item's complete value to YES
//    [self.shoplistsitemsService completeShopListItem:dict completion:nil];
    [self.shoplistsitemsService completeItem:dict completion:nil];

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
    //cell.textLabel.text = [item valueForKey:@"emoji"];
    cell.textLabel.text = [item valueForKey:@"emoji_Item"];

    //cell.textLabel.text = [item valueForKey:@"id_ShopList"];
    //cell.textLabel.text = @"id_ShopList";
    //cell.detailTextLabel.text = [item valueForKey:@"text"];
    cell.detailTextLabel.text = [item valueForKey:@"name_Item"];

    //cell.textLabel.text = [item valueForKey:@"emoji_Item"];
    
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
    
    
    
    NSMutableDictionary *itemsEmoji=[[NSMutableDictionary alloc] init];
    [itemsEmoji setValue:@"🍅" forKey:@"Tomate"];
    [itemsEmoji setValue:@"🍆" forKey:@"Aubergine"];
    [itemsEmoji setValue:@"🌽" forKey:@"Maï"];
    [itemsEmoji setValue:@"🌽" forKey:@"Mai"];
    [itemsEmoji setValue:@"🍠" forKey:@"Patatedouce"];
    [itemsEmoji setValue:@"🍇" forKey:@"Raisin"];
    [itemsEmoji setValue:@"🍉" forKey:@"Pastèque"];
    [itemsEmoji setValue:@"🍊" forKey:@"Tangerine"];
    [itemsEmoji setValue:@"🍊" forKey:@"Orange"];
    [itemsEmoji setValue:@"🍋" forKey:@"Citron"];
    [itemsEmoji setValue:@"🍌" forKey:@"Banane"];
    [itemsEmoji setValue:@"🍎" forKey:@"Pomme"];
    [itemsEmoji setValue:@"🍏" forKey:@"Pommeverte"];
    [itemsEmoji setValue:@"🍏" forKey:@"Pommesverte"];
    [itemsEmoji setValue:@"🍐" forKey:@"Poire"];
    [itemsEmoji setValue:@"🍑" forKey:@"Pêche"];
    [itemsEmoji setValue:@"🍒" forKey:@"Cerise"];
    [itemsEmoji setValue:@"🍓" forKey:@"Fraise"];
    [itemsEmoji setValue:@"🍍" forKey:@"Anana"];
    [itemsEmoji setValue:@"🍦" forKey:@"Glace"];
    [itemsEmoji setValue:@"🍼" forKey:@"Lait"];
    [itemsEmoji setValue:@"🍧" forKey:@"Sorbet"];
    [itemsEmoji setValue:@"🍞" forKey:@"Pain"];
    [itemsEmoji setValue:@"🍪" forKey:@"Biscuit"];
    [itemsEmoji setValue:@"🍮" forKey:@"Flan"];
    [itemsEmoji setValue:@"🍩" forKey:@"Beignet"];
    [itemsEmoji setValue:@"🍰" forKey:@"Fraisier"];
    [itemsEmoji setValue:@"🍫" forKey:@"Chocolat"];
    [itemsEmoji setValue:@"🍬" forKey:@"Friandise"];
    [itemsEmoji setValue:@"🍬" forKey:@"Bonbon"];
    [itemsEmoji setValue:@"🍭" forKey:@"Sucette"];
    [itemsEmoji setValue:@"🐟" forKey:@"Poisson"];
    [itemsEmoji setValue:@"🐟" forKey:@"Thon"];
    [itemsEmoji setValue:@"🍤" forKey:@"Crevette"];
    [itemsEmoji setValue:@"🍗" forKey:@"Poulet"];
    [itemsEmoji setValue:@"🐓" forKey:@"Coqauvin"];
    [itemsEmoji setValue:@"🐂" forKey:@"Boeuf"];
    [itemsEmoji setValue:@"🐖" forKey:@"Porc"];
    [itemsEmoji setValue:@"🐑" forKey:@"Mouton"];
    [itemsEmoji setValue:@"🐇" forKey:@"Lapin"];
    [itemsEmoji setValue:@"🐇" forKey:@"Lapinàlamoutarde"];
    [itemsEmoji setValue:@"🐸" forKey:@"Cuissesdegrenouille"];
    [itemsEmoji setValue:@"🍯" forKey:@"Miel"];
    [itemsEmoji setValue:@"🍷" forKey:@"Vinrouge"];
    [itemsEmoji setValue:@"🍷" forKey:@"Vin"];
    [itemsEmoji setValue:@"🍹" forKey:@"Liqueur"];
    [itemsEmoji setValue:@"🍹" forKey:@"Cocktail"];
    [itemsEmoji setValue:@"🍺" forKey:@"Bière"];
    [itemsEmoji setValue:@"🍳" forKey:@"Oeuf"];
    [itemsEmoji setValue:@"🍲" forKey:@"Soupe"];
    [itemsEmoji setValue:@"🍝" forKey:@"Pâte"];
    [itemsEmoji setValue:@"🍝" forKey:@"Spaghetti"];
    [itemsEmoji setValue:@"🍟" forKey:@"Frite"];
    [itemsEmoji setValue:@"🍵" forKey:@"Thé"];
    [itemsEmoji setValue:@"☕️" forKey:@"Café"];
    [itemsEmoji setValue:@"🍫" forKey:@"Chocolat"];
    [itemsEmoji setValue:@"🍕" forKey:@"Pizza"];
    [itemsEmoji setValue:@"🍚" forKey:@"Riz"];
    [itemsEmoji setValue:@"🍚" forKey:@"Rizbasmati"];
    [itemsEmoji setValue:@"💧" forKey:@"Eau"];
    [itemsEmoji setValue:@"🎃" forKey:@"Citrouille"];
    [itemsEmoji setValue:@"🎂" forKey:@"Gâteau"];
    [itemsEmoji setValue:@"💊" forKey:@"Médicament"];
    [itemsEmoji setValue:@"🚬" forKey:@"Cigarette"];
    [itemsEmoji setValue:@"🍣" forKey:@"Sushi"];
    [itemsEmoji setValue:@"🍶" forKey:@"Saké"];
    [itemsEmoji setValue:@"🍔" forKey:@"Hamburger"];
    [itemsEmoji setValue:@"🍞" forKey:@"Paintranché"];
    [itemsEmoji setValue:@"🍮" forKey:@"Flan"];
    [itemsEmoji setValue:@"🍞" forKey:@"Baguette"];
    [itemsEmoji setValue:@"🍞" forKey:@"Croissant"];
    [itemsEmoji setValue:@"🍞" forKey:@"Painauchocolat"];
    [itemsEmoji setValue:@"🍞" forKey:@"Brioche"];
    [itemsEmoji setValue:@"🍧" forKey:@"Sorbet"];
    [itemsEmoji setValue:@"🐐" forKey:@"Fromagedechèvre"];
    [itemsEmoji setValue:@"🐄" forKey:@"Fromagedevache"];
    [itemsEmoji setValue:@"🐑" forKey:@"Fromagedebrebi"];
    [itemsEmoji setValue:@"🔥" forKey:@"Crèmebrulée"];
    [itemsEmoji setValue:@"❄️" forKey:@"Crèmefraiche"];
    [itemsEmoji setValue:@"🍝" forKey:@"Spaghetti"];
    [itemsEmoji setValue:@"🍝" forKey:@"Pâtes"];
    [itemsEmoji setValue:@"🍝" forKey:@"Penne"];
    [itemsEmoji setValue:@"🍝" forKey:@"Coquillette"];
    [itemsEmoji setValue:@"🍝" forKey:@"Torsades"];
    [itemsEmoji setValue:@"🍝" forKey:@"Ravioli"];
    [itemsEmoji setValue:@"🍝" forKey:@"Fettucini"];
    [itemsEmoji setValue:@"🍝" forKey:@"Linguine"];
    [itemsEmoji setValue:@"🌱" forKey:@"Herbesdeprovence"];
    [itemsEmoji setValue:@"🍃" forKey:@"Epicesàpoisson"];
    [itemsEmoji setValue:@"🔥" forKey:@"Pimentd'espelette"];
    [itemsEmoji setValue:@"🌱" forKey:@"Paprika"];
    [itemsEmoji setValue:@"🍃" forKey:@"Thym"];
    [itemsEmoji setValue:@"🍃" forKey:@"Coriande"];
    [itemsEmoji setValue:@"🍹" forKey:@"Cocktail"];
    [itemsEmoji setValue:@"🍹" forKey:@"Liqueur"];
    [itemsEmoji setValue:@"🍷" forKey:@"Vinrouge"];
    [itemsEmoji setValue:@"🍷" forKey:@"Vinrosé"];
    [itemsEmoji setValue:@"🍸" forKey:@"Vinblanc"];
    [itemsEmoji setValue:@"🐖" forKey:@"Hot-dog"];
    [itemsEmoji setValue:@"🍞" forKey:@"Sandwich"];
    [itemsEmoji setValue:@"🐓" forKey:@"Pouletpané"];
    [itemsEmoji setValue:@"🍲" forKey:@"Soupe"];
    [itemsEmoji setValue:@"🚬" forKey:@"Cigarette"];
    [itemsEmoji setValue:@"💊" forKey:@"Médicament"];
    [itemsEmoji setValue:@"💦" forKey:@"Shampoing"];
    [itemsEmoji setValue:@"💦" forKey:@"Savon"];
    [itemsEmoji setValue:@"💦" forKey:@"Savonàvaiselle"];
    [itemsEmoji setValue:@"🍬" forKey:@"Friandise"];
    [itemsEmoji setValue:@"🍬" forKey:@"Bonbon"];
    [itemsEmoji setValue:@"🍭" forKey:@"Sucette"];


    
    
    
    NSString *capItemText = [self.itemText.text capitalizedString];

    NSString *keyValue = capItemText;
    
    //Remove spaces
     keyValue = [keyValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //Remove numeric values
    //keyValue = [keyValue stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [keyValue length])];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"1" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"2" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"3" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"4" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"5" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"6" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"7" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"8" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"9" withString:@""];
    keyValue = [keyValue stringByReplacingOccurrencesOfString:@"0" withString:@""];
    
    NSLog(@"Remove numeric %@", keyValue);
    
    keyValue = [keyValue capitalizedString];
    
    NSLog(@"Capitalized %@", keyValue);

    //Remove the plurial "s"
    if([keyValue hasSuffix:@"s"])
    {keyValue = [keyValue substringToIndex:[keyValue length]-1];}

    NSLog(@"Last s removed %@", keyValue);
    
    
    NSString *emojiItem = [itemsEmoji valueForKey:keyValue];

    if ([itemsEmoji objectForKey:keyValue]) {
        NSLog(@"There's an object set for key %@", keyValue);
        NSLog(@"value for key %@", emojiItem);
    } else {
        NSLog(@"No object set for key %@",keyValue);
        emojiItem = @"🍴";
    }

    
    //for (NSString* key in itemsEmoji) {
    //    id value = [itemsEmoji objectForKey:key];
    //    NSLog(
    //}

    NSString *UUID_Item = [[NSUUID UUID] UUIDString];
    
    NSLog(@"GFO => UUID id_Item %@", UUID_Item);
    
    
    NSDictionary *item = @{ @"id": UUID_Item, @"emoji_Item": emojiItem, @"name_Item" : self.itemText.text, @"complete" : @NO };

    [self.shoplistsitemsService addItem:item completion:nil];

    
    
    //=== Insert ShopListsItems ======
    
    NSString *UUID_ShopListsItem = [[NSUUID UUID] UUIDString];
    NSLog(@"GFO => UUID id ShopListsItems %@", UUID_ShopListsItem);
    
    MSClient *client = [(QSAppDelegate *) [[UIApplication sharedApplication] delegate] client];
    
    NSDictionary *shopListItem = @{ @"id": UUID_ShopListsItem, @"id_item": UUID_Item, @"id_shoplist" : shopListID };
    MSTable *itemTable = [client tableWithName:@"ShopListsItems"];
    
    [itemTable insert:shopListItem completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"ShopListItem inserted, id: %@", [insertedItem objectForKey:@"id"]);
        }
    }];
    
    //===================================
    
    
    
    
    
    
    self.itemText.text = @"";
    self.itemEmoji = @"🍴";
    
    
    // BadgeNumber incrementation
    newItems = newItems + 1;
    [UIApplication sharedApplication].applicationIconBadgeNumber = newItems;

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



- (IBAction)inviteAction:(id)sender {

    
    NSLog(@"GFO => invitation");
    
    
    /*
    NSString *recipients = @"mailto:?cc=ghislain.fortin@hotmail.fr&subject=TFGTM : Invitation à ma liste de course";
    
    NSString *body = [NSString stringWithFormat:@"&body=Bonjour, Je t'invite à ma liste de course %@  à l'aide de l'application TheFirstGetTheMilk!", shopListName];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
     
     
    NSLog(@"GFO => SMS");
    
    UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Invitation!" message:@"Invitation envoyée par email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [warningAlert show];
    
    
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"sms:0648162995"]];
     
     */

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showInvitation"]) {
        InvitationVC *destViewController = segue.destinationViewController;
        destViewController.shopListName = shopListName;
        //destViewController.shopListID = shopListID;

        
    }
}

- (IBAction)unwindFromModalViewController:(UIStoryboardSegue *)segue
{
    
    if ([segue.sourceViewController isKindOfClass:[SelectItemsVC class]]) {
        SelectItemsVC *itemVC = segue.sourceViewController;
        // if the user clicked Cancel, we don't want to change the color
        if (itemVC.selectedItem) {
            
            NSString *keyValue = itemVC.selectedItem;
            if([keyValue hasPrefix: @" "])
            {keyValue = [keyValue substringFromIndex:1];}
            
            self.itemText.text = keyValue;
        }
    }
    
}


-(void)dismissKeyboard {
    [itemText resignFirstResponder];
}


@end
