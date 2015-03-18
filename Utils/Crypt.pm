use strict;
use warnings;

package Crypt;

use Method::Signatures;
use Digest::MD5 qw(md5_hex);

method new {
       my $obj = bless {}, $self;
       return $obj;
}

method encryptPass(Str $strPassword, Str $strKey) {
       my $strSwappedHash = $self->swapMD5(md5_hex($self->swapMD5($strPassword) . $strKey . 'Y(02.>\'H}t":E1'));
       return $strSwappedHash;
}

method swapMD5(Str $strHash) {
       my $strSwapped = substr($strHash, 16, 16);
       $strSwapped .= substr($strHash, 0, 16);
       return $strSwapped;
}

method reverseMD5(Str $strKey) {
       my $revKey = reverse($strKey);
       my $strHash = md5_hex($revKey);
       return $strHash;
}

method generateKey {
       my @arrChars = ('A'..'Z', 'a'..'z', 0..9, '!\"\A3$%^&*()_+-=[]{}:@~;#<>?|\\,./');
       my $strKey = '';
       for (0..9) {
            $strKey .= $arrChars[rand(@arrChars)];
       }
       return $strKey;
}

method generateInt(Int $intMin, Int $intMax) {
       my $intRand = rand($intMax - $intMin);
       my $intFinal = int($intMin + $intRand);
       return $intFinal;
}

1;