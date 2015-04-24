//
//  SettingsViewController.h
//  BCWallet
//
//  Created by Zach Prager on 4/24/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppTokenInputCell.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,AppTokenInputDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;
@end
