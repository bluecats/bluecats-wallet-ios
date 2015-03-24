//
//  Card+Additions.m
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "Card+Additions.h"

@implementation Card (Additions)

+ (Card *)createCardInContext:(NSManagedObjectContext *)context
{
    Card *p = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:context];
    return p;
}

@end
