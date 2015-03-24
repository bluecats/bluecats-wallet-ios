//
//  ComparisonUtilities.h
//  BCWalletOSX
//
//  Created by Cody Singleton on 2/22/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComparisonUtilities : NSObject

+ (NSComparisonResult)compareOneDouble:(double)one withAnotherDouble:(double)another;

+ (BOOL)isOneDouble:(double)one lessThanOrEqualToAnotherDouble:(double)another;

+ (BOOL)isOneDouble:(double)one lessThanAnotherDouble:(double)another;

+ (BOOL)isOneDouble:(double)one greaterThanOrEqualToAnotherDouble:(double)another;

+ (BOOL)isOneDouble:(double)one greaterThanAnotherDouble:(double)another;

+ (NSComparisonResult)compareOneFloat:(float)one withAnotherFloat:(float)another;

@end
