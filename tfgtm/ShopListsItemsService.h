//
//  ShopListsItemsService.h
//  tfgtm
//
//  Created by Ghislain Fortin on 21/06/2015.
//  Copyright (c) 2015 MobileServices. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>

#pragma mark * Block Definitions

typedef void (^QSCompletionBlock) ();

#pragma mark * ShopListItemsService public interface

@interface ShopListsItemsService : NSObject

@property (nonatomic, strong)   MSClient *client;

+ (ShopListsItemsService *)defaultService;

- (void)addItem:(NSDictionary *)item
     completion:(QSCompletionBlock)completion;

- (void)completeItem:(NSDictionary *)item
          completion:(QSCompletionBlock)completion;

- (void)syncData:(QSCompletionBlock)completion;


@end
