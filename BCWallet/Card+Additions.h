//
//  Card+Additions.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "Card.h"

@interface Card (Additions)

+ (Card *)createCardInContext:(NSManagedObjectContext *)context;

@end
