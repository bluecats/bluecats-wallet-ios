//
//  Merchant.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface Merchant : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * backgroundHexColor;
@property (nonatomic, retain) NSString * textHexColor;
@property (nonatomic, retain) NSString * merchantID;
@property (nonatomic, retain) NSString * logoImageURL;
@property (nonatomic, retain) NSSet *cards;
@end

@interface Merchant (CoreDataGeneratedAccessors)

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end
