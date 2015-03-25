//
//  BCBeacon+Card.m
//  BCWallet
//
//  Created by Zach Prager on 2/16/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "BCBeacon+Card.h"
#import "BCCategory.h"
#import "BCCustomValue.h"
#import <objc/runtime.h>
#import "Constants.h"

@interface BCBeacon ()
@property (nonatomic) NSArray *merchantInfosCache;
@property (nonatomic) NSString *registerIDCache;
@end

@implementation BCBeacon (Card)

- (NSString *)registerID
{
    if (!self.registerIDCache)
    {
        NSString *registerID = nil;
        
        for (BCCustomValue *customValue in self.customValues) {
            
            if (!customValue.value || customValue.value.length == 0) continue;
            
            if ([customValue.key isEqualToString:WalletRegisterIDKey
                 ]) {
                registerID = customValue.value;
            }
        }
        self.registerIDCache = registerID;
    }
    return self.registerIDCache;
}

- (NSArray *)merchantInfos
{
    if (!self.merchantInfosCache)
    {
        NSMutableArray *merchantInfosMutable = [[NSMutableArray alloc] init];
        
        for (BCCategory *category in self.categories) {
            
            NSMutableDictionary *merchantCategoryInfo = [[NSMutableDictionary alloc] init];
            [merchantCategoryInfo setObject:@"#FFFFFF" forKey:WalletMerchantBackgroundHexColorKey];
            [merchantCategoryInfo setObject:@"#000000" forKey:WalletMerchantTextHexColorKey];
            
            for (BCCustomValue *customValue in category.customValues) {
                
                if (!customValue.value || customValue.value.length == 0) continue;
                
                if ([customValue.key isEqualToString:WalletMerchantIDKey]) {
                    [merchantCategoryInfo setObject:customValue.value forKey:WalletMerchantIDKey];
                
                } else if ([customValue.key isEqualToString:WalletMerchantNameKey]) {
                    [merchantCategoryInfo setObject:customValue.value forKey:WalletMerchantNameKey];
                
                } else if ([customValue.key isEqualToString:WalletMerchantLogoImageURLKey]) {
                    [merchantCategoryInfo setObject:customValue.value forKey:WalletMerchantLogoImageURLKey];
                }
                else if ([customValue.key isEqualToString:WalletMerchantBackgroundHexColorKey]) {
                    [merchantCategoryInfo setObject:customValue.value forKey:WalletMerchantBackgroundHexColorKey];
                }
                else if ([customValue.key isEqualToString:WalletMerchantTextHexColorKey]) {
                    [merchantCategoryInfo setObject:customValue.value forKey:WalletMerchantTextHexColorKey];
                }
            }
            
            NSString *merchantID = [merchantCategoryInfo objectForKey:WalletMerchantIDKey];
            
            if (merchantID) [merchantInfosMutable addObject:merchantCategoryInfo];
        }
        self.merchantInfosCache = merchantInfosMutable;
    }
    
    return self.merchantInfosCache;
}

- (NSArray *)merchantInfosCache
{
    return objc_getAssociatedObject(self, @selector(merchantInfosCache));
}

- (void)setMerchantInfosCache:(NSArray *)merchantInfosCache
{
    objc_setAssociatedObject(self, @selector(merchantInfosCache), merchantInfosCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)registerIDCache
{
    return objc_getAssociatedObject(self, @selector(registerIDCache));
}

- (void)setRegisterIDCache:(NSString *)registerIDCache
{
    objc_setAssociatedObject(self, @selector(registerIDCache), registerIDCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)description
{
    return self.serialNumber?: self.bluetoothAddress;
}

@end
