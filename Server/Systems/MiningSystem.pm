use strict;
use warnings;

package MiningSystem;

use Method::Signatures;

method new($resChild) {
       my $obj = bless {}, $self;
       $obj->{child} = $resChild;
       return $obj;
}

method handleMiningSystem($strData, $objClient) {
       my @arrData = split('%', $strData);
       my $strCmd = $arrData[3];
       if ($strCmd eq 'r#cdu') {
           my $intCoins = $self->{child}->{modules}->{crypt}->generateInt(1, 100);
           $objClient->setCoins($objClient->{property}->{personal}->{coins} + $intCoins);
           $objClient->sendXT('cdu', $arrData[4], $intCoins, $objClient->{property}->{personal}->{coins});
       }
}

1;