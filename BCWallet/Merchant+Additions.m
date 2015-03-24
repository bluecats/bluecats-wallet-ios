//
//  Merchant+Additions.m
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "Merchant+Additions.h"
#import "Constants.h"

@implementation Merchant (Additions)

+ (Merchant *)createMerchantInContext:(NSManagedObjectContext *)context
{
    Merchant *p = [NSEntityDescription insertNewObjectForEntityForName:@"Merchant" inManagedObjectContext:context];
    return p;
}

- (void)updateWithMerchantInfo:(NSDictionary *)merchantInfo
{
    self.backgroundHexColor = [merchantInfo objectForKey:WalletMerchantBackgroundHexColorKey];
    self.textHexColor = [merchantInfo objectForKey:WalletMerchantTextHexColorKey];
    self.merchantID = [merchantInfo objectForKey:WalletMerchantIDKey];
    self.name = [merchantInfo objectForKey:WalletMerchantNameKey];
    self.logoImageURL = [merchantInfo objectForKey:WalletMerchantLogoImageURLKey];
}

@end
