//
//  BCMerchantCell.h
//  BCWallet
//
//  Created by Zach Prager on 2/20/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Merchant+Additions.h"

@interface MerchantCell : UITableViewCell

@property (nonatomic) Merchant *merchant;

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end
