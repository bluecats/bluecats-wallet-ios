//
//  ComparisonUtilities.m
//  BCWallet
//
//  Created by Cody Singleton on 2/22/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "ComparisonUtilities.h"

@implementation ComparisonUtilities

+ (NSComparisonResult)compareOneDouble:(double)one withAnotherDouble:(double)another
{
    if (fabs(one - another) < DBL_EPSILON) {
        return NSOrderedSame;
    }
    else if (one > another) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedAscending;
    }
}

+ (BOOL)isOneDouble:(double)one lessThanOrEqualToAnotherDouble:(double)another
{
    NSComparisonResult result = [self compareOneDouble:one withAnotherDouble:another];
    
    return (result == NSOrderedSame || result == NSOrderedAscending) ? YES : NO;
}

+ (BOOL)isOneDouble:(double)one lessThanAnotherDouble:(double)another
{
    NSComparisonResult result = [self compareOneDouble:one withAnotherDouble:another];
    
    return (result == NSOrderedAscending) ? YES : NO;
}

+ (BOOL)isOneDouble:(double)one greaterThanOrEqualToAnotherDouble:(double)another
{
    NSComparisonResult result = [self compareOneDouble:one withAnotherDouble:another];
    
    return (result == NSOrderedSame || result == NSOrderedDescending) ? YES : NO;
}

+ (BOOL)isOneDouble:(double)one greaterThanAnotherDouble:(double)another
{
    NSComparisonResult result = [self compareOneDouble:one withAnotherDouble:another];
    
    return (result == NSOrderedDescending) ? YES : NO;
}

+ (NSComparisonResult)compareOneFloat:(float)one withAnotherFloat:(float)another
{
    if (fabs(one - another) < FLT_EPSILON) {
        return NSOrderedSame;
    }
    else if (one > another) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedAscending;
    }
}

@end
