//
//  AddCardViewController.m
//  BCWallet
//
//  Created by Zach Prager on 2/19/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "AddCardViewController.h"
#import "Merchant+Additions.h"
#import "Card+Additions.h"
#import "NSManagedObject+Additions.h"
#import "AppDelegate.h"
#import "BarcodeCell.h"
#import "MerchantCell.h"
#import "UIViewController+Additions.h"
#import "UIColor+Additions.h"

const CGFloat kTableViewSectionHeaderHeight = 36.0f;
const CGFloat kTableViewSectionHeaderLabelMargin = 6.0f;
const CGFloat kTableViewSectionFooterHeight = 0.0f;

@interface AddCardViewController () <UITextFieldDelegate>

@property (nonatomic) NSArray *merchants;
@property (nonatomic) NSArray *staticCellClasses;

// static tableview cells
@property (nonatomic) BarcodeCell *barcodeCell;

@end

@implementation AddCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.merchants = [Merchant entitiesInManagedObjectContext:self.managedContext withPredicate:nil];
    self.saveButton.enabled = NO;
    self.staticCellClasses = @[[BarcodeCell class]];
    
    [self setFontFamily:@"Avenir-Medium" forView:self.navigationController.navigationBar includingSubViews:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.merchants.count > 0)
    {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableview.delegate tableView:self.tableview willSelectRowAtIndexPath:firstIndexPath];
        [self.tableview selectRowAtIndexPath:firstIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.merchants.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Merchant *merchant = [self.merchants objectAtIndex:row];
    return merchant.name;
}

- (IBAction)save:(id)sender
{
    NSIndexPath *selectedIndexPath = [self.tableview indexPathForSelectedRow];
    if (selectedIndexPath)
    {
        Card *newCard = [Card createCardInContext:self.managedContext];
        newCard.barcode = self.barcodeCell.barcodeField.text;
        newCard.merchant = [self.merchants objectAtIndex:selectedIndexPath.row];
        
        [self saveContext];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 130;
            break;
        case 1:
            return 80;
        default:
            return 80;
            break;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1) return nil;
    
    NSIndexPath *oldIndexPath = [tableView indexPathForSelectedRow];
    if (oldIndexPath) {
        MerchantCell *mercahntCellToUnSelect = (MerchantCell*)[tableView cellForRowAtIndexPath:oldIndexPath];
        mercahntCellToUnSelect.accessoryType = UITableViewCellAccessoryNone;
    }
    
    MerchantCell *merchantCellToSelect = (MerchantCell*)[tableView cellForRowAtIndexPath:indexPath];
    merchantCellToSelect.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableViewSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = nil;
    switch (section) {
        case 0:
            sectionTitle = @"Enter Barcode";
            break;
        case 1:
            sectionTitle = @"Select Merchant";
            break;
        default:
            sectionTitle = @"";
            break;
    }

    CGRect tableFrame = self.tableview.frame;
    
    CGRect labelFrame = CGRectMake(kTableViewSectionHeaderLabelMargin, 2 * kTableViewSectionHeaderLabelMargin, tableFrame.size.width - 2 * kTableViewSectionHeaderLabelMargin, kTableViewSectionHeaderHeight - 3 * kTableViewSectionHeaderLabelMargin);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"Avenir-Light" size:12];
    label.text = [sectionTitle uppercaseString];
    label.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableFrame.size.width, kTableViewSectionHeaderHeight)];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableViewSectionFooterHeight;
}

#pragma mark tableview data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[MerchantCell class]]) {
        
        MerchantCell *merchantCell = (MerchantCell *)cell;
        
        Merchant *merchant = [self.merchants objectAtIndex:indexPath.row];
        UIColor *textColor = [UIColor colorWithHexString:merchant.textHexColor];
        merchantCell.nameLabel.textColor = textColor;
        merchantCell.backgroundColor = [UIColor colorWithHexString:merchant.backgroundHexColor];
        merchantCell.tintColor = textColor;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *barcodeCellIdentifier = @"BarcodeCell";
    static NSString *merchantCellIdentifier = @"MerchantCell";
    
    if (indexPath.section == 0)
    {
        Class cellClass = [self.staticCellClasses objectAtIndex:indexPath.row];
        
        if ([cellClass isSubclassOfClass:[BarcodeCell class]])
        {
            BarcodeCell *cell = [tableView dequeueReusableCellWithIdentifier:barcodeCellIdentifier forIndexPath:indexPath];
            
            self.barcodeCell = cell;
            self.barcodeCell.barcodeField.delegate = self;
            self.barcodeCell.barcodeField.autocorrectionType = UITextAutocorrectionTypeNo;
            return cell;
        }
        
        return nil;
    }
    else
    {
        MerchantCell *cell = [tableView dequeueReusableCellWithIdentifier:merchantCellIdentifier forIndexPath:indexPath];
        cell.merchant = [self.merchants objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.staticCellClasses.count;
            break;
        case 1:
            return self.merchants.count;
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark uitextfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if ((newString.length > 0 && newString.length <= 8) &&
        (self.tableview.indexPathForSelectedRow)) {
        self.saveButton.enabled = YES;
    }
    else {
        self.saveButton.enabled = NO;
    }
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)saveContext
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ad saveContext];
}

@end
