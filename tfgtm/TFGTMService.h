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
#import <Foundation/Foundation.h>


#pragma mark * Block Definitions

typedef void (^QSCompletionBlock) ();

#pragma mark * TFGTMService public interface


@interface TFGTMService : NSObject

@property (nonatomic, strong)   MSClient *client;

+ (TFGTMService *)defaultService;

// ShopLists
//----------

- (void)addShopList:(NSDictionary *)shopList
     completion:(QSCompletionBlock)completion;

- (void)completeShopList:(NSDictionary *)shopList
          completion:(QSCompletionBlock)completion;

- (void)syncDataShopLists:(QSCompletionBlock)completion;

// Users
//----------

- (void)addUser:(NSDictionary *)user
         completion:(QSCompletionBlock)completion;

- (void)completeUser:(NSDictionary *)user
              completion:(QSCompletionBlock)completion;

- (void)syncDataUsers:(QSCompletionBlock)completion;


// Items
//----------


- (void)addItem:(NSDictionary *)item
     completion:(QSCompletionBlock)completion;

- (void)completeItem:(NSDictionary *)item
          completion:(QSCompletionBlock)completion;

- (void)syncDataItems:(QSCompletionBlock)completion;


// Categories
//-------------

- (void)addCategory:(NSDictionary *)category
     completion:(QSCompletionBlock)completion;

- (void)completeCategory:(NSDictionary *)category
          completion:(QSCompletionBlock)completion;

- (void)syncDataCategories:(QSCompletionBlock)completion;


// ShopListItems
//---------------

- (void)addShopListItem:(NSDictionary *)shopListItem
         completion:(QSCompletionBlock)completion;

- (void)completeShopListItem:(NSDictionary *)shopListItem
              completion:(QSCompletionBlock)completion;

- (void)syncDataShopListsItems:(QSCompletionBlock)completion;


// ShopListUsers
//---------------

- (void)addShopListUser:(NSDictionary *)shopListUser
             completion:(QSCompletionBlock)completion;

- (void)completeShopListUser:(NSDictionary *)shopListUser
                  completion:(QSCompletionBlock)completion;

- (void)syncDataShopListsUsers:(QSCompletionBlock)completion;


- (void)syncData:(QSCompletionBlock)completion;

@end
