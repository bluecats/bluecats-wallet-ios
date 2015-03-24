//
//  NSManagedObject+BCExtra.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (BCExtra)

+ (NSManagedObject *)firstInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countInManagedObjectContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;
+ (NSArray *)destroyAllInManagedContext:(NSManagedObjectContext *)context;

+ (NSArray *)entitiesInManagedObjectContext:(NSManagedObjectContext *)context
                              withPredicate:(NSPredicate *)predicate;
+ (NSArray *)entitiesInManagedObjectContext:(NSManagedObjectContext *)context
                              withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors andPrefetches:(NSArray *)prefetchKeyArray limit:(NSUInteger)limit;

+ (id)entityInManagedObjectContext:(NSManagedObjectContext *)context
                     withPredicate:(NSPredicate *)predicate;

@end
