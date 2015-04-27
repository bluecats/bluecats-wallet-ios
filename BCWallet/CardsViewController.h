//
//  CardsViewController.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card+Additions.h"
#import "Merchant+Additions.h"
#import "CardCell.h"
#import "NSManagedObject+Additions.h"

@interface CardsViewController : UITableViewController <CardCellDelegate>

@property (nonatomic) NSManagedObjectContext *managedContext;

@end
