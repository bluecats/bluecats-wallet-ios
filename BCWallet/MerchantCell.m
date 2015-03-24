//
//  MerchantCell.m
//  BCWallet
//
//  Created by Zach Prager on 2/20/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "MerchantCell.h"
#import "UIImageView+BCAFNetworking.h"

@implementation MerchantCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMerchant:(Merchant *)merchant
{
    _merchant = merchant;
    
    self.nameLabel.text = merchant.name;
    
    NSURL *logoURL = [NSURL URLWithString:merchant.logoImageURL];
    [self.logoImageView setImageWithURL:logoURL placeholderImage:nil];
}

@end
