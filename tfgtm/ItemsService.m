//
//  ItemsService.m
//  tfgtm
//
//  Created by Ghislain Fortin on 21/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "QSAppDelegate.h"
#import "ItemsService.h"


#pragma mark * Private interface

@interface ItemsService()

@property (nonatomic, strong)   MSSyncTable *syncTable;

@end



#pragma mark * Implementation

@implementation ItemsService

+ (ItemsService *)defaultService
{
    // Create a singleton instance of TFGTMService
    static ItemsService* service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ItemsService alloc] init];
    });
    
    return service;
}

-(ItemsService *)init
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
        
        // Create an MSSyncTable instance to allow us to work with the TodoItem table
        //        self.syncTable = [_client syncTableWithName:@"TodoItem"];
        self.syncTable = [_client syncTableWithName:@"Items"];
        
    }
    
    return self;
}

-(void)addItem:(NSDictionary *)item completion:(QSCompletionBlock)completion
{
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.syncTable insert:item completion:^(NSDictionary *result, NSError *error)
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

-(void)completeItem:(NSDictionary *)item completion:(QSCompletionBlock)completion
{
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [item mutableCopy];
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
    [self.syncTable pullWithQuery:query queryId:@"allItems" completion:^(NSError *error) {
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
