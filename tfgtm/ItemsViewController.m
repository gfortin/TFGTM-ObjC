//
//  ItemsViewController.m
//  tfgtm
//
//  Created by Ghislain Fortin on 21/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//


#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#import "ItemsViewController.h"
#import "ItemsService.h"
#import "QSAppDelegate.h"

#import "SSKeychain.h"
#import "SSKeychainQuery.h"


#pragma mark * Private Interface

@interface ItemsViewController ()

// Private properties
@property (strong, nonatomic) ItemsService *itemsService;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ItemsViewController

#pragma mark * UIView methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the shoplistsService - this creates the Mobile Service client inside the wrapped service
    self.itemsService = [ItemsService defaultService];
    
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
    
    [self.itemsService syncData:^
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
    cell.textLabel.text = [item valueForKey:@"name_Item"];
    cell.detailTextLabel.text = [item valueForKey:@"emoji_Item"];
    
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
    sleep(10);
    
    
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
