# bluecats-wallet-ios

BlueCats Wallet for iOS works in tandem with the OS X app of the same name.  Please find it [here](https://github.com/bluecats/bluecats-wallet-osx).

####Entering a Gift Card
Open BC Wallet for iOS and press the plus sign in the top right hand corner to add a gift card.  Select the merchant and enter the respective barcode for that gift card. Then press **Save**.

####Sending a Balance Request
Pull down on the mobile gift card listing to send Gift Card Balance Requests to the USB beacon over a single BLE connection.  This will update current balances and add any aditional 

####Gift Card Redemption Requests
When Gift Card Redemption Requests are received within the appropriate proximity, BC Wallet for iOS will prompt for an amount to be applied to the purchase.

If the mobile has more than one gift card for the merchant, the one with the lowest balance will be redeemed first. If a gift card with a balance less than the remaining amount of the transaction is redeemed, then it will be re-tendered.

The transaction can be paid by multiple gift cards and devices. 

The entry field will be prepopulated with the remaining amount of the transaction or the current balance of the gift card. To use this amount press **Yes** or enter a custom amount.  This will send a Gift Card Redemption Response.
