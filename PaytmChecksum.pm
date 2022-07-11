# Paytm uses checksum signature to ensure that API requests and responses shared between your 
# application and Paytm over network have not been tampered with. We use SHA256 hashing and 
# AES128 encryption algorithm to ensure the safety of transaction data.
#
# @author     Lalit Kumar
# @version    2.0.1
# @link       https://developer.paytm.com/docs/checksum/#perl

package PaytmChecksum;
use Digest::SHA qw(sha256_hex);
use Crypt::CBC;
use MIME::Base64;


use constant IV    => '@@@@&&&&####$$$$';

sub encrypt{
	my($input,$key) = @_;
	my $cipher = Crypt::CBC->new({
		'key'         => $key, # 256 bits
		'cipher'      => "Crypt::Rijndael",
		'iv'          => IV,
		'literal_key' => 1,
		'header'      => "none",
		'keysize'     => 16 
	});

	my $encrypted = $cipher->encrypt($input);
	$encrypted = encode_base64($encrypted);
	chomp($encrypted);
	return $encrypted;
}

sub decrypt{
	my ($encrypted, $key)= @_;
	$encrypted = decode_base64($encrypted);
	my $cipher = Crypt::CBC->new({
		'key'         => $key, # 256 bits
		'cipher'      => "Crypt::Rijndael",
		'iv'          => IV,
		'literal_key' => 1,
		'header'      => "none",
		'keysize'     => 16 
	});

	my $decrypted = $cipher->decrypt($encrypted);    
	chomp($decrypted);
	return $decrypted;
}

sub generateSignature{
	my ($params, $key)= @_;
	if(ref($params) eq "HASH") {
		$params = getStringByParams(%$params);
	}			
	return generateSignatureByString($params, $key);
}
sub verifySignature{
	my ($params, $key, $checksum)= @_;
	if(exists($params["CHECKSUMHASH"])){
		delete($params{"CHECKSUMHASH"});
	}
	if(ref($params) eq "HASH") {		
		$params = getStringByParams(%$params);
	}		
	return verifySignatureByString($params, $key, $checksum);	
}

sub generateSignatureByString{
	my ($params, $key) = @_;
	$salt	= generateRandomString(4);
	return calculateChecksum($params, $key, $salt);
}
sub verifySignatureByString{
	my ($params, $key, $checksum) = @_;
	$paytm_hash = decrypt($checksum, $key);
	$salt       = substr $paytm_hash, -4;
	return $paytm_hash == calculateHash($params, $salt) ? true : false;	
}

sub generateRandomString{
	my $random;
	my $length = shift;  

	$data = "9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAabcdefghijklmnopqrstuvwxyz!@#$&_";

	for ($i = 0; $i < $length; $i++) {
		$random .= substr $data, (int(rand(999999)) % (length $data)), 1;
	}

	return $random;
}

sub getStringByParams{
	my %params = @_;
	my @arr = ();
    foreach my $key (sort (keys(%params))) {
        if (exists $params{$key}){			  	
            push @arr, defined($params{$key}) && lc $params{$key} != "null" ? $params{$key} : "";
        }
    }
   return join '|',@arr;
}

sub calculateHash{
	my ($params, $salt) = @_;
	$finalString = $params . "|" . $salt;
	$hash = sha256_hex($finalString);
	$hashString = $hash . $salt;
	return $hashString
}

sub calculateChecksum{
	my ($params, $key, $salt) = @_;
	$hashString = calculateHash($params, $salt);
	$checksum = encrypt($hashString, $key);
	$checksum =~ s/[\n\r]//g;
	return $checksum;
}
1;