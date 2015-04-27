//
//  CardCell.m
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "CardCell.h"
#import "UIImageView+AFNetworking.h"

@interface CardCell ()

@end

@implementation CardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.indicator.hidden = YES;
    [self.getBalanceButton addTarget:self action:@selector(didPressGetBalanceButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCard:(Card *)card
{
    _card = card;
    
    NSString *currentBalanceString = @"--";
    
    if (_card.currentBalance) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode: NSNumberFormatterRoundHalfUp];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        currentBalanceString = [formatter stringFromNumber:_card.currentBalance];
    }
    
    self.currentBalanceLabel.text = currentBalanceString;
    self.barcodeLabel.text = _card.barcode;
    
    NSURL *logoURL = [NSURL URLWithString:_card.merchant.logoImageURL];
    [self.logoImageView setImageWithURL:logoURL placeholderImage:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (self.isShowingActivity) {
        [self showActivity];
    }
    else
    {
        [self endActivity];
    }
}

- (void)showActivity
{
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    
    self.isShowingActivity = YES;
}

- (void)endActivity
{
    self.indicator.hidden = YES;
    [self.indicator stopAnimating];
    
    self.isShowingActivity = NO;
}

- (void)didPressGetBalanceButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pressedGetBalanceButtonForCell:)]) {
        [self.delegate pressedGetBalanceButtonForCell:self];
    }
}

@end
