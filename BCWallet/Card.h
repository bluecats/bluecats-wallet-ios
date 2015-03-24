//
//  Card.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Merchant;

@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSNumber * currentBalance;
@property (nonatomic, retain) NSNumber * openingBalance;
@property (nonatomic, retain) Merchant *merchant;

@end
