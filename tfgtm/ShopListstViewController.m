// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

#import "ShopListsViewController.h"
#import "TFGTMService.h"
#import "QSAppDelegate.h"

#import "SSKeychain.h"
#import "SSKeychainQuery.h"


#pragma mark * Private Interface


@interface ShopListsViewController ()

// Private properties
@property (strong, nonatomic) TFGTMService *tfgtmService;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end


#pragma mark * Implementation


@implementation ShopListsViewController

#pragma mark * UIView methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the tfgtmService - this creates the Mobile Service client inside the wrapped service
    self.tfgtmService = [TFGTMService defaultService];
    
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
    [self loginAndGetData];
    //[self refresh];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    QSAppDelegate *delegate = (QSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
//    fetchRequest.entity = [NSEntityDescription entityForName:@"ShopLists" inManagedObjectContext:context];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Categories" inManagedObjectContext:context];
//    fetchRequest.entity = [NSEntityDescription entityForName:@"TodoItem" inManagedObjectContext:context];
    
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
    
    [self.tfgtmService syncData:^
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
    
    // Ask the tfgtmService to set the item's complete value to YES
    [self.tfgtmService completeItem:dict completion:nil];
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
    cell.textLabel.text = [item valueForKey:@"name_Category"];

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
    
    NSDictionary *item = @{ @"text" : self.itemText.text, @"complete" : @NO };
    [self.tfgtmService addItem:item completion:nil];
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
    MSClient *client = self.tfgtmService.client;
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
    [SSKeychain setPassword:self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken forService:@"AzureMobileServiceTutorial" account:self.tfgtmService.client.currentUser.userId];
}


- (void)loadAuthInfo {
    NSString *userid = [[SSKeychain accountsForService:@"AzureMobileServiceTutorial"][0] valueForKey:@"acct"];
    if (userid) {
        NSLog(@"userid: %@", userid);
        self.tfgtmService.client.currentUser = [[MSUser alloc] initWithUserId:userid];
        self.tfgtmService.client.currentUser.mobileServiceAuthenticationToken = [SSKeychain passwordForService:@"AzureMobileServiceTutorial" account:userid];
        
    }
}

@end