# More Details: https://developer.paytm.com/docs/checksum/#perl

#!/usr/bin/perl 
use PaytmChecksum;

my $paytmParams = {
            "MID" => "YOUR_MID_HERE",
            "ORDER_ID" => "YOUR_ORDER_ID_HERE"
            };
            
# Generate checksum by parameters we have
# Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys
my $paytmChecksum = PaytmChecksum::generateSignature($paytmParams,'YOUR_MERCHANT_KEY');
my $verifyChecksum = PaytmChecksum::verifySignature($paytmParams,'YOUR_MERCHANT_KEY', $paytmChecksum);

printf("generateSignature Returns: %s\n", $paytmChecksum);
printf("verifySignature Returns: %s\n\n", $verifyChecksum);

# initialize JSON String 
$body = "{\"mid\":\"YOUR_MID_HERE\",\"orderId\":\"YOUR_ORDER_ID_HERE\"}";

# Generate checksum by parameters we have in body
# Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
my $paytmChecksum = PaytmChecksum::generateSignature($body,'YOUR_MERCHANT_KEY');
my $verifyChecksum = PaytmChecksum::verifySignature($body,'YOUR_MERCHANT_KEY', $paytmChecksum);

printf("generateSignature Returns: %s\n", $paytmChecksum);
printf("verifySignature Returns: %s\n\n", $verifyChecksum);

