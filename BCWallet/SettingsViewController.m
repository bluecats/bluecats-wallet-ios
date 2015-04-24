//
//  SettingsViewController.m
//  BCWallet
//
//  Created by Zach Prager on 4/24/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

static NSString * const sectionTitleKey     =   @"sectionTitleKey";
static NSString * const sectionContentsKey  =   @"sectionContentsKey";
static NSString * const cellTitleKey        =   @"cellTitleKey";

/* cell types */
static NSString * const appTokenTitleKey = @"AppTokenCell";

@interface SettingsViewController ()

@property (nonatomic) NSArray *settingsTableViewMap;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *sectionOneContents = @[@{cellTitleKey: appTokenTitleKey}];
    
    self.settingsTableViewMap = @[@{sectionTitleKey:@"App Token",
                                    sectionContentsKey:sectionOneContents}
                                  ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

static NSString *appTokenCellIdentifier = @"AppTokenInputCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSString *cellInfo = [[[self.settingsTableViewMap objectAtIndex:indexPath.section] valueForKey:sectionContentsKey] objectAtIndex:indexPath.row];
    
    if ([[cellInfo valueForKey:cellTitleKey] isEqualToString:appTokenTitleKey])
    {
        AppTokenInputCell *appTokenCell = [self.tableview dequeueReusableCellWithIdentifier:appTokenCellIdentifier forIndexPath:indexPath];
        appTokenCell.delegate = self;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.appToken) {
            appTokenCell.textField.text = appDelegate.appToken;
        }
        
        cell = appTokenCell;
    }
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingsTableViewMap.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.settingsTableViewMap objectAtIndex:section] valueForKey:sectionContentsKey] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.settingsTableViewMap objectAtIndex:section] valueForKey:sectionTitleKey];
}

#pragma mark app token update

- (void)cell:(AppTokenInputCell *)cell didUpdateAppToken:(NSString *)appToken
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (![appDelegate.appToken isEqualToString:appToken])
    {
        [appDelegate startupBlueCatsWithAppToken:appToken];
    }
}

@end
