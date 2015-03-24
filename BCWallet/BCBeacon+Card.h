//
//  BCBeacon+Card.h
//  BCWallet
//
//  Created by Zach Prager on 2/16/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "BCBeacon.h"

@interface BCBeacon (Card)

- (NSString *)registerID;

- (NSArray *)merchantInfos;

@end
