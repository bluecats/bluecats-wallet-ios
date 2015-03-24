//
//  NSManagedObject+Additions.m
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (BCExtra)

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
}

+ (NSManagedObject *)firstInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil)
    {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
        
    } else if ([fetchedObjects count] > 0)
    {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

+ (NSArray *)entitiesInManagedObjectContext:(NSManagedObjectContext *)context
                              withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    
    fetchRequest.predicate = predicate;
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil)
    {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
        return @[];
    }
    else
    {
        return fetchedObjects;
    }
}

+ (NSArray *)entitiesInManagedObjectContext:(NSManagedObjectContext *)context
                              withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors andPrefetches:(NSArray *)prefetchKeyArray limit:(NSUInteger)limit
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    
    fetchRequest.relationshipKeyPathsForPrefetching = prefetchKeyArray;
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = sortDescriptors;
    [fetchRequest setFetchLimit:limit];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil)
    {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
        return @[];
    }
    else
    {
        return fetchedObjects;
    }
}

+ (id)entityInManagedObjectContext:(NSManagedObjectContext *)context
                     withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    [fetchRequest setFetchLimit:1];
    
    fetchRequest.predicate = predicate;
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil)
    {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
    }
    else if ([fetchedObjects count] > 0)
    {
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}

+ (NSUInteger)countInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self countInManagedObjectContext:context withPredicate:nil];
}

+ (NSUInteger)countInManagedObjectContext:(NSManagedObjectContext *)context
                            withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    [fetchRequest setIncludesSubentities:NO];
    if(predicate)[fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    
    if (count == NSNotFound)
    {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
        return NSNotFound;
        
    } else
    {
        return count;
    }
}

+ (NSArray *)destroyAllInManagedContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[self entityInManagedObjectContext:context]];
    
    NSError *error;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (result == nil)
    {
        NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
    }
    else if ([result count] > 0)
    {
        for (id obj in result)
            [context deleteObject:obj];
        return result;
    }
    return result;
}

@end
