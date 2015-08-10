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
#import "TFGTMService.h"
#import "QSAppDelegate.h"


#pragma mark * Private interface


@interface TFGTMService()


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong)   MSSyncTable *syncShopLists;

@property (nonatomic, strong)   MSSyncTable *syncUsers;
@property (nonatomic, strong)   MSSyncTable *syncItems;
@property (nonatomic, strong)   MSSyncTable *syncCategories;
@property (nonatomic, strong)   MSSyncTable *syncShopListsItems;
@property (nonatomic, strong)   MSSyncTable *syncShopListsUsers;

@property (nonatomic, strong)   MSSyncTable *syncTable;



@end


#pragma mark * Implementation


@implementation TFGTMService


+ (TFGTMService *)defaultService
{
    // Create a singleton instance of TFGTMService
    static TFGTMService* service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[TFGTMService alloc] init];
    });
    
    return service;
}

-(TFGTMService *)init
{
    self = [super init];
    
    if (self)
    {
        // Initialize the Mobile Service client with your URL and key   
        self.client = [MSClient clientWithApplicationURLString:@"https://tfgtm.azure-mobile.net/"
                                                applicationKey:@"DorhkRlJvPtclEoBghfFIobYnguVff69"];
    
        QSAppDelegate *delegate = (QSAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        MSCoreDataStore *store = [[MSCoreDataStore alloc] initWithManagedObjectContext:context];
        
        self.client.syncContext = [[MSSyncContext alloc] initWithDelegate:nil dataSource:store callback:nil];
        
        // Create MSSyncTable instances to allow us to work with the tables
 

        self.syncShopLists  = [_client syncTableWithName:@"ShopLists"];

        self.syncUsers      = [_client syncTableWithName:@"Users"];
        self.syncItems      = [_client syncTableWithName:@"Items"];
        self.syncCategories = [_client syncTableWithName:@"Categories"];
        self.syncShopListsItems = [_client syncTableWithName:@"ShopListsItems"];
        self.syncShopListsUsers = [_client syncTableWithName:@"ShopListsUsers"];

        self.syncTable = [_client syncTableWithName:@"TodoItem"];

        
    }
    
    return self;
}


// ToDoItem
//==========

-(void)addTodoItem:(NSDictionary *)todoitem completion:(QSCompletionBlock)completion
{
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.syncTable insert:todoitem completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncData: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)completeTodoItem:(NSDictionary *)todoitem completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [todoitem mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncTable update:mutable completion:^(NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncData: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)syncData:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullData:completion];
    }];
}

-(void)pullData:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncTable query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncTable pullWithQuery:query queryId:@"allTodoItems" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}


//=========================================




-(void)addShopList:(NSDictionary *)shopList completion:(QSCompletionBlock)completion
{
    // Insert the shopList into the ShopLists table and add to the shopLists array on completion
    [self.syncShopLists insert:shopList completion:^(NSDictionary *result, NSError *error)
    {
        [self logErrorIfNotNil:error];
    
        [self syncDataShopLists: ^{
            // Let the caller know that we finished
            if (completion != nil) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }
        }];
    }];
}

-(void)completeShopList:(NSDictionary *)shopList completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [shopList mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncShopLists update:mutable completion:^(NSError *error)
    {
        [self logErrorIfNotNil:error];
        
        [self syncDataShopLists: ^{
            // Let the caller know that we finished
            if (completion != nil) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }
        }];
    }];
}

-(void)syncDataShopLists:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullDataShopLists:completion];
    }];
}

-(void)pullDataShopLists:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncShopLists query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncShopLists pullWithQuery:query queryId:@"allShopLists" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}



-(void)addUser:(NSDictionary *)user completion:(QSCompletionBlock)completion
{
    // Insert the user into the Users table and add to the users array on completion
    [self.syncUsers insert:user completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataUsers: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)completeUser:(NSDictionary *)user completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [user mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncUsers update:mutable completion:^(NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataUsers: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)syncDataUsers:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullDataUsers:completion];
    }];
}

-(void)pullDataUsers:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncUsers query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncUsers pullWithQuery:query queryId:@"allUsers" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}


 


-(void)addItem:(NSDictionary *)item completion:(QSCompletionBlock)completion
{
    
    NSLog(@"GFO => addItem : %@", item);
    
    // Insert the Item into the Items table and add to the items array on completion
    [self.syncItems insert:item completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataItems: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)completeItem:(NSDictionary *)item completion:(QSCompletionBlock)completion
{
    NSLog(@"Complete item %@",item);
    
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [item mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncItems update:mutable completion:^(NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataItems: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)syncDataItems:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullDataItems:completion];
    }];
}

-(void)pullDataItems:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncItems query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncItems pullWithQuery:query queryId:@"allItems" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}

-(void)addCategory:(NSDictionary *)category completion:(QSCompletionBlock)completion
{
    // Insert the user into the Users table and add to the users array on completion
    [self.syncUsers insert:category completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataCategories: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)completeCategory:(NSDictionary *)category completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [category mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncCategories update:mutable completion:^(NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataCategories: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)syncDataCategories:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullDataCategories:completion];
    }];
}

-(void)pullDataCategories:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncCategories query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncCategories pullWithQuery:query queryId:@"allCategories" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}


 
-(void)addShopListItem:(NSDictionary *)shopListItem completion:(QSCompletionBlock)completion
{
    // Insert the shopList into the ShopLists table and add to the shopLists array on completion
    [self.syncShopListsItems insert:shopListItem completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataShopListsItems: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)completeShopListItem:(NSDictionary *)shopListItem completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [shopListItem mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncShopListsItems update:mutable completion:^(NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataShopListsItems: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)syncDataShopListsItems:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullDataShopListsItems:completion];
    }];
}

-(void)pullDataShopListsItems:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncShopListsItems query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncShopListsItems pullWithQuery:query queryId:@"allShopListsItems" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}

-(void)addShopListUser:(NSDictionary *)shopListUser completion:(QSCompletionBlock)completion
{
    // Insert the shopList into the ShopLists table and add to the shopLists array on completion
    [self.syncShopListsUsers insert:shopListUser completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataShopListsUsers: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)completeShopListUser:(NSDictionary *)shopListUser completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [shopListUser mutableCopy];
    [mutable setObject:@YES forKey:@"complete"];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.syncShopListsUsers update:mutable completion:^(NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         [self syncDataShopListsUsers: ^{
             // Let the caller know that we finished
             if (completion != nil) {
                 dispatch_async(dispatch_get_main_queue(), completion);
             }
         }];
     }];
}

-(void)syncDataShopListsUsers:(QSCompletionBlock)completion
{
    // push all changes in the sync context, then pull new data
    [self.client.syncContext pushWithCompletion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        [self pullDataShopListsUsers:completion];
    }];
}

-(void)pullDataShopListsUsers:(QSCompletionBlock)completion
{
    MSQuery *query = [self.syncShopListsUsers query];
    
    // Pulls data from the remote server into the local table.
    // We're pulling all items and filtering in the view
    // query ID is used for incremental sync
    [self.syncShopListsUsers pullWithQuery:query queryId:@"allShopListsUsers" completion:^(NSError *error) {
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}



- (void)logErrorIfNotNil:(NSError *) error
{
    if (error)
    {
        NSLog(@"ERROR %@", error);
    }
}

@end
