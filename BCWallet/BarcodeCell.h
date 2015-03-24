//
//  BarcodeCell.h
//  BCWallet
//
//  Created by Zach Prager on 2/20/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarcodeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *barcodeField;
@property (nonatomic, weak) IBOutlet UILabel *instructionLabel;

@end
