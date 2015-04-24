//
//  AppTokenInputCell.h
//  BCWallet
//
//  Created by Zach Prager on 4/24/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppTokenInputCell;

@protocol AppTokenInputDelegate <NSObject>

@optional
- (void)cell:(AppTokenInputCell *)cell didUpdateAppToken:(NSString *)appToken;

@end

@interface AppTokenInputCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<AppTokenInputDelegate> delegate;
@end

