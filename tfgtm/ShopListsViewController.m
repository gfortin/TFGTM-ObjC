//  TFGTM
//
//  Created by Ghislain Fortin on 20/06/2015.
//  Copyright (c) 2015 Ghislain FORTIN. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#import "ShopListsViewController.h"
#import "ShopListsItemsViewController.h"
#import "TFGTMService.h"
#import "QSAppDelegate.h"

#import "SSKeychain.h"
#import "SSKeychainQuery.h"


#pragma mark * Private Interface


@interface ShopListsViewController ()

// Private properties
@property (strong, nonatomic) TFGTMService *shoplistsService;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end


#pragma mark * Implementation


@implementation ShopListsViewController

@synthesize shopListSelect;
@synthesize shopListSelectID;
@synthesize strUserID;
@synthesize itemText;


#pragma mark * UIView methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Pour masquer le clavier
    /*
    [itemText setDelegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
     */
    
    
    // Create the shoplistsService - this creates the Mobile Service client inside the wrapped service
    self.shoplistsService = [TFGTMService defaultService];
    
    // Let's load the user ID and token when the app starts.
    //[self loadAuthInfo];
    
    NSLog(@"GFO => strUserID : %@", strUserID );
    
    // have refresh control reload all data from server
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Synchronisation des listes de courses..."];
    [self.refreshControl addTarget:self
                            action:@selector(onRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    

    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }

    // Set this in every view controller so that the back button displays < instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];


    
    // load the data
    //[self loginAndGetData];
    [self refresh];
}


// Requête principale
//====================

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    QSAppDelegate *delegate = (QSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;

    fetchRequest.entity = [NSEntityDescription entityForName:@"ShopLists" inManagedObjectContext:context];
    
    // A mettre en place une liste de ShopListsUsers
    
    
    if (strUserID) {
        //=== Read ShopListsUsers ======
        
        NSLog(@"GFO => Read ShopListsUsers for userID : %@", strUserID);
        
        MSClient *client = [(QSAppDelegate *) [[UIApplication sharedApplication] delegate] client];
        
        NSPredicate *predicateShopListUser = [NSPredicate predicateWithFormat:@"id_user == %@", strUserID];
        MSTable *table = [client tableWithName:@"ShopListsUsers"];
        
        NSMutableArray *shopListsID;
        
        // Query the ShopListsUsers table and update the items property with the results from the service
        [table readWithPredicate:predicateShopListUser completion:^(MSQueryResult *result, NSError *error) {
            if(error) {
                NSLog(@"ERROR %@", error);
            } else {
                for(NSDictionary *item in result.items) {
                    NSLog(@"ShopListsUsers id_shoplist: %@", [item objectForKey:@"id_shoplist"]);
                    [shopListsID addObject:[item objectForKey:@"id_shoplist"]];
                }
            }
        }];
        NSLog(@"GFO 1 : %@",shopListsID[1]);
        NSLog(@"GFO 2 : %@",shopListsID[2]);
    }
    
    //NSArray *slid = shopListsID;
    
    //===================================
    
    // show only picnic and repas pour demain
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == '263E498C-81D4-4B9B-B928-EBBA45F16EC0' OR id == '43EB2B10-4410-42DE-B8C4-D3A13EB8F727'"];
    
    //NSArray *shopListsIds = [NSArray arrayWithObjects: @"54121F41-F3C5-4349-939C-C9ECE7BCA457",
    //                                                @"897C1A91-00ED-4CAF-B3AA-54F7A3C7F2DA", nil];
    
    // show only non-completed items
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"complete != YES AND id IN %@", predicateIN];
    //    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"complete != YES AND id IN %@", shopListsIds];
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
    
    [self.shoplistsService syncDataShopLists:^

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
    [self.shoplistsService completeShopList:dict completion:nil];
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


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    shopListSelect = [item valueForKey:@"name_ShopList"];
    shopListSelectID = [item valueForKey:@"id"];

    NSLog(@"Select shopList %@ %@", shopListSelect, shopListSelectID);
    return true;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Set the label on the cell and make sure the label color is black (in case this cell
    // has been reused and was previously greyed out
    cell.textLabel.textColor = [UIColor blackColor];
//    cell.textLabel.text = [item valueForKey:@"text"];
//    cell.textLabel.text = [item valueForKey:@"name_Category"];
//    cell.textLabel.text = [item valueForKey:@"name_ShopList"];
//    cell.detailTextLabel.text = [item valueForKey:@"name_ShopList"];
//    cell.textLabel.text = @"🍴";
    cell.textLabel.text = [item valueForKey:@"name_ShopList"];
    
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
    
    NSString *UUID_ShopList = [[NSUUID UUID] UUIDString];
    
    NSLog(@"GFO => UUID id_ShopList %@", UUID_ShopList);

    //    NSDictionary *item = @{ @"text" : self.itemText.text, @"complete" : @NO };
    NSDictionary *item = @{ @"id": UUID_ShopList, @"name_ShopList" : self.itemText.text, @"complete" : @NO };
    [self.shoplistsService addShopList:item completion:nil];
    
    
    //=== Insert ShopListsUsers ======
    if (strUserID)
    {
        NSString *UUID_ShopListsUsers = [[NSUUID UUID] UUIDString];
        NSLog(@"GFO => UUID id ShopListsUsers %@", UUID_ShopListsUsers);
        
        MSClient *client = [(QSAppDelegate *) [[UIApplication sharedApplication] delegate] client];
        
        NSDictionary *shopListUser = @{ @"id": UUID_ShopListsUsers, @"id_user": strUserID, @"id_shoplist" : UUID_ShopList };
        MSTable *itemTable = [client tableWithName:@"ShopListsUsers"];
        
        [itemTable insert:shopListUser completion:^(NSDictionary *insertedItem, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"ShopListUser inserted, id: %@", [insertedItem objectForKey:@"id"]);
            }
        }];
    }
    
    
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showShopListItems"]) {
        ShopListsItemsViewController *destViewController = segue.destinationViewController;
        destViewController.shopListName = shopListSelect;
        destViewController.shopListID = shopListSelectID;
    }
}

-(void)dismissKeyboard {
    [itemText resignFirstResponder];
}


- (IBAction)settings:(id)sender {
    //code for opening settings app in iOS 8
    [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
}


@end
