//
//  Merchant+Additions.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "Merchant.h"

@interface Merchant (Additions)

+ (Merchant *)createMerchantInContext:(NSManagedObjectContext *)context;
- (void)updateWithMerchantInfo:(NSDictionary *)merchantInfo;

@end
