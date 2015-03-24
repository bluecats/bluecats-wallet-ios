//
//  AddCardViewController.h
//  BCWallet
//
//  Created by Zach Prager on 2/19/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCardViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic) NSManagedObjectContext *managedContext;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
