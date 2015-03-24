//
//  CardsViewController.m
//  BCWallet
//
//  Created by Zach Prager on 1/6/15.
//  Copyright (c) 2015 BlueCats. All rights reserved.
//

#import "CardsViewController.h"
#import "AppDelegate.h"
#import "BCMicroLocationManager.h"
#import "BCMicroLocation.h"
#import "BCCategory.h"
#import "BCEventManager.h"
#import "BCEventFilter.h"
#import "BCBeacon+Card.h"
#import "Constants.h"
#import "AddCardViewController.h"
#import "TransactionAlertView.h"
#import "UIViewController+Additions.h"
#import "UIColor+Additions.h"
#import "BCCustomValue.h"

NSString * const kTriggerIdentifierEnteredBeacon = @"TriggerIdentifierEnteredBeacon";
NSString * const kTriggerIdentifierRegisterInProximity = @"TriggerIdentifierRegisterInProximity";
NSString * const kTriggerIdentifierTransactionInProximity = @"TriggerIdentifierTransactionInProximity";
NSString * const kTriggerIdentifierEnteredMerchant = @"TriggerIdentifierEnteredMerchant";
NSString * const kTransactionRegisterBeaconKey = @"kTransactionRegisterBeaconKey";
NSString * const kTransactionCardIndexKey = @"kTransactionCardIndexKey";

@interface CardsViewController () <BCEventManagerDelegate, BCMicroLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic) NSArray *cards;
@property (nonatomic) BCEventManager * eventManager;
@property (nonatomic) NSMutableDictionary *currentlyVisitingRegisterBeaconsWithSerial;
@property (nonatomic) NSMutableDictionary *currentlyVisitingMerchantIDs;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) BOOL didShowRegisterNearbyNotification;

@end

@implementation CardsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setMaximumFractionDigits:2];
    [self.numberFormatter setRoundingMode: NSNumberFormatterRoundHalfUp];
    [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.eventManager = [[BCEventManager alloc] init];
    self.eventManager.delegate = self;
    
    [self setupNeverSeenRegisterFilter];
    [self setupRegisterProximityFilter];
    [self setupTransactionProximityFilter];
    [self setupNeverSeenMerchantFilter];
    
    self.currentlyVisitingRegisterBeaconsWithSerial = [[NSMutableDictionary alloc] init];
    self.currentlyVisitingMerchantIDs = [[NSMutableDictionary alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(requestCurrentBalances)
                  forControlEvents:UIControlEventValueChanged];
    
    [[BCMicroLocationManager sharedManager] setDelegate:self];
    [[BCMicroLocationManager sharedManager] startUpdatingMicroLocation];
    
    self.editButtonItem.tintColor = [UIColor darkTextColor];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self setFontFamily:@"Avenir-Medium" forView:self.navigationController.navigationBar includingSubViews:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableViewData];
}

- (void)setupNeverSeenMerchantFilter
{
    BCEventFilter *neverSeenFilter = (BCEventFilter *)[BCEventFilter filterByNeverEnteredBeacon];
    BCEventFilter *merchantFilter = (BCEventFilter *)[BCEventFilter filterByCategoriesWithCustomValueKeys:@[WalletMerchantIDKey]];
    BCTrigger* enteredNewBeacon = [[BCTrigger alloc] initWithIdentifier:kTriggerIdentifierEnteredMerchant
                                                             andFilters:@[merchantFilter, neverSeenFilter]];
    enteredNewBeacon.repeatCount = NSIntegerMax;
    [self.eventManager monitorEventWithTrigger:enteredNewBeacon];
}

- (void)setupNeverSeenRegisterFilter
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"syncStatus = %i", BCSyncStatusSynced];
    BCEventFilter *syncedFilter = (BCEventFilter *)[BCEventFilter filterByPredicate:pred];
    BCEventFilter *neverSeenFilter = (BCEventFilter *)[BCEventFilter filterByNeverEnteredBeacon];
    BCEventFilter *registerFilter = (BCEventFilter *)[BCEventFilter filterByCustomValuesWithKeys:@[WalletRegisterIDKey]];
    BCTrigger* enteredNewBeacon = [[BCTrigger alloc] initWithIdentifier:kTriggerIdentifierEnteredBeacon
                                                             andFilters:@[syncedFilter, registerFilter, neverSeenFilter]];
    enteredNewBeacon.repeatCount = NSIntegerMax;
    [self.eventManager monitorEventWithTrigger:enteredNewBeacon];
}

- (void)setupRegisterProximityFilter
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"syncStatus = %i", BCSyncStatusSynced];
    BCEventFilter *syncedFilter = (BCEventFilter *)[BCEventFilter filterByPredicate:pred];
    BCEventFilter *proximityFilter = (BCEventFilter *)[BCEventFilter filterByProximities:@[@(BCProximityFar), @(BCProximityImmediate), @(BCProximityNear)]];
    BCEventFilter *registerFilter = (BCEventFilter *)[BCEventFilter filterByCustomValuesWithKeys:@[WalletRegisterIDKey]];
    BCTrigger *registerInProximityTrigger = [[BCTrigger alloc] initWithIdentifier:kTriggerIdentifierRegisterInProximity
                                                                       andFilters:@[syncedFilter, registerFilter, proximityFilter]];
    registerInProximityTrigger.repeatCount = NSIntegerMax;
    [self.eventManager monitorEventWithTrigger:registerInProximityTrigger];
}

- (void)setupTransactionProximityFilter
{
    //BCEventFilter *proximityFilter = (BCEventFilter *)[BCEventFilter filterByProximities:@[@(BCProximityFar), @(BCProximityImmediate), @(BCProximityNear)]];
    
    BCEventFilter *proximityFilter = (BCEventFilter *)[BCEventFilter filterByProximities:@[@(BCProximityImmediate)]];
    BCEventFilter *registerFilter = (BCEventFilter *)[BCEventFilter filterByCustomValuesWithKeys:@[WalletRegisterIDKey]];
    BCEventFilter *blockDataFilter = (BCEventFilter *)[BCEventFilter filterByReassembledBlockDataWithDataType:BCBlockDataTypeCustom];
    BCTrigger *registerInProximityTrigger = [[BCTrigger alloc] initWithIdentifier:kTriggerIdentifierTransactionInProximity
                                                                       andFilters:@[registerFilter, proximityFilter, blockDataFilter]];
    registerInProximityTrigger.repeatCount = NSIntegerMax;
    [self.eventManager monitorEventWithTrigger:registerInProximityTrigger];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        @synchronized(self){
            Card *card = [self.cards objectAtIndex:indexPath.row];
            NSMutableArray *mutableCopy = [self.cards mutableCopy];
            [mutableCopy removeObjectAtIndex:indexPath.row];
            [self.managedContext deleteObject:card];
            self.cards = mutableCopy;
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)updateLocalStoreFromRegisterBeacon:(BCBeacon *)beacon
{
    for (NSDictionary *merchantInfo in [beacon merchantInfos])
    {
        Merchant *merchant = nil;
        NSString *merchantID = [merchantInfo objectForKey:WalletMerchantIDKey];
        if (merchantID)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"merchantID = %@", merchantID];
            merchant = (Merchant *)[Merchant entityInManagedObjectContext:self.managedContext withPredicate:predicate];
        }
        
        if (!merchant)
        {
            merchant = [Merchant createMerchantInContext:self.managedContext];
        
            // Create default card for merchant
            Card *card = [Card createCardInContext:self.managedContext];
            card.merchant = merchant;
            card.barcode = @"bluecats";
        }
        
        [merchant updateWithMerchantInfo:merchantInfo];
    }
}

- (NSDictionary *)findFirstMerchantInfoInArray:(NSArray *)merchantInfos withMerchantID:(NSString *)merchantIDToFind
{
    for (NSDictionary *merchantInfo in merchantInfos) {
        NSString *merchantID = [merchantInfo objectForKey:WalletMerchantIDKey];
        if ([merchantIDToFind isEqualToString:merchantID]) {
            return merchantInfo;
        }
    }
    return nil;
}

- (NSInteger)indexOfCardWithBarcode:(NSString *)barcode andMerchantID:(NSString *)merchantID
{
    for (NSInteger index = 0; index < self.cards.count; index++) {
        Card *card = [self.cards objectAtIndex:index];
        if ([card.barcode isEqualToString:barcode] &&
            [card.merchant.merchantID isEqualToString:merchantID]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)requestCurrentBalances
{
    NSArray *registerBeacons = self.currentlyVisitingRegisterBeaconsWithSerial.allValues;
    
    BCBeacon *closestRegisterBeacon = [[registerBeacons sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                           BCBeacon *b1 = (BCBeacon *)obj1;
                                           BCBeacon *b2 = (BCBeacon *)obj2;
                                           
                                           return [b1.rssi compare:b2.rssi];
                                           
                                       }] lastObject];
    
    if (!closestRegisterBeacon) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
        
        return;
    }
    
    NSMutableArray *cardsForClosestRegister = [NSMutableArray array];
    
    NSArray *merchantInfosForRegister = [closestRegisterBeacon merchantInfos];
    if (merchantInfosForRegister && merchantInfosForRegister.count > 0) {
        
        for (Card *card in self.cards) {
            
            NSDictionary *merchantInfo = [self findFirstMerchantInfoInArray:merchantInfosForRegister
                                                             withMerchantID:card.merchant.merchantID];
            if (merchantInfo) {
                NSLog(@"Requesting balance for card %@ from merchant %@", card.barcode, card.merchant.name);
                [cardsForClosestRegister addObject:card];
            }
        }
    }
    
    NSMutableArray *requestDataArray = [NSMutableArray array];
    for (Card *card in cardsForClosestRegister) {
        
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:@{WalletDataTypeTinyKey: [NSString stringWithFormat:@"%@", @(WalletDataTypeCardBalanceRequest)], WalletCardBarcodeTinyKey: card.barcode, WalletMerchantIDTinyKey: card.merchant.merchantID} options:0 error:nil];
        [requestDataArray addObject:requestData];
    }
    
    [closestRegisterBeacon requestDataArrayFromBeaconEndpoint:BCBeaconEndpointUSBHost withDataArray:requestDataArray success:^(NSArray *responseDataArray) {
        
        for (NSData *responseData in responseDataArray) {
            
            NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            if (responseInfo) {
                
                NSString *barcode = [responseInfo objectForKey:WalletCardBarcodeTinyKey];
                NSString *merchantID = [responseInfo objectForKey:WalletMerchantIDTinyKey];
                
                NSInteger indexOfCard = [self indexOfCardWithBarcode:barcode andMerchantID:merchantID];
                Card *card = [self.cards objectAtIndex:indexOfCard];
                
                NSArray *errorCodes = [responseInfo objectForKey:WalletErrorsTinyKey];
                if (!errorCodes || (errorCodes.count == 0))
                {
                    NSString *currentBalanceString = [responseInfo objectForKey:WalletCardCurrentBalanceTinyKey];
                    card.currentBalance = [self.numberFormatter numberFromString:currentBalanceString];
                    
                    NSString *openingBalanceString = [responseInfo objectForKey:WalletCardOpeningBalanceTinyKey];
                    card.openingBalance = [self.numberFormatter numberFromString:openingBalanceString];
                }
                else if (errorCodes.count > 0)
                {
                    NSMutableString *message = [[NSString stringWithFormat:@"Unable to get balance for card with barcode %@ from %@'s register %@ due to the following errors:", barcode, card.merchant.name, closestRegisterBeacon.registerID] mutableCopy];
                    
                    for (NSNumber *errorCode in errorCodes)
                    {
                        NSString *errorString = [self descriptionForWalletError:(WalletError)[errorCode integerValue]];
                        [message appendFormat:@" %@", errorString];
                    }
                    
                    NSString *title = @"Balance Request Failed";
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                        message:message
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alertView show];
                    });
                }
            }
        }
        
        [self saveContext];
        
        [self reloadTableViewData];
        
    } status:^(NSString *status) {
        
        NSLog(@"Balance request status %@", status);
        
    } failure:^(NSError *error) {
        
        NSString *message = [NSString stringWithFormat:@"Unable to get balance from register %@.", closestRegisterBeacon.registerID];
        
        NSString *title = @"Balance Requests Failed";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
            [self.refreshControl endRefreshing];
        });
        
    }];
}

- (void)reloadTableViewData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.cards = [Card entitiesInManagedObjectContext:self.managedContext withPredicate:nil];
        [self.tableView reloadData];
        
        if (self.refreshControl) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
            
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:12.0f], NSForegroundColorAttributeName: [UIColor blackColor]}];
            self.refreshControl.attributedTitle = attributedTitle;
            
            [self.refreshControl endRefreshing];
        }
    });
}

- (void)scheduleLocalNotificationWithMessage:(NSString *)message
{
    NSString *alertMessage = message;
    NSDate *dateTime = [[NSDate date] dateByAddingTimeInterval:2];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = dateTime;
    localNotification.alertBody = alertMessage;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)eventManager:(BCEventManager *)eventManager triggeredEvent:(BCTriggeredEvent *)triggeredEvent
{
    if ([triggeredEvent.event.eventIdentifier isEqualToString:kTriggerIdentifierEnteredBeacon]) {
        
        for (BCBeacon *registerBeacon in triggeredEvent.filteredMicroLocation.beacons) {
            
            NSLog(@"entered register beacon %@", registerBeacon.serialNumber);
            [self updateLocalStoreFromRegisterBeacon:registerBeacon];
        }
        
        [self saveContext];
        [self reloadTableViewData];
    }
    else if ([triggeredEvent.event.eventIdentifier isEqualToString:kTriggerIdentifierRegisterInProximity])
    {
        BOOL needsTableViewReload = NO;
        for (BCBeacon *registerBeacon in triggeredEvent.filteredMicroLocation.beacons) {
            
            if (![self.currentlyVisitingRegisterBeaconsWithSerial objectForKey:registerBeacon.serialNumber]) {
                
                for (NSDictionary *merchInfo in [registerBeacon merchantInfos]) {
                    
                    NSString *merchantID = [merchInfo objectForKey:WalletMerchantIDKey];
                    if (merchantID) {
                        
                        NSMutableArray *availableRegistersWithMerchID = [self.currentlyVisitingMerchantIDs objectForKey:merchantID];
                        if (!availableRegistersWithMerchID) {
                            NSMutableArray *availableRegister = [NSMutableArray arrayWithObject:registerBeacon];
                            [self.currentlyVisitingMerchantIDs setObject:availableRegister forKey:merchantID];
                        }
                        else {
                            [availableRegistersWithMerchID addObject:registerBeacon];
                        }
                    }
                }
                
                @synchronized(self) {
                    
                    NSLog(@"nearby register beacon %@", registerBeacon.serialNumber);
                    [self.currentlyVisitingRegisterBeaconsWithSerial setObject:registerBeacon forKey:registerBeacon.serialNumber];
                    
                    needsTableViewReload = YES;
                    NSLog(@"nearby merchants %@", self.currentlyVisitingMerchantIDs);
                }
            }
        }
        
        if (needsTableViewReload) [self reloadTableViewData];
    }
    else if ([triggeredEvent.event.eventIdentifier isEqualToString:kTriggerIdentifierTransactionInProximity]) {
        
        NSLog(@"THERE IS A TRANSACTION IN PROX");
        for (BCBeacon *registerBeacon in triggeredEvent.filteredMicroLocation.beacons) {
            
            NSArray *blockDataArray = [registerBeacon reassembledBlockDataWithDataType:BCBlockDataTypeCustom];
            NSDictionary *lastDataInfo = [blockDataArray lastObject];
            NSData *data = [lastDataInfo objectForKey:BCBlueCatsBlockDataKey];
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (json && !jsonError) {
                
                NSString *merchantID = [json objectForKey:WalletMerchantIDTinyKey];
                int index = 0;
                int cardIndex = 0;
                double lowestCurrentBalance = NSIntegerMax;
                
                for (Card *card in self.cards) {
                    
                    if ([card.merchant.merchantID isEqualToString:merchantID]) {
                        
                        if ([card.currentBalance doubleValue] < lowestCurrentBalance &&
                            ([card.currentBalance doubleValue] > 0)) {
                            
                            cardIndex = index;
                            lowestCurrentBalance = [card.currentBalance doubleValue];
                        }
                    }
                    index++;
                }
                
                if (lowestCurrentBalance != NSIntegerMax) {
                    
                    NSMutableDictionary *transactionInfo = [@{
                                                           kTransactionRegisterBeaconKey: registerBeacon,
                                                           kTransactionCardIndexKey: @(cardIndex)
                                                           } mutableCopy];
                    
                    [transactionInfo addEntriesFromDictionary:json];
                    [self showCardRedmeptionViewForTransactionRequest:transactionInfo];
                }
                else {
                    NSLog(@"No cards with a balance found.");
                }
            }
        }
    }
    else if ([triggeredEvent.event.eventIdentifier isEqualToString:kTriggerIdentifierEnteredMerchant]) {
        
        if (!self.didShowRegisterNearbyNotification &&
            [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            
            NSString *message = @"Welcome Back. Special offer expires soon!";
            BCBeacon *beacon = [triggeredEvent.filteredMicroLocation.beacons firstObject];
            for (BCCategory *category in beacon.categories) {
                
                BOOL doBreak = NO;
                for (BCCustomValue *customValue in category.customValues) {
                    
                    if ([customValue.key isEqualToString:WalletMerchantWelcomeMessageKey]) {
                        
                        message = customValue.value;
                        doBreak = YES;
                        break;
                    }
                }
                if (doBreak) break;
            }
            
            [self scheduleLocalNotificationWithMessage:message];
            self.didShowRegisterNearbyNotification = YES;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Card *card = [self.cards objectAtIndex:indexPath.row];
    
    CardCell *cardCell = (CardCell *)cell;
    cardCell.backgroundColor = [UIColor colorWithHexString:card.merchant.backgroundHexColor];
    cardCell.barcodeLabel.textColor = [UIColor colorWithHexString:card.merchant.textHexColor];
    cardCell.currentBalanceLabel.textColor = [UIColor colorWithHexString:card.merchant.textHexColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CardCell";
    
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Card *card = [self.cards objectAtIndex:indexPath.row];
    cell.card = card;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cards.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)reset
{
    // delete all rows in database
    [Card destroyAllInManagedContext:self.managedContext];
    [Merchant destroyAllInManagedContext:self.managedContext];
}

- (void)saveContext
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ad saveContext];
}

#pragma BCMicroLocationManagerDelegate

- (void) microLocationManager:(BCMicroLocationManager *)microLocationManager didEndVisitForBeaconsWithSerialNumbers:(NSArray *)serialNumbers
{
    BOOL needsTableViewReload = NO;
    
    for (NSString *serialNumber in serialNumbers) {
        
        BCBeacon *registerBeacon = [self.currentlyVisitingRegisterBeaconsWithSerial objectForKey:serialNumber];
        if (registerBeacon) {
            
            for (NSDictionary *merchantInfo in [registerBeacon merchantInfos])
            {
                NSString *merchantID = [merchantInfo objectForKey:WalletMerchantIDKey];
                if (merchantID) {
                    
                    NSMutableArray *availableRegistersWithMerchID = [self.currentlyVisitingMerchantIDs objectForKey:merchantID];
                    if (availableRegistersWithMerchID && (availableRegistersWithMerchID.count < 2)) {
                        [self.currentlyVisitingMerchantIDs removeObjectForKey:merchantID];
                    }
                    else if (availableRegistersWithMerchID) {
                        [availableRegistersWithMerchID removeObject:registerBeacon];
                    }
                }
            }
            
            @synchronized(self)
            {
                [self.currentlyVisitingRegisterBeaconsWithSerial removeObjectForKey:serialNumber];
                needsTableViewReload = YES;
                NSLog(@"currently visiting merch ids with registers %@", self.currentlyVisitingMerchantIDs);
            }
        }
    }
    
    if (needsTableViewReload) [self.tableView reloadData];
}

- (void)showCardRedmeptionViewForTransactionRequest:(NSDictionary *)request
{
    NSNumber *cardIndex = [request objectForKey:kTransactionCardIndexKey];
    NSString *amountString = [request objectForKey:WalletTransactionRemainingAmountTinyKey];
    NSNumber *amount = [self.numberFormatter numberFromString:amountString];
    Card *card = [self.cards objectAtIndex:[cardIndex integerValue]];
    
    double suggestedAmount = MIN([card.currentBalance doubleValue], MAX([amount doubleValue], [amount doubleValue] - [card.currentBalance doubleValue]));
    
    NSString *title = [NSString stringWithFormat:@"All on your %@ card?", card.merchant.name];
    NSString *msg = [NSString stringWithFormat:@"If no, enter how much below."];
    
    TransactionAlertView *alert = [[TransactionAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.transactionRequest = request;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    
    UITextField *amountInputField = [alert textFieldAtIndex:0];
    amountInputField.placeholder = [NSString stringWithFormat:@"%.2f", suggestedAmount];
    amountInputField.keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if (buttonIndex == 1) {
        
        if ([alertView isKindOfClass:[TransactionAlertView class]]) {
            
            TransactionAlertView *tranactionAlert = (TransactionAlertView *)alertView;
            UITextField *amountInputField = [tranactionAlert textFieldAtIndex:0];
            
            NSDecimalNumber *amount;
            if (amountInputField.text.length > 0) {
                amount = [NSDecimalNumber decimalNumberWithString:amountInputField.text];
            }
            
            [self redeemCardForTransactionRequest:tranactionAlert.transactionRequest forAmount:amount];
        }
    }
}

- (void)redeemCardForTransactionRequest:(NSDictionary *)transaction
                                         forAmount:(NSDecimalNumber *)amount
{
    BCBeacon *registerBeacon = [transaction objectForKey:kTransactionRegisterBeaconKey];
    NSNumber *cardIndex = [transaction objectForKey:kTransactionCardIndexKey];
    Card *card = [self.cards objectAtIndex:[cardIndex integerValue]];
    
    NSString *barcode = card.barcode;
    NSString *merchantID = [transaction objectForKey:WalletMerchantIDTinyKey];
    NSString *transactionID = [transaction objectForKey:WalletTransactionIDTinyKey];
    
    NSMutableDictionary *requestInfo = [@{
                                    WalletDataTypeTinyKey: [NSString stringWithFormat:@"%@", @(WalletDataTypeCardRedemptionRequest)],
                                    WalletCardBarcodeTinyKey: barcode,
                                    WalletMerchantIDTinyKey: merchantID,
                                    WalletTransactionIDTinyKey: transactionID,
                                    } mutableCopy];
    if (amount) {
        [requestInfo setObject:[self.numberFormatter stringFromNumber:amount] forKey:WalletAmountTinyKey];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tinyDeviceID = [userDefaults objectForKey:WalletUserIdDefaultsKey];
    if (tinyDeviceID) {
        [requestInfo setObject:tinyDeviceID forKey:WalletDeviceIDTinyKey];
    }
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestInfo options:0 error:nil];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[cardIndex integerValue] inSection:0];
    CardCell *cell = (CardCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showActivity];
    
    [registerBeacon requestDataArrayFromBeaconEndpoint:BCBeaconEndpointUSBHost withDataArray:@[requestData] success:^(NSArray *responseDataArray)
     {
         NSData *responseData = [responseDataArray lastObject];
         NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
         if (responseInfo)
         {
             NSArray *errorCodes = [responseInfo objectForKey:WalletErrorsTinyKey];
             if (!errorCodes || (errorCodes.count == 0))
             {
                 NSString *currentBalanceString = [responseInfo objectForKey:WalletCardCurrentBalanceTinyKey];
                 NSNumber *currentBalance = [self.numberFormatter numberFromString:currentBalanceString];
                 card.currentBalance = currentBalance;
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                     [self saveContext];
                 });
             }
             else if (errorCodes.count > 0)
             {
                 NSMutableString *mutableErrorString = [@"Transaction failed with errors:" mutableCopy];
                 for (NSNumber *errorCode in errorCodes) {
                     
                     NSString *errorString = [self descriptionForWalletError:(WalletError)[errorCode integerValue]];
                     [mutableErrorString appendFormat:@" %@", errorString];
                 }
                 
                 NSString *title = [NSString stringWithFormat:@"Could Not Complete Transaction For %@", registerBeacon.serialNumber];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                     message:mutableErrorString
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                     [alertView show];
                 });
             }
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [cell endActivity];
         });
         
     } status:^(NSString *status)
     {
         NSLog(@"status %@", status);
         
     } failure:^(NSError *error) {
         
         NSLog(@"failure !! !! %@", error);
         NSString *title = [NSString stringWithFormat:@"USB Beacon Connection Failed For %@", registerBeacon.serialNumber];
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
             [alertView show];
             [cell endActivity];
         });
     }];
    
}

- (NSString *)descriptionForWalletError:(WalletError)errorCode
{
    
    switch (errorCode)
    {
        case WalletErrorSerializationFailed:
            return @"Serialization Failed";
            break;
        case WalletErrorJSONInvalid:
            return @"JSON Invalid";
            break;
        case WalletErrorRequestTypeMissing:
            return @"Request Type Missing";
            break;
        case WalletErrorRequestTypeNotSupported:
            return @"Request Type Not Supported";
            break;
        case WalletErrorMerchantIDMissing:
            return @"Merchant ID Is Missing";
            break;
        case WalletErrorCardNotFound:
            return @"Card Not Found";
            break;
        case WalletErrorCardBarcodeMissing:
            return @"Card Barcode Is Missing";
            break;
        case WalletErrorCardBalanceInsufficient:
            return @"Card Balance Insuffient";
            break;
        case WalletErrorTransactionIDMissing:
            return @"Transaction ID Is Missing";
            break;
        case WalletErrorTransactionNotFound:
            return @"Transaction Not Found";
            break;
        case WalletErrorTransactionCanceled:
            return @"Transaction Canceled";
            break;
        case WalletErrorTransactionCompleted:
            return @"Transaction Completed";
            break;
        case WalletErrorMerchantNotSupported:
            return @"Merchant Not Supported";
            break;
        case WalletErrorSpecifiedAmountExceedsRemainingAmount:
            return @"Specified Amount Exceeds Transaction Remaining Amount";
            break;
        default:
            return @"Unknown Error";
            break;
    }
}


static NSString *addCardSegue = @"addCardSegue";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:addCardSegue])
    {
        AddCardViewController *vc = [((UINavigationController *)segue.destinationViewController).viewControllers objectAtIndex:0];
        vc.managedContext = self.managedContext;
    }
}

@end
