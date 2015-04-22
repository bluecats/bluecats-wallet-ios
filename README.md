# bluecats-wallet-ios

BlueCats Wallet uses your location to show you nearby registers that redeem your loyalty and gift cards.

BlueCats Wallet for iOS works with BC Wallet for [OS X](https://github.com/bluecats/bluecats-wallet-osx), [CSharp](https://github.com/bluecats/bluecats-wallet-csharp), and [BCLib-CSharp](https://github.com/bluecats/bclib-csharp).  

[PDF Guide](https://drive.google.com/file/d/0BxJOlyJ2qnYqX3dGbklhOHdKb0E/view?usp=sharing) to using BC Wallet for iOS with BC Wallet for OS X.

####Entering a Gift Card
Open BC Wallet for iOS and press the plus sign in the top right hand corner to add a gift card.  Select the merchant and enter the respective barcode for that card. Then press **Save**.

####Sending a Balance Request
Pull down on the mobile card list to request card balances to the USB beacon over a single BLE connection.  This will update the current balances for your cards.

####Card Redemption Requests
When card redemption requests are received within the appropriate proximity, BC Wallet for iOS will prompt for an amount to be applied to the purchase.

If the mobile has more than one gift card for the merchant, the one with the lowest balance will be redeemed first. If a gift card with a balance less than the remaining amount of the transaction is redeemed, then it will be re-tendered.

The transaction can be paid by multiple gift cards and devices. 

The entry field will be pre-populated with the remaining amount of the transaction or the current balance of the gift card. To use this amount press **Yes** or update the field with a custom amount.  This will respond with a card redemption response.
