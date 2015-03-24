//
//  CardCell.h
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card+Additions.h"
#import "Merchant+Additions.h"

@interface CardCell : UITableViewCell

@property (nonatomic) Card *card;

@property (nonatomic, weak) IBOutlet UILabel *currentBalanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *barcodeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic) BOOL isShowingActivity;

- (void)showActivity;
- (void)endActivity;
@end
