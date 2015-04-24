//
//  AppTokenInputCell.m
//  BCWallet
//
//  Created by Zach Prager on 4/24/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "AppTokenInputCell.h"

@implementation AppTokenInputCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUUID *appTokenUUID = [[NSUUID alloc] initWithUUIDString:textField.text];
    if (appTokenUUID ) {
        
        if ([self.delegate respondsToSelector:@selector(cell:didUpdateAppToken:)])
        {
            [self.delegate cell:self didUpdateAppToken:textField.text];
        }
    } else
    {
        NSString *title = @"Invalid App Token";
        NSString *message = @"Copy and Paste From BC Reveal";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
