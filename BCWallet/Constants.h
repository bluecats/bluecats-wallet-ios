//
//  Constants.h
//  BCWallet
//
//  Created by Cody Singleton on 2/14/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const WalletDataTypeTinyKey;
extern NSString * const WalletMerchantIDTinyKey;
extern NSString * const WalletCardBarcodeTinyKey;
extern NSString * const WalletCardOpeningBalanceTinyKey;
extern NSString * const WalletCardCurrentBalanceTinyKey;
extern NSString * const WalletTransactionIDTinyKey;
extern NSString * const WalletRegisterIDTinyKey;
extern NSString * const WalletTransactionTotalAmountTinyKey;
extern NSString * const WalletTransactionRemainingAmountTinyKey;
extern NSString * const WalletAmountTinyKey;
extern NSString * const WalletDeviceIDTinyKey;
extern NSString * const WalletErrorsTinyKey;

extern NSString * const WalletMerchantIDKey;
extern NSString * const WalletMerchantNameKey;
extern NSString * const WalletMerchantLogoImageURLKey;
extern NSString * const WalletMerchantBackgroundHexColorKey;
extern NSString * const WalletMerchantTextHexColorKey;
extern NSString * const WalletRegisterIDKey;
extern NSString * const WalletMerchantWelcomeMessageKey;

extern NSString * const WalletUserIdDefaultsKey;

typedef enum {
    WalletDataTypeCardBalanceRequest = 0,
    WalletDataTypeCardRedemptionRequest,
    WalletDataTypeTransactionNotification
} WalletDataType;

typedef enum {
    WalletErrorSerializationFailed = 1,
    WalletErrorJSONInvalid,
    WalletErrorRequestTypeMissing,
    WalletErrorRequestTypeNotSupported,
    WalletErrorMerchantIDMissing,
    WalletErrorCardNotFound,
    WalletErrorCardBarcodeMissing,
    WalletErrorCardBalanceInsufficient,
    WalletErrorTransactionIDMissing,
    WalletErrorTransactionNotFound,
    WalletErrorTransactionCanceled,
    WalletErrorTransactionCompleted,
    WalletErrorMerchantNotSupported,
    WalletErrorSpecifiedAmountExceedsRemainingAmount
} WalletError;
